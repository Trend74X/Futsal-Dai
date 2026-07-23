import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/widgets/custom_datetime_picker.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Ensure this path matches your project structure for DateTimePickerHelper
// import 'package:futsal_dai/src/helper/date_time_picker_helper.dart';

class OwnserMaunualSlotEntry extends StatefulWidget {
  const OwnserMaunualSlotEntry({super.key});

  @override
  State<OwnserMaunualSlotEntry> createState() => _OwnserMaunualSlotEntryState();
}

class _OwnserMaunualSlotEntryState extends State<OwnserMaunualSlotEntry> {
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final courtSel = TextEditingController(text: 'Pitch A');
  final teamName = TextEditingController();
  final phNum = TextEditingController();

  String selectedMethod = 'cash';

  // Connected DateTime Variables
  late DateTime selectedDateTime;
  DateTime get endTime => selectedDateTime.add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDateTime = DateTime(now.year, now.month, now.day, now.hour + 1, 0);
  }

  @override
  void dispose() {
    courtSel.dispose();
    teamName.dispose();
    phNum.dispose();
    super.dispose();
  }

  String get formattedDateTime {
    final now = DateTime.now();
    final isToday = selectedDateTime.year == now.year &&
        selectedDateTime.month == now.month &&
        selectedDateTime.day == now.day;

    final datePrefix = isToday ? 'Today' : DateFormat('EEE, MMM d').format(selectedDateTime);
    final startFormatted = DateFormat('h:mm a').format(selectedDateTime);
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
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.h),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    appbarWidget(),
                    SizedBox(height: 16.h),
                    entrySlot(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget appbarWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, color: subtitleTextColor),
        ),
        Text('Add Entry', style: boldStyle(primaryTextColor, 28.sp)),
        const SizedBox(width: 40), // Balanced spacing for back icon
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                
                // Court Selection (Tapping triggers picker bottom sheet)
                GestureDetector(
                  onTap: _showCourtPicker,
                  child: AbsorbPointer(
                    child: CustomTextFormField(
                      headingText: "COURT SELECTION",
                      headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
                      textInputAction: TextInputAction.next,
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      controller: courtSel,
                      readOnly: true,
                      maxLines: 1,
                      hintText: 'Select Pitch',
                      hintStyle: regularStyle(subtitleTextColor.withValues(alpha: 0.6), 16.sp),
                      filledColor: lightFilledBgColor,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Time & Date Card
                Text(
                  'TIME & DATE',
                  style: boldStyle(subtitleTextColor, 12.sp),
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: lightFilledBgColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.all(16.sp),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: primaryColor, size: 20.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          formattedDateTime,
                          style: boldStyle(whiteTextColor, 16.sp),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      InkWell(
                        onTap: _handleSelectDateTime,
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryTextColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: primaryTextColor,
                              width: 0.5,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
                          child: Text(
                            'EDIT',
                            style: boldStyle(primaryTextColor, 12.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Player / Team Name
                CustomTextFormField(
                  headingText: "PLAYER/TEAM NAME",
                  headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  controller: teamName,
                  maxLines: 1,
                  hintText: 'Urban Striker FC',
                  hintStyle: regularStyle(subtitleTextColor.withValues(alpha: 0.6), 16.sp),
                  filledColor: lightFilledBgColor,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter player or team name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                
                // Phone Number
                CustomTextFormField(
                  headingText: "PHONE NUMBER",
                  keyboardType: TextInputType.phone,
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  controller: phNum,
                  maxLines: 1,
                  hintText: '9801234567',
                  filledColor: lightFilledBgColor,
                  hintStyle: regularStyle(subtitleTextColor.withValues(alpha: 0.6), 16.sp),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                
                // Payment Status Selection
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
                
                // Submit Button
                CustomUsualButton(
                  text: 'Confirm & Book Slot',
                  fontColor: const Color(0xFF053900),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  onPressed: _submitForm,
                ),
                SizedBox(height: 16.h),
                Center(
                  child: Text(
                    'ACTION CANNOT BE UNDONE ONCE CONFIRMED',
                    style: regularStyle(subtitleTextColor, 10.sp),
                  ),
                ),
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
    required String method,
  }) {
    final bool isSelected = selectedMethod == method;

    return InkWell(
      onTap: () => setState(() => selectedMethod = method),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? primaryColor : whiteTextColor.withValues(alpha: 0.5),
            width: 0.5.sp,
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 16.w,
              height: 16.h,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                isSelected ? primaryColor : Colors.white,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: regularStyle(whiteTextColor, 16.sp),
            ),
            const Spacer(),
            Container(
              height: 20.h,
              width: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? primaryColor : whiteTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DateTime Picker Trigger
  void _handleSelectDateTime() async {
    final DateTime? result = await DateTimePickerHelper.pickDateTime(
      context: context,
      initialDateTime: selectedDateTime,
    );

    if (result != null) {
      setState(() {
        selectedDateTime = result;
      });
    }
  }

  // Court Selector BottomSheet Modal
  void _showCourtPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: lightFilledBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        final courts = ['Pitch A (Indoor)', 'Pitch B (Outdoor)', 'Pitch C (5-A-Side)'];
        return Container(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: courts.map((court) {
              return ListTile(
                title: Text(court, style: boldStyle(whiteTextColor, 16.sp)),
                onTap: () {
                  setState(() {
                    courtSel.text = court;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Form Submission
  void _submitForm() {
    if (formKey.currentState!.validate()) {
      // Process manual booking logic
      Get.snackbar(
        'Success',
        'Slot reserved successfully for ${teamName.text}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: primaryColor,
        colorText: Colors.black,
      );
      Get.back();
    }
  }
}