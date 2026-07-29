import 'dart:developer';

import 'package:futsal_dai/src/model/amenities_model.dart';
import 'package:get/get.dart';
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

}