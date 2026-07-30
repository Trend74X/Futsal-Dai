import 'dart:developer';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

Future<void> makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    log('Could not launch dialer for $phoneNumber');
  }
}

void launchMapDirections({required double latitude, required double longitude}) async {
    // final double destLat = 27.68529949056445;
    // final double destLng = 85.30584563183453;
    
    Uri mapUri;

    if (Platform.isAndroid) {
      mapUri = Uri.parse('google.navigation:q=$latitude,$longitude&mode=d');
    } else if (Platform.isIOS) {
      mapUri = Uri.parse('http://maps.apple.com/?saddr=Current%20Location&daddr=$latitude,$longitude');
    } else {
      // Fallback fallback URL for Web/Desktop
      mapUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');
    }

    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch map intent: $mapUri';
    }
  }