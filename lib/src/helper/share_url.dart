import 'package:flutter/material.dart';
import 'package:futsal_dai/src/widgets/custom_toast.dart';
import 'package:share_plus/share_plus.dart';

void shareContent(BuildContext context) async {
  final String textToShare = 'Hey! Check out this amazing futsal ground: https://google.com';
  
  // Using SharePlus.instance.share for modern versions of the package
  final result = await SharePlus.instance.share(
    ShareParams(
      text: textToShare,
      subject: 'Check this out from Futsal Dai!', // Used mostly if the user shares to Email
    ),
  );

  if (result.status == ShareResultStatus.success) {
    showToast(message: 'Thank you for sharing.', isSuccess: true);
  }
}