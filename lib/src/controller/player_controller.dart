import 'dart:developer';

import 'package:futsal_dai/src/model/futsal_venue_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerController extends GetxController {
  final supabase = Supabase.instance.client; 
  
  RxBool isLoadingNearByData = false.obs;

  List nearbyVenues = [].obs;

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

      nearbyVenues = (response as List)
        .map((item) => FutsalVenueModel.fromJson(item as Map<String, dynamic>))
        .toList();
      log(nearbyVenues.toString());
      isLoadingNearByData(false);
    } catch (e) {
      isLoadingNearByData(false);
      log('Error fetching amenities: $e');
    }
  }

}