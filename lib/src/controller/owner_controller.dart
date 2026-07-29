import 'package:futsal_dai/src/helper/cache_manager.dart';
import 'package:futsal_dai/src/widgets/custom_toast.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerController extends GetxController {
  final supabase = Supabase.instance.client; 
  RxBool isLoadingData = false.obs;

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
      Get.snackbar("Error", "Failed to fetch data: $e");
      return null;
    } finally {
      isLoadingData.value = false;
    }
  }

}