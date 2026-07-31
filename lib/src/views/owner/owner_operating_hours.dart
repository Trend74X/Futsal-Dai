import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/validators.dart';
import 'package:futsal_dai/src/model/day_schedule_model.dart';
import 'package:futsal_dai/src/views/owner/owner_business_hours_widget.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:get/get.dart';

class OwnerOperatingHours extends StatefulWidget {
  final int venueId; // Pass your venue ID here

  const OwnerOperatingHours({super.key, required this.venueId});

  @override
  State<OwnerOperatingHours> createState() => _OwnerOperatingHoursState();
}

class _OwnerOperatingHoursState extends State<OwnerOperatingHours> {
  int selectedDuration = 60;
  String selectedBufferTime = 'none';
  final peakRateCon = TextEditingController();

  List<DaySchedule> individualDays = [
    DaySchedule(dayOfWeek: 0, label: 'Sunday'),
    DaySchedule(dayOfWeek: 1, label: 'Monday'),
    DaySchedule(dayOfWeek: 2, label: 'Tuesday'),
    DaySchedule(dayOfWeek: 3, label: 'Wednesday'),
    DaySchedule(dayOfWeek: 4, label: 'Thursday'),
    DaySchedule(dayOfWeek: 5, label: 'Friday'),
    DaySchedule(dayOfWeek: 6, label: 'Saturday'),
  ];

  DaySchedule peakHourSchedule = DaySchedule(
    dayOfWeek: -1,
    label: 'Peak Hours',
    isEnabled: false,
    startTime: const TimeOfDay(hour: 17, minute: 0),
    endTime: const TimeOfDay(hour: 21, minute: 0),
  );

  @override
  void dispose() {
    peakRateCon.dispose();
    super.dispose();
  }

  // Helper method to convert TimeOfDay into DB 'HH:mm:ss' format
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  // Parse Buffer Time string to integer
  int _getBufferMinutes() {
    if (selectedBufferTime == 'none') return 0;
    return int.tryParse(selectedBufferTime) ?? 0;
  }

  // Handle saving data to backend / controller
  Future<void> _handleSave() async {
    // 1. Validate peak rate input if peak hours are enabled
    if (peakHourSchedule.isEnabled && peakRateCon.text.trim().isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter a peak hourly rate.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // 2. Prepare payload for operating_hours table
    final List<Map<String, dynamic>> operatingHoursData = individualDays.map((day) {
      return {
        'venue_id': widget.venueId,
        'day_of_week': day.dayOfWeek,
        'open_time': _formatTimeOfDay(day.startTime),
        'close_time': _formatTimeOfDay(day.endTime),
        'is_closed': !day.isEnabled,
        'is_peak': false,
        'peak_rate': null,
      };
    }).toList();

    // Append Peak Hour row if enabled
    if (peakHourSchedule.isEnabled) {
      operatingHoursData.add({
        'venue_id': widget.venueId,
        'day_of_week': null, // General peak hour rule
        'open_time': _formatTimeOfDay(peakHourSchedule.startTime),
        'close_time': _formatTimeOfDay(peakHourSchedule.endTime),
        'is_closed': false,
        'is_peak': true,
        'peak_rate': double.tryParse(peakRateCon.text) ?? 0.0,
      });
    }

    // 3. Prepare payload for futsal_venues table
    final Map<String, dynamic> venueSettingsData = {
      'slot_duration_mins': selectedDuration,
      'buffer_time_mins': _getBufferMinutes(),
    };

    // DEBUG LOG: Inspect your payload before network request
    debugPrint('--- Operating Hours Payload ---');
    debugPrint(operatingHoursData.toString());
    debugPrint('--- Venue Settings Payload ---');
    debugPrint(venueSettingsData.toString());

    // Call your Controller method here
    // await ownCon.saveOperatingRules(
    //   venueId: widget.venueId,
    //   hours: operatingHoursData,
    //   settings: venueSettingsData,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appbarWidget(),
                    SizedBox(height: 12.h),
                    headerlabel(
                      label: 'Slot & Duration Rules',
                      icon: Icons.timer_outlined,
                    ),
                    SizedBox(height: 12.h),
                    slotWidget(),
                    SizedBox(height: 24.h),
                    BusinessHoursScreen(
                      individualDays: individualDays,
                      onScheduleChanged: (updatedList) {
                        setState(() {
                          individualDays = updatedList;
                        });
                      },
                    ),
                    SizedBox(height: 24.h),
                    headerlabel(
                      label: 'Peak Hours & Rate Multiplier',
                      icon: Icons.trending_up,
                    ),
                    SizedBox(height: 12.h),
                    peakHoursContainerWidget(),
                    SizedBox(height: 24.h),
                    peakHoursPricingWidget(),
                    SizedBox(height: 24.h),
                    saveOperationRulesWidget(),
                    SizedBox(height: 24.h),
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
        Text('Operating Hours', style: boldStyle(primaryTextColor, 24.sp)),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget headerlabel({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 21.sp,
          color: primaryColor,
        ),
        SizedBox(width: 8.w),
        Text(label, style: semiBoldStyle(whiteTextColor, 20.sp)),
      ],
    );
  }

  Widget slotWidget() {
    return Container(
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEFAULT SLOT DURATION',
            style: boldStyle(subtitleTextColor, 12.sp),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              circularButtonWidget(
                label: '30 Mins',
                isSelected: selectedDuration == 30,
                onTap: () => setState(() => selectedDuration = 30),
              ),
              circularButtonWidget(
                label: '60 Mins',
                isSelected: selectedDuration == 60,
                onTap: () => setState(() => selectedDuration = 60),
              ),
              circularButtonWidget(
                label: '90 Mins',
                isSelected: selectedDuration == 90,
                onTap: () => setState(() => selectedDuration = 90),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'BUFFER TIME BETWEEN MATCHES',
            style: boldStyle(subtitleTextColor, 12.sp),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              circularButtonWidget(
                label: 'None',
                isSelected: selectedBufferTime == 'none',
                onTap: () => setState(() => selectedBufferTime = 'none'),
              ),
              circularButtonWidget(
                label: '5 mins',
                isSelected: selectedBufferTime == '5',
                onTap: () => setState(() => selectedBufferTime = '5'),
              ),
              circularButtonWidget(
                label: '10 mins',
                isSelected: selectedBufferTime == '10',
                onTap: () => setState(() => selectedBufferTime = '10'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget circularButtonWidget({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : lightFilledBgColor,
          borderRadius: BorderRadius.circular(24.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        margin: EdgeInsets.only(right: 8.w),
        child: Text(
          label,
          style: boldStyle(
            isSelected ? const Color(0xFF107100) : whiteTextColor,
            12.sp,
          ),
        ),
      ),
    );
  }

  Widget peakHoursContainerWidget() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3F465C).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(16.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFFADB4CE),
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Charge extra during high-demand hours. Peak rates will apply automatically during the specified window.',
              style: regularStyle(const Color(0xFFADB4CE), 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget peakHoursPricingWidget() {
    return Container(
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(16.sp),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enable Peak Hour Pricing',
                style: semiBoldStyle(whiteTextColor, 16.sp),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: peakHourSchedule.isEnabled,
                  activeThumbColor: white,
                  activeTrackColor: primaryColor,
                  inactiveThumbColor: white,
                  inactiveTrackColor: gray01,
                  onChanged: (val) {
                    setState(() {
                      peakHourSchedule.isEnabled = val;
                    });
                  },
                ),
              ),
            ],
          ),
          if (peakHourSchedule.isEnabled) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: Get.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PEAK START',
                    style: boldStyle(subtitleTextColor, 12.sp),
                  ),
                  SizedBox(height: 8.h),
                  buildTimeButton(
                    context: context,
                    time: peakHourSchedule.startTime,
                    onTimeSelected: (newTime) {
                      setState(() {
                        peakHourSchedule.startTime = newTime;
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'PEAK END',
                    style: boldStyle(subtitleTextColor, 12.sp),
                  ),
                  SizedBox(height: 8.h),
                  buildTimeButton(
                    context: context,
                    time: peakHourSchedule.endTime,
                    onTimeSelected: (newTime) {
                      setState(() {
                        peakHourSchedule.endTime = newTime;
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'PEAK HOURLY RATE(Rs.)',
                    style: boldStyle(subtitleTextColor, 12.sp),
                  ),
                  CustomTextFormField(
                    headingText: "",
                    headingTextStyle: regularStyle(subtitleTextColor, 16.sp),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    controller: peakRateCon,
                    maxLines: 1,
                    hintText: '2500',
                    filledColor: lightFilledBgColor,
                    hintStyle: regularStyle(disableButton, 16.sp),
                    validator: (value) => validateIsEmpty(string: value!),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildTimeButton({
    required BuildContext context,
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onTimeSelected,
  }) {
    return InkWell(
      onTap: () async {
        TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: buildPickerTheme,
        );
        if (picked != null) {
          onTimeSelected(picked);
        }
      },
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: Get.width,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: lightFilledBgColor,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          time.format(context),
          style: regularStyle(whiteTextColor, 16.sp),
        ),
      ),
    );
  }

  Widget saveOperationRulesWidget() {
    return InkWell(
      onTap: _handleSave,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: const Color(0xFF107100),
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Save Operating Rules',
              style: regularStyle(const Color(0xFF107100), 20.sp),
            ),
          ],
        ),
      ),
    );
  }
}