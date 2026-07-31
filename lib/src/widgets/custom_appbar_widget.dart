import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:get/get.dart';

AppBar appBarWidget({required String title, dynamic action}) {
  return AppBar(
    backgroundColor: transparent,
    title: Text(title, style: boldStyle(primaryTextColor, 24.sp)),
    centerTitle: true,
    surfaceTintColor: transparent,
    leading: IconButton(
      onPressed: () => Get.back(),
      icon: Icon(Icons.arrow_back_ios_new, color: subtitleTextColor),
    ),
    actions: action != null 
      ?[ action, SizedBox(width: 16.w) ]
      : null,
  );
}