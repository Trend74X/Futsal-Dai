import 'dart:convert';
import 'dart:developer';

import 'package:futsal_dai/src/model/amenities_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppController extends GetxController {

  final supabase = Supabase.instance.client;
  final Rx<PackageInfo?> _packageInfo = Rx<PackageInfo?>(null);
  PackageInfo? get packageInfo => _packageInfo.value;

  final RxString appVersion = ''.obs;

  List<AmenityModel> amenitiesList = [];
  RxBool isLoadingAmenities = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAppVersion();
    fetchAmenitiesFromSupabase();
  }

  Future<void> loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _packageInfo.value = info;
      appVersion.value = 'App Version ${info.version} (Build ${info.buildNumber})';
    } catch (e) {
      appVersion.value = 'App Version unavailable';
    }
  }

  Future<void> fetchAmenitiesFromSupabase() async {
    try {
      isLoadingAmenities(true);
      final response = await Supabase.instance.client
          .from('option_sub_masters')
          .select('id, label, icon_name, option_masters!inner(name)')
          .eq('option_masters.name', 'Amenities');

      amenitiesList = (response as List)
          .map((item) => AmenityModel.fromJson(item))
          .toList();
      isLoadingAmenities(false);
    } catch (e) {
      isLoadingAmenities(false);
      log('Error fetching amenities: $e');
    }
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      // Nominatim Reverse Geocoding API
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1');

      final response = await http.get(url, headers: {
        'User-Agent': 'com.example.futsal_dai',
        'Accept-Language': 'en'
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['display_name'] != null) {
          String streetAddress =  "${data['address']['name'] ?? data['address']['amenity'] ?? data['address']['road'] ?? ''}, ${data['address']['city'] ?? data['address']['town'] ?? data['address']['village'] ?? ''}, ${data['address']['state'] ?? ''}"
                  .replaceAll(RegExp(r'^, |, $'), '')
                  .replaceAll(', ,', ',');
          log('address :');
          log(streetAddress);
          return streetAddress;
        }
      } else {
        log("Failed to fetch address");
      }
      return '';
    } catch (e) {
      log("Error fetching address: $e");
      return '';
    }
  }

}