import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:get/get.dart';

SnackbarController showToast({String? message, bool? isSuccess, bool? isEn, duration, isNotDissmiable}) {
  //bottom height
  var bottomHeight = WidgetsBinding.instance.platformDispatcher.views.first.padding.bottom;

  // Check for iPhones with a notch (iPhone X, 12, 13, 14, 15 Pro, etc.)
  bool isNotchediPhone = Platform.isIOS && bottomHeight > 20;

  // Use different margins based on the device
  double marginBottom = 108.h;
  
  if (isNotchediPhone) {
    marginBottom = 76.h;  // Adjust for iPhones with notch
  } else if (Platform.isAndroid && bottomHeight > 0) {
    marginBottom = 94.h;  // Adjust for Android with gesture navigation
  }

  return Get.snackbar(
    "",
    "",
    colorText: isSuccess == true ? black : white,
    backgroundColor: isSuccess == true ? white : redCompulsory,
    borderWidth: 0,
    margin: EdgeInsets.fromLTRB(16.sp, 0, 16.sp, marginBottom), // Adjust margin bottom for iPhones with a notch
    duration: duration ?? const Duration(seconds: 3),
    borderRadius: 8.0.r,
    messageText: const SizedBox.shrink(),
    snackPosition: SnackPosition.BOTTOM,
    padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
    dismissDirection: isNotDissmiable == true ? DismissDirection.none : null,
    // isDismissible: false,
    titleText: Padding(
      padding: EdgeInsets.only(top: 1.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: isEn == true ? 4.sp : 1.5.sp),
              child: Text(
                message.toString(),
                style: TextStyle(fontSize: 13.sp, color: isSuccess == true ? black : white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}