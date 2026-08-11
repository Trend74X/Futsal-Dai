import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:get/get.dart';

// Future<dynamic> customAlertDialog() {
//   return Get.defaultDialog(
//     title: "Delete Member",
//     middleText: "Are you sure you want to remove this member from the group?",
//     backgroundColor: filledBgColor,
//     titleStyle: boldStyle(whiteTextColor, 18.sp),
//     middleTextStyle: semiBoldStyle(whiteTextColor, 14.sp),
//     textConfirm: "Confirm",
//     textCancel: "Cancel",
//     confirmTextColor: black,
//     cancelTextColor: whiteTextColor,
//     buttonColor: primaryColor,
//     onConfirm: () {
//       print("Member deleted!");
//       Get.back(); 
//     },
//     onCancel: () => Get.back()
//   );
// }

Future<dynamic> customAlertDialog({
  required String title,
  required String content,
  required String confirmText,
  String? cancelText,
  required VoidCallback confirmAction
}) {
  return Get.dialog(
    AlertDialog(
      backgroundColor: filledBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: title == ''
              ? null
              : Center(
                child: Text(
                  title,
                  style: boldStyle(primaryTextColor, 18.sp),
                ),
              ),
      content: Text(
        content,
        style: semiBoldStyle(whiteTextColor, 14.sp).copyWith(height: 1.2),
        textAlign: .start,
      ),
      actions: [
        // Confirm
        InkWell(
          onTap: () {
            Get.back();
            confirmAction();
          },
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: .circular(8.r)
            ),
            padding: .symmetric(vertical: 8.h, horizontal: 12.w),
            child: Text(
              confirmText,
              style: boldStyle(black, 14.sp),
            ),
          ),
        ),
        // Cancel
        if(cancelText != null)
          InkWell(
            onTap: () => Get.back(),
            child: Container(
              decoration: BoxDecoration(
                color: transparent,
                borderRadius: .circular(8.r),
                border: .all(color: primaryColor)
              ),
              padding: .symmetric(vertical: 8.h, horizontal: 12.w),
              child: Text(
                cancelText,
                style: boldStyle(primaryColor, 14.sp),
              ),
            ),
          ),
      ],
    ),
  );
}