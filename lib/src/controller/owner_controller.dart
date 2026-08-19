import 'package:flutter/material.dart';
import 'package:futsal_dai/src/helper/cache_manager.dart';
import 'package:futsal_dai/src/widgets/custom_toast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerController extends GetxController {
  final supabase = Supabase.instance.client; 
  RxBool isLoadingData = false.obs;

  // Observable list to store pending bookings
  RxList<Map<String, dynamic>> pendingBookings = <Map<String, dynamic>>[].obs;
  RxBool isLoadingPending = false.obs;

  // Observable list for owner's grounds/pitches
  RxList<Map<String, dynamic>> venueGrounds = <Map<String, dynamic>>[].obs;
  RxBool isLoadingGrounds = false.obs;

  // Observable list for timeline bookings of the selected ground & date
  RxList<Map<String, dynamic>> groundBookings = <Map<String, dynamic>>[].obs;
  RxBool isLoadingTimeline = false.obs;

  Future<void> saveVenueAndPitches({
    required Map<String, dynamic> futsalVenues, 
    required List<Map<String, dynamic>> futsalGround,
  }) async {
    final userId = read('userId');
    if(userId == null) {
      showToast(message: "User not authenticated", isSuccess: false);
    }

    try {
      final venueResponse = await supabase
          .from('futsal_venues')
          .insert(futsalVenues)
          .select('id')
          .single();
      final int venueId = venueResponse['id'];
      write('venueId', venueResponse['id']);

      final List<Map<String, dynamic>> groundsData = futsalGround.map((ground) {
        return {
          ...ground,
          'venue_id': venueId,
        };
      }).toList();

      await supabase.from('futsal_grounds').insert(groundsData);
      showToast(message: "Venue and pitches saved successfully!", isSuccess: true);
    } catch (e) {
      showToast(message: "Failed to save data: $e", isSuccess: false);
    }
  }

  Future<void> updateVenueAndPitches({
    required dynamic venueId,
    required Map<String, dynamic> futsalVenues,
    required List<Map<String, dynamic>> futsalGround,
    List<dynamic> deletedPitchIds = const [],
  }) async {
    final userId = read('userId');

    if (userId == null) {
      showToast(message: "User not authenticated", isSuccess: false);
      return;
    }

    try {
      // 1. Update existing futsal_venues row by venueId
      await supabase
          .from('futsal_venues')
          .update(futsalVenues)
          .eq('id', venueId);

      // 2. Delete pitches that were removed in the UI
      if (deletedPitchIds.isNotEmpty) {
        await supabase
            .from('futsal_grounds')
            .delete()
            .inFilter('id', deletedPitchIds);
      }

      // 3. Separate new pitches from existing ones
      List<Map<String, dynamic>> existingPitches = [];
      List<Map<String, dynamic>> newPitches = [];

      for (var ground in futsalGround) {
        final Map<String, dynamic> groundMap = {
          ...ground,
          'venue_id': venueId,
        };

        // If 'id' is null, empty, or doesn't exist, it's a brand new pitch
        if (groundMap['id'] == null || (groundMap['id'] as String).isEmpty) {
          groundMap.remove('id'); // Remove so PostgreSQL generates a new UUID
          newPitches.add(groundMap);
        } else {
          existingPitches.add(groundMap);
        }
      }

      // 4. Perform Insert for brand new pitches
      if (newPitches.isNotEmpty) {
        await supabase.from('futsal_grounds').insert(newPitches);
      }

      // 5. Perform Upsert/Update only for existing pitches that have valid IDs
      if (existingPitches.isNotEmpty) {
        await supabase.from('futsal_grounds').upsert(existingPitches);
      }

      showToast(message: "Venue and pitches updated successfully!", isSuccess: true);
    } catch (e) {
      showToast(message: "Failed to update data: $e", isSuccess: false);
    }
  }

  Future<Map<String, dynamic>?> fetchVenueAndPitchesByOwner() async {
    final userId = read('userId');
    if (userId == null) return null;

    isLoadingData.value = true;

    try {
      final venueRes = await supabase
          .from('futsal_venues')
          .select('*')
          .eq('owner_id', userId)
          .maybeSingle();

      if (venueRes == null) return null;

      final int venueId = venueRes['id'];

      final groundsRes = await supabase
          .from('futsal_grounds')
          .select('*')
          .eq('venue_id', venueId);

      return {
        'venue': venueRes,
        'grounds': groundsRes as List<dynamic>,
      };
    } catch (e) {
      showToast(message: "Failed to fetch data: $e", isSuccess: false);
      return null;
    } finally {
      isLoadingData.value = false;
    }
  }

  Future<void> saveOperatingRules({
    required int venueId,
    required List<Map<String, dynamic>> operatingHours,
    required Map<String, dynamic> venueSettings,
  }) async {
    try {
      isLoadingData.value = true;

      await supabase
          .from('operating_hours')
          .delete()
          .eq('venue_id', venueId);

      await supabase
          .from('operating_hours')
          .insert(operatingHours);

      await supabase
          .from('futsal_venues')
          .update(venueSettings)
          .eq('id', venueId);

      showToast(message: 'Operating rules saved successfully!', isSuccess: true);
    } catch (e) {
      showToast(message: 'Failed to save settings: ${e.toString()}', isSuccess: false);
    } finally {
      isLoadingData.value = false;
    }
  }

  Future<Map<String, dynamic>?> fetchOperatingRules(int venueId) async {
    try {
      isLoadingData.value = true;

      final venueRes = await supabase
          .from('futsal_venues')
          .select('slot_duration_mins, buffer_time_mins, is_peak_enabled, peak_start_time, peak_end_time, peak_rate')
          .eq('id', venueId)
          .maybeSingle();

      final hoursRes = await supabase
          .from('operating_hours')
          .select('*')
          .eq('venue_id', venueId)
          .order('day_of_week', ascending: true);

      return {
        'venue': venueRes,
        'hours': hoursRes,
      };
    } catch (e) {
      debugPrint('Error fetching operating rules: $e');
      return null;
    } finally {
      isLoadingData.value = false;
    }
  }

  Future<void> fetchPendingBookings(int venueId) async {
    isLoadingPending.value = true;
    try {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await supabase
          .from('bookings')
          .select('*, users(full_name, phone_number, profile_pic)')
          .eq('venue_id', venueId)
          .eq('status', 'pending')
          .eq('is_deleted', false)
          .gte('booking_date', todayStr)
          .order('booking_date', ascending: true)
          .order('start_time', ascending: true);

      pendingBookings.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch pending bookings: $e');
    } finally {
      isLoadingPending.value = false;
    }
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus, {String? groundId, String? dateStr}) async {
    try {
      await supabase
          .from('bookings')
          .update({'status': newStatus})
          .eq('id', bookingId);

      pendingBookings.removeWhere((booking) => booking['id'] == bookingId);

      if (groundId != null && dateStr != null) {
        fetchGroundTimelineBookings(groundId: groundId, dateStr: dateStr);
      }

      Get.snackbar(
        'Success', 
        'Booking $newStatus successfully',
        backgroundColor: newStatus == 'booked' ? const Color(0xFF3C4B35) : const Color(0xFF93000A),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update booking: $e');
    }
  }

  Future<void> fetchVenueGrounds(int venueId) async {
    isLoadingGrounds.value = true;
    try {
      final response = await supabase
          .from('futsal_grounds')
          .select('*')
          .eq('venue_id', venueId);

      venueGrounds.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch grounds: $e');
    } finally {
      isLoadingGrounds.value = false;
    }
  }

  Future<void> fetchGroundTimelineBookings({
    required String groundId,
    required String dateStr,
  }) async {
    isLoadingTimeline.value = true;
    try {
      final response = await supabase
          .from('bookings')
          .select('*, users(full_name, phone_number)')
          .eq('ground_id', groundId)
          .eq('booking_date', dateStr)
          .eq('is_deleted', false);

      groundBookings.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load timeline: $e');
    } finally {
      isLoadingTimeline.value = false;
    }
  }

  Future<void> createManualBooking({
    required int venueId,
    required String groundId,
    required String groundName,
    required String teamName,
    required String phoneNumber,
    required String venueName,
    required String bookingType,
    required DateTime bookingDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required double totalPrice,
  }) async {
    try {
      isLoadingData.value = true;

      final dateFormatted = DateFormat('yyyy-MM-dd').format(bookingDate);
      final startTimeFormatted = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00';
      final endTimeFormatted = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00';

      final Map<String, dynamic> bookingData = {
        'venue_id'    : venueId,
        'venue_name'  : venueName,
        'ground_id'   : groundId,
        'ground_name' : groundName,
        'booking_date': dateFormatted,
        'start_time'  : startTimeFormatted,
        'end_time'    : endTimeFormatted,
        'status'      : 'booked',
        'booking_type': bookingType,
        'team_name'   : teamName,
        'phone_number': phoneNumber,
        'total_price' : totalPrice,
        'user_id'     : read('userId')
      };

      await supabase.from('bookings').insert(bookingData);
      //refresh time line
      fetchGroundTimelineBookings(groundId: groundId, dateStr: dateFormatted);

      Get.back();
      showToast(message: 'Slot reserved successfully for $teamName', isSuccess: true);
    } catch (e) {
      showToast(message: 'Failed to create manual booking: $e', isSuccess: false);
    } finally {
      isLoadingData.value = false;
    }
  }
}