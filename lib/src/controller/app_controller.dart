import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppController extends GetxController {

  final Rx<PackageInfo?> _packageInfo = Rx<PackageInfo?>(null);
  PackageInfo? get packageInfo => _packageInfo.value;

  final RxString appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAppVersion();
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

}