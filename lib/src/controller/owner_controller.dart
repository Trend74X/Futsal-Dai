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
      // 1. Insert into futsal_venues
      final venueResponse = await supabase
          .from('futsal_venues')
          .insert(futsalVenues)
          .select('id')
          .single();
      final int venueId = venueResponse['id'];
      write('venueId', venueResponse['id']);

      // 2. Attach the created venue_id to each ground object
      final List<Map<String, dynamic>> groundsData = futsalGround.map((ground) {
        return {
          ...ground,
          'venue_id': venueId,
        };
      }).toList();

      // 3. Insert all pitches into futsal_grounds
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
    final supabase = Supabase.instance.client;
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

      // 3. Attach venue_id to grounds payload
      final List<Map<String, dynamic>> groundsData = futsalGround.map((ground) {
        return {
          ...ground,
          'venue_id': venueId,
        };
      }).toList();

      // 4. Upsert pitches (Updates existing grounds with matching 'id', inserts new ones)
      await supabase.from('futsal_grounds').upsert(groundsData);

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
      final supabase = Supabase.instance.client;

      // 1. Get Venue by owner_id
      final venueRes = await supabase
          .from('futsal_venues')
          .select('*')
          .eq('owner_id', userId)
          .maybeSingle();

      if (venueRes == null) return null;

      final int venueId = venueRes['id'];

      // 2. Fetch Pitches by venue_id
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

      // 1. Clear previous operating hours for this venue to prevent duplicate records
      await supabase
          .from('operating_hours')
          .delete()
          .eq('venue_id', venueId);

      // 2. Insert new operating hours schedule
      await supabase
          .from('operating_hours')
          .insert(operatingHours);

      // 3. Update global settings in futsal_venues table
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

  /// Optional: Fetch existing hours for a venue when opening the screen
  Future<Map<String, dynamic>?> fetchOperatingRules(int venueId) async {
    try {
      isLoadingData.value = true;

      // Fetch venue settings (slot duration, buffer, peak hours)
      final venueRes = await supabase
          .from('futsal_venues')
          .select('slot_duration_mins, buffer_time_mins, is_peak_enabled, peak_start_time, peak_end_time, peak_rate')
          .eq('id', venueId)
          .maybeSingle();

      // Fetch weekly operating hours
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

  // Fetch Pending Bookings
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

  // Helper method to update DB and UI
  Future<void> updateBookingStatus(String bookingId, String newStatus, {String? groundId, String? dateStr}) async {
    try {
      // 1. Update Supabase
      await supabase
          .from('bookings')
          .update({'status': newStatus})
          .eq('id', bookingId);

      // 2. Remove the booking from the local UI list immediately so it disappears from the queue
      pendingBookings.removeWhere((booking) => booking['id'] == bookingId);

      // 3. If groundId and date are provided, refresh the timeline automatically
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

  // Fetch grounds belonging to this venue
  Future<void> fetchVenueGrounds(int venueId) async {
    isLoadingGrounds.value = true;
    try {
      final response = await supabase
          .from('futsal_grounds')
          .select('id, ground_name, ground_type, format')
          .eq('venue_id', venueId);

      venueGrounds.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch grounds: $e');
    } finally {
      isLoadingGrounds.value = false;
    }
  }

  // Fetch bookings for a specific ground and date to populate the timeline
  Future<void> fetchGroundTimelineBookings({
    required String groundId,
    required String dateStr, // Format: 'yyyy-MM-dd'
  }) async {
    isLoadingTimeline.value = true;
    try {
      final response = await supabase
          .from('bookings')
          .select('*, users(full_name, phone_number)')
          .eq('ground_id', groundId) // Strictly targets the selected pitch UUID
          .eq('booking_date', dateStr)
          .eq('is_deleted', false);

      groundBookings.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load timeline: $e');
    } finally {
      isLoadingTimeline.value = false;
    }
  }

}