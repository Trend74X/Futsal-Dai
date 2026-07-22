import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OwnserMaunualSlotEntry extends StatefulWidget {
  const OwnserMaunualSlotEntry({super.key});

  @override
  State<OwnserMaunualSlotEntry> createState() => _OwnserMaunualSlotEntryState();
}

class _OwnserMaunualSlotEntryState extends State<OwnserMaunualSlotEntry> {

  final formKey = GlobalKey<FormState>();

  //Text Controllers
  final courtSel = TextEditingController();
  final teamName = TextEditingController();
  final phNum    = TextEditingController();

  String selectedMethod = 'cash';

  late DateTime startTime;
  DateTime get endTime => startTime.add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startTime = DateTime(now.year, now.month, now.day, now.hour + 1, 0);
  }

  String get formattedDateTime {
    final now = DateTime.now();
    final isToday = startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;

    final datePrefix = isToday ? 'Today' : DateFormat('EEE, MMM d').format(startTime);
    final startFormatted = DateFormat('h:mm a').format(startTime);
    final endFormatted = DateFormat('h:mm a').format(endTime);

    return '$datePrefix, $startFormatted - $endFormatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            child: Padding(
              padding: .symmetric(horizontal: 16.sp, vertical: 8.h),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    appbarWidget(),
                    SizedBox(height: 16.h),
                    entrySlot()
                  ],
                )
              )
            )
          )
        )
      )
    );
  }

  Widget appbarWidget() {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, color: subtitleTextColor),
        ),
        Text('Add Entry', style: boldStyle(primaryTextColor, 28.sp)),
        SizedBox(width: 1),
      ],
    );
  }

  Widget entrySlot() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black.withValues(alpha: 0.01), 
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08), 
              width: 1.0,
            ),
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  'Manual Slot Entry',
                  style: boldStyle(whiteTextColor, 28.sp),
                ),
                Text(
                  'Reserve slot for walk-in players or phone bookings',
                  style: regularStyle(subtitleTextColor, 16.sp).copyWith(height: 1.2),
                ),
                SizedBox(height: 16.h),
                CustomTextFormField(
                  headingText: "COURT SELECTION",
                  headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
                  textInputAction: .next,
                  autoValidateMode: .onUserInteraction,
                  controller: courtSel,
                  readOnly: true,
                  maxLines: 1,
                  hintText: 'Pitch A',
                  hintStyle: regularStyle(subtitleTextColor.withValues(alpha: 0.6), 16.sp),
                  filledColor: lightFilledBgColor,
                  onChanged: (value){
                    setState(() {});
                  },
                ),
                SizedBox(height: 16.h),
                Text(
                  'TIME & DATE',
                  style: boldStyle(subtitleTextColor, 12.sp),
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: lightFilledBgColor,
                    borderRadius: .circular(8.r)
                  ),
                  padding: .all(16.sp),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: primaryColor, size: 20.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          formattedDateTime, // Displays: "Today, 6:00 PM - 7:00 PM"
                          style: boldStyle(whiteTextColor, 16.sp),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      InkWell(
                        onTap: selectDateTime,
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryTextColor.withValues(alpha: 0.1),
                            borderRadius: .circular(10.r),
                            border: .all(
                              color: primaryTextColor,
                              width: 0.5
                            )
                          ),
                          padding: .symmetric(vertical: 4.h, horizontal: 12.w),
                          child: Text(
                            'EDIT',
                            style: boldStyle(primaryTextColor, 12.sp),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                CustomTextFormField(
                  headingText: "PLAYER/TEAM NAME",
                  headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
                  textInputAction: .next,
                  keyboardType: .text,
                  autoValidateMode: .onUserInteraction,
                  controller: teamName,
                  maxLines: 1,
                  hintText: 'Urban Striker FC',
                  hintStyle: regularStyle(subtitleTextColor.withValues(alpha: 0.6), 16.sp),
                  filledColor: lightFilledBgColor,
                  onChanged: (value){
                    setState(() {});
                  },
                ),
                SizedBox(height: 16.h),
                CustomTextFormField(
                  headingText: "PHONE NUMBER",
                  headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
                  textInputAction: .next,
                  keyboardType: .phone,
                  autoValidateMode: .onUserInteraction,
                  controller: phNum,
                  maxLines: 1,
                  hintText: '9801234567',
                  filledColor: lightFilledBgColor,
                  hintStyle: regularStyle(subtitleTextColor.withValues(alpha: 0.6), 16.sp),
                  onChanged: (value){
                    setState(() {});
                  },
                ),
                SizedBox(height: 16.h),
                Text(
                  'PAYMENT STATUS',
                  style: boldStyle(subtitleTextColor, 12.sp),
                ),
                SizedBox(height: 8.h),
                paymentStatusTile(icon: 'assets/icons/cash.svg', label: 'Cash Paid at Venue', method: 'cash'),
                SizedBox(height: 8.h),
                paymentStatusTile(icon: 'assets/icons/advance.svg', label: 'Advance Deposit Paid', method: 'advance'),
                SizedBox(height: 8.h),
                paymentStatusTile(icon: 'assets/icons/unpaid.svg', label: 'Unpaid / Pay After Match', method: 'unpaid'),
                SizedBox(height: 24.h),
                CustomUsualButton(
                  text: 'Confirm & Book Slot',
                  // style: boldStyle(Color(0xFF053900), 28.sp),
                  fontColor: Color(0xFF053900),
                  fontSize: 20.sp,
                  fontWeight: .bold,
                  onPressed: () {}
                ),
                SizedBox(height: 16.h),
                Center(
                  child: Text(
                    'ACTION CANNOT BE UNDONE ONCE CONFIRMED',
                    style: regularStyle(subtitleTextColor, 10.sp),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget paymentStatusTile({
    required String icon,
    required String label,
    required String method
  }) {
    return InkWell(
      onTap: () => setState(() => selectedMethod = method),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: .circular(12.r),
          border: .all(
            color: selectedMethod == method ? primaryColor : whiteTextColor.withValues(alpha: 0.5),
            width: 0.5.sp
          )
        ),
        padding: .symmetric(vertical: 16.h, horizontal: 16.w),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 16.w,
              height: 16.h,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(selectedMethod == method ? primaryColor : white, BlendMode.srcIn),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: regularStyle(whiteTextColor, 16.sp),
            ),
            Spacer(),
            Container(
              height: 20.h,
              width: 20.w,
              decoration: BoxDecoration(
                shape: .circle,
                color: selectedMethod == method ? primaryColor : transparent,
                border: .all(
                  color: selectedMethod == method ? primaryColor : whiteTextColor
                )
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> selectDateTime() async {
    Widget buildPickerTheme(BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: primaryColor,            // Header background & selected circle color (Neon Green)
            onPrimary: Colors.black,          // Text color inside selected circle
            surface: lightFilledBgColor,      // Dialog background color
            onSurface: whiteTextColor,        // Normal text color
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,  // 'OK' & 'CANCEL' button colors
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
          ), dialogTheme: DialogThemeData(backgroundColor: lightFilledBgColor),
        ),
        child: child!,
      );
    }

    // 1. Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: buildPickerTheme, // Applies your dark green theme
    );

    if (pickedDate == null) return;

    if (!mounted) return;

    // 2. Pick Start Time
    final TimeOfDay? pickedStartTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(startTime),
      builder: buildPickerTheme, // Applies your dark green theme
    );

    if (pickedStartTime == null) return;

    setState(() {
      startTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedStartTime.hour,
        pickedStartTime.minute,
      );
    });
  }
  
}