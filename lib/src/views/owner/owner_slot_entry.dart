import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/owner_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';
import 'package:futsal_dai/src/widgets/custom_datetime_picker.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OwnerMaunualSlotEntry extends StatefulWidget {
  final int venueId;
  final String venueName;
  final List<Map<String, dynamic>> venueGrounds;
  final String? initialGroundId;
  final String? initialGroundName;
  final String? initialTimeSlot;
  final double basePrice;
  final double peakRate;
  final bool isPeakEnabled;
  final String? peakStartTime;
  final String? peakEndTime;
  final double groundModifier;

  const OwnerMaunualSlotEntry({
    super.key,
    required this.venueId,
    required this.venueName,
    required this.venueGrounds,
    this.initialGroundId,
    this.initialGroundName,
    this.initialTimeSlot,
    this.basePrice = 1500.0,
    this.peakRate = 0.0,
    this.isPeakEnabled = false,
    this.peakStartTime,
    this.peakEndTime,
    this.groundModifier = 0.0,
  });

  @override
  State<OwnerMaunualSlotEntry> createState() => _OwnerMaunualSlotEntryState();
}

class _OwnerMaunualSlotEntryState extends State<OwnerMaunualSlotEntry> {
  final OwnerController ownerCon = Get.find<OwnerController>();
  final formKey = GlobalKey<FormState>();

  late final TextEditingController priceController;
  String? selectedGroundId;
  
  final courtSel = TextEditingController();
  final teamName = TextEditingController();
  final phNum    = TextEditingController();

  // State for booking type selection ('manual_walk_in' or 'by_phone_call')
  String selectedBookingType = 'manual_walk_in';

  late DateTime selectedDateTime;
  DateTime get endTime => selectedDateTime.add(const Duration(hours: 1));

  double calculateSlotPrice() {
    double price = widget.basePrice + widget.groundModifier;

    if (widget.isPeakEnabled && widget.peakStartTime != null && widget.peakEndTime != null) {
      try {
        final slotTime = TimeOfDay.fromDateTime(selectedDateTime);
        
        final startParts = widget.peakStartTime!.split(':');
        final endParts = widget.peakEndTime!.split(':');
        
        final peakStart = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
        final peakEnd = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));

        int slotMins = slotTime.hour * 60 + slotTime.minute;
        int startMins = peakStart.hour * 60 + peakStart.minute;
        int endMins = peakEnd.hour * 60 + peakEnd.minute;

        bool isPeak = slotMins >= startMins && slotMins < endMins;
        if (isPeak && widget.peakRate > 0) {
          price = widget.peakRate + widget.groundModifier;
        }
      } catch (e) {
        debugPrint('Error calculating peak price: $e');
      }
    }
    return price;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    if (widget.initialTimeSlot != null && widget.initialTimeSlot!.isNotEmpty) {
      try {
        // Handles full date-time strings passed from the schedule page
        selectedDateTime = DateTime.parse(widget.initialTimeSlot!);
      } catch (_) {
        // Fallback for simple hour formats
        final parts = widget.initialTimeSlot!.split(':');
        final hour = int.parse(parts[0]);
        selectedDateTime = DateTime(now.year, now.month, now.day, hour, 0);
      }
    } else {
      selectedDateTime = DateTime(now.year, now.month, now.day, now.hour + 1, 0);
    }

    if (widget.initialGroundId != null) {
      selectedGroundId = widget.initialGroundId;
      courtSel.text = widget.initialGroundName ?? '';
    } else if (widget.venueGrounds.isNotEmpty) {
      selectedGroundId = widget.venueGrounds[0]['id'].toString();
      courtSel.text = widget.venueGrounds[0]['ground_name'] ?? '';
    }

    double initialCalculatedPrice = calculateSlotPrice();
    priceController = TextEditingController(text: initialCalculatedPrice.toStringAsFixed(0));
  }

  @override
  void dispose() {
    courtSel.dispose();
    teamName.dispose();
    phNum.dispose();
    priceController.dispose();
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
      appBar: appBarWidget(title: 'Add Entry'),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(8.sp),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 8.h),
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

  Widget entrySlot() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: black.withValues(alpha: 0.01),
            border: Border.all(
              color: white.withValues(alpha: 0.08),
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
                
                // BOOKING TYPE SELECTION DROPDOWN/CHIPS
                Text(
                  'BOOKING TYPE',
                  style: boldStyle(subtitleTextColor, 12.sp),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: bookingTypeButton(
                        label: 'Manual Walk-In',
                        value: 'manual_walk_in',
                        icon: Icons.directions_walk,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: bookingTypeButton(
                        label: 'Booked by Call',
                        value: 'by_phone_call',
                        icon: Icons.phone_callback_rounded,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

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
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: primaryColor,
                              width: 0.5,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
                          child: Text(
                            'EDIT',
                            style: boldStyle(primaryColor, 12.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                
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
                
                CustomTextFormField(
                  headingText: "PHONE NUMBER",
                  headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
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

                CustomTextFormField(
                  headingText: "TOTAL PRICE (NPR)",
                  headingTextStyle: boldStyle(subtitleTextColor, 12.sp),
                  keyboardType: TextInputType.number,
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  controller: priceController,
                  maxLines: 1,
                  filledColor: lightFilledBgColor,
                  validator: (val) {
                    if (val == null || double.tryParse(val) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                
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

  // Widget helper for switching booking type options nicely
  Widget bookingTypeButton({required String label, required String value, required IconData icon}) {
    final bool isSelected = selectedBookingType == value;

    return InkWell(
      onTap: () => setState(() => selectedBookingType = value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.2) : lightFilledBgColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? primaryColor : subtitleTextColor, size: 18.sp),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                style: boldStyle(isSelected ? whiteTextColor : subtitleTextColor, 11.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSelectDateTime() async {
    final DateTime? result = await DateTimePickerHelper.pickDateTime(
      context: context,
      initialDateTime: selectedDateTime,
    );

    if (result != null) {
      setState(() {
        selectedDateTime = result;
        priceController.text = calculateSlotPrice().toStringAsFixed(0);
      });
    }
  }

  void _showCourtPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: lightFilledBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.venueGrounds.map((ground) {
              final String name = ground['ground_name'] ?? 'Pitch';
              final String type = ground['ground_type'] ?? '';
              return ListTile(
                title: Text('$name ($type)', style: boldStyle(whiteTextColor, 16.sp)),
                onTap: () {
                  setState(() {
                    selectedGroundId = ground['id'].toString();
                    courtSel.text = name;
                    
                    double modifier = double.tryParse(ground['price_modifier']?.toString() ?? '0.0') ?? 0.0;
                    double base = calculateSlotPrice() - widget.groundModifier + modifier;
                    priceController.text = base.toStringAsFixed(0);
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

  Future<void> _submitForm() async {
    if (formKey.currentState!.validate()) {
      if (selectedGroundId == null) {
        Get.snackbar('Error', 'Please select a court/pitch', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      double finalPrice = double.tryParse(priceController.text.trim()) ?? calculateSlotPrice();
      // String venueName = widget.initialGroundName ?? widget.venueGrounds.firstWhere((g) => g['id'].toString() == selectedGroundId, orElse: () => {'ground_name': 'Venue'})['ground_name'];

      await ownerCon.createManualBooking(
        venueId    : widget.venueId,
        venueName  : widget.venueName,
        groundId   : selectedGroundId!,
        groundName : widget.initialGroundName!,
        teamName   : teamName.text.trim(),
        phoneNumber: phNum.text.trim(),
        bookingDate: selectedDateTime,
        startTime  : TimeOfDay.fromDateTime(selectedDateTime),
        endTime    : TimeOfDay.fromDateTime(endTime),
        totalPrice : finalPrice,
        bookingType: selectedBookingType
      );
    }
  }
}