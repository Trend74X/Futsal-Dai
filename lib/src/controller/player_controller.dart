import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:futsal_dai/src/model/futsal_venue_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerController extends GetxController {
  final supabase = Supabase.instance.client; 
  RxBool isBooking = false.obs;
  
  RxBool isLoadingNearByData = false.obs;
  RxList nearbyVenues = [].obs;

  // --- VENUE DETAILS VARIABLES ---
  RxBool isLoadingDetails = false.obs;
  Rx<Map<String, dynamic>?> todayHours = Rx<Map<String, dynamic>?>(null);
  RxList<dynamic> grounds = <dynamic>[].obs;
  RxList<dynamic> dailyBookings = <dynamic>[].obs;
  
  // The dynamically generated slots will be stored here for the UI to consume
  RxList<Map<String, dynamic>> availableSlots = <Map<String, dynamic>>[].obs;

  // Track the currently selected ground to filter slots (Using RxnInt for Supabase int8 IDs)
  RxnString selectedGroundId = RxnString(null);

  Future<void> loadNearbyVenues() async {
    try {
      isLoadingNearByData(true);
      final response = await supabase.rpc(
        'get_nearby_venues',
        params: {
          'user_lat': 27.6712,     // e.g. 27.6712
          'user_long': 85.3214,    // e.g. 85.3214
          'max_km': 10.0,          // Distance limit in kilometers
          'limit_count': 8
        },
      );

      nearbyVenues.value = (response as List)
        .map((item) => FutsalVenueModel.fromJson(item as Map<String, dynamic>))
        .toList();
      log(nearbyVenues.toString());
      isLoadingNearByData(false);
    } catch (e) {
      isLoadingNearByData(false);
      log('Error fetching nearby venues: $e');
    }
  }

  // --- FETCH DAILY DATA ---
  Future<void> fetchDailyVenueData(int venueId, DateTime selectedDate, dynamic venueData) async {
    isLoadingDetails.value = true;
    
    // Remember the currently selected ground
    String? previousSelectedGroundId = selectedGroundId.value;

    try {
      final dayOfWeek = selectedDate.weekday; 
      final dateString = DateFormat('yyyy-MM-dd').format(selectedDate);

      // Run queries concurrently
      final responses = await Future.wait(<Future<dynamic>>[
        supabase
            .from('operating_hours')
            .select()
            .eq('venue_id', venueId)
            .eq('day_of_week', dayOfWeek)
            .maybeSingle(),
        
        supabase
            .from('futsal_grounds')
            .select()
            .eq('venue_id', venueId)
            .eq('is_available', true),

        supabase
            .from('bookings')
            .select()
            .eq('venue_id', venueId)
            .eq('booking_date', dateString)
            .eq('is_deleted', false)
      ]);

      todayHours.value = responses[0] as Map<String, dynamic>?;
      grounds.assignAll(responses[1] as List<dynamic>);
      dailyBookings.assignAll(responses[2] as List<dynamic>);
      
      // Intelligent Ground Selection
      if (grounds.isNotEmpty) {
        bool groundExists = grounds.any((ground) => ground['id'] == previousSelectedGroundId);

        if (groundExists) {
          selectedGroundId.value = previousSelectedGroundId;
        } else {
          selectedGroundId.value = grounds.first['id'];
        }
        
        generateSlotsForSelectedGround(selectedDate, venueData);
      } else {
        selectedGroundId.value = null;
        availableSlots.clear();
      }

    } catch (e) {
      log('Error fetching daily data: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  // --- SLOT GENERATOR METHOD ---
  void generateSlotsForSelectedGround(DateTime selectedDate, dynamic venueData) {
    if (todayHours.value == null || todayHours.value!['is_closed'] == true) {
      availableSlots.clear();
      return; 
    }

    String openTimeStr = todayHours.value!['open_time'];
    String closeTimeStr = todayHours.value!['close_time'];
    bool isPeak = todayHours.value!['is_peak'] ?? false;
    double peakRate = (todayHours.value!['peak_rate'] ?? venueData.basePrice).toDouble();
    String? peakStart = todayHours.value!['peak_start_time'];
    String? peakEnd = todayHours.value!['peak_end_time'];

    // Filter bookings just for the currently selected ground
    final groundBookings = dailyBookings.where((b) => b['ground_id'] == selectedGroundId.value).toList();

    availableSlots.assignAll(_generateAvailableSlots(
      selectedDate: selectedDate,
      openingTimeStr: openTimeStr,
      closingTimeStr: closeTimeStr,
      durationMin: venueData.slotDurationMins ?? 60,
      basePrice: venueData.basePrice.toDouble(),
      isPeakEnabled: isPeak,
      peakStartTimeStr: peakStart,
      peakEndTimeStr: peakEnd,
      peakRate: peakRate,
      existingBookings: groundBookings.cast<Map<String, dynamic>>(),
    ));
  }

  List<Map<String, dynamic>> _generateAvailableSlots({
    required DateTime selectedDate,
    required String openingTimeStr, 
    required String closingTimeStr, 
    required int durationMin,       
    required double basePrice,
    required bool isPeakEnabled,
    String? peakStartTimeStr,
    String? peakEndTimeStr,
    double? peakRate,
    required List<Map<String, dynamic>> existingBookings,
  }) {
    List<Map<String, dynamic>> generatedSlots = [];

    TimeOfDay openTime = _parseTime(openingTimeStr);
    TimeOfDay closeTime = _parseTime(closingTimeStr);
    
    DateTime startTime = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, openTime.hour, openTime.minute);
    DateTime endTime = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, closeTime.hour, closeTime.minute);

    if (endTime.isBefore(startTime)) {
      endTime = endTime.add(const Duration(days: 1));
    }

    DateTime currentSlotTime = startTime;

    while (currentSlotTime.isBefore(endTime)) {
      DateTime nextSlotTime = currentSlotTime.add(Duration(minutes: durationMin));
      
      String slotLabel = "${DateFormat('HH:mm').format(currentSlotTime)} - ${DateFormat('HH:mm').format(nextSlotTime)}";

      double currentPrice = basePrice;
      if (isPeakEnabled && peakStartTimeStr != null && peakEndTimeStr != null && peakRate != null) {
        TimeOfDay peakStart = _parseTime(peakStartTimeStr);
        TimeOfDay peakEnd = _parseTime(peakEndTimeStr);
        
        if ((currentSlotTime.hour > peakStart.hour || (currentSlotTime.hour == peakStart.hour && currentSlotTime.minute >= peakStart.minute)) &&
            (currentSlotTime.hour < peakEnd.hour || (currentSlotTime.hour == peakEnd.hour && currentSlotTime.minute < peakEnd.minute))) {
          currentPrice = peakRate;
        }
      }

      String status = 'available';
      String bookedBy = '';
      
      for (var booking in existingBookings) {
        if (booking['start_time'] == DateFormat('HH:mm:ss').format(currentSlotTime) && booking['status'] != 'cancelled') {
          status = booking['status']; 
          bookedBy = booking['user_name'] ?? 'Someone';
          break;
        }
      }

      generatedSlots.add({
        'slot_start': currentSlotTime,
        'slot_end': nextSlotTime,
        'slot': slotLabel,
        'price': currentPrice,
        'status': status,
        'booked_by': bookedBy,
      });

      currentSlotTime = nextSlotTime;
    }
    return generatedSlots;
  }

  Future<void> requestBooking({
    required dynamic venueId,
    required String groundId,
    required String groundName,
    required DateTime bookingDate,
    required DateTime startTime,
    required DateTime endTime,
    required num totalPrice,
  }) async {
    isBooking.value = true;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      
      if (userId == null) {
        throw Exception('User is not logged in.');
      }

      // Pre-format the dates for both the check and the payload
      final formattedDate = DateFormat('yyyy-MM-dd').format(bookingDate);
      final formattedStartTime = DateFormat('HH:mm:ss').format(startTime);
      final formattedEndTime = DateFormat('HH:mm:ss').format(endTime);

      final payload = {
        'is_deleted': false,
        'venue_id': venueId,
        'ground_id': groundId,
        'user_id': userId,
        'booking_date': formattedDate,
        'start_time': formattedStartTime,
        'end_time': formattedEndTime,
        'total_price': totalPrice,
        'status': 'pending',
        'booking_type': 'app_booking',
        'ground_name': groundName
      };

      // 1. Check if a booking already exists for this exact slot
      final existingBooking = await Supabase.instance.client
          .from('bookings')
          .select('id')
          .eq('venue_id', venueId)
          .eq('ground_id', groundId)
          .eq('booking_date', formattedDate)
          .eq('start_time', formattedStartTime)
          .maybeSingle(); // Returns null if no record is found

      if (existingBooking != null) {
        // 2. UPDATE if it exists
        await Supabase.instance.client
            .from('bookings')
            .update(payload)
            .eq('id', existingBooking['id']);
      } else {
        // 3. INSERT if it does not exist
        await Supabase.instance.client
            .from('bookings')
            .insert(payload);
      }

      // --- NEW: UI REFRESH LOGIC ---
      // Find the slot in your observable list and update its status locally
      final slotIndex = availableSlots.indexWhere((slot) => slot['slot_start'] == startTime);
      if (slotIndex != -1) {
        availableSlots[slotIndex]['status'] = 'pending';
        availableSlots.refresh(); // Tells GetX to redraw the grid immediately
      }

      Get.snackbar(
        'Request Sent', 
        'Your booking request has been sent to the owner.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to request booking: $e', 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
      );
    } finally {
      isBooking.value = false;
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}