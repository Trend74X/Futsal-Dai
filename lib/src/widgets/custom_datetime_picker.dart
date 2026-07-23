import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
// Import your app's color constants and text styles here
// import 'path/to/colors.dart';

class DateTimePickerHelper {
  static Future<DateTime?> pickDateTime({
    required BuildContext context,
    required DateTime initialDateTime,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    // Theme Builder
    Widget buildPickerTheme(BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: primaryColor, // Header background & selected circle
            onPrimary: Colors.black, // Text color inside selected circle
            surface: lightFilledBgColor, // Dialog background color
            onSurface: whiteTextColor, // Normal text color
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              textStyle: boldStyle(primaryColor, 14.sp),
            ),
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: lightFilledBgColor,
            hourMinuteColor: primaryColor.withValues(alpha: 0.1),
            hourMinuteTextColor: whiteTextColor,
            dialBackgroundColor: Colors.black26,
            dialHandColor: primaryColor,
            dialTextColor: whiteTextColor,
            entryModeIconColor: primaryColor,
          ),
          dialogTheme: DialogThemeData(backgroundColor: lightFilledBgColor),
        ),
        child: child!,
      );
    }

    // 1. Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
      builder: buildPickerTheme,
    );

    if (pickedDate == null) return null;
    if (!context.mounted) return null;

    // 2. Pick Start Time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
      builder: buildPickerTheme,
    );

    if (pickedTime == null) return null;

    // Return combined DateTime
    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }
}