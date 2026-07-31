import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/owner_controller.dart';
import 'package:futsal_dai/src/helper/constant.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/validators.dart';
import 'package:futsal_dai/src/model/day_schedule_model.dart';
import 'package:futsal_dai/src/views/owner/owner_business_hours_widget.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:get/get.dart';

class OwnerOperatingHours extends StatefulWidget {
  final int venueId;

  const OwnerOperatingHours({super.key, required this.venueId});

  @override
  State<OwnerOperatingHours> createState() => _OwnerOperatingHoursState();
}

class _OwnerOperatingHoursState extends State<OwnerOperatingHours> {
  final controller = Get.put(OwnerController());

  int selectedDuration = 60;
  String selectedBufferTime = 'none';
  bool isMonFriGrouped = false;

  final peakRateCon = TextEditingController();

  DaySchedule peakHourSchedule = DaySchedule(
    dayOfWeek: -1,
    label: 'Peak Hours',
    isEnabled: false,
    startTime: const TimeOfDay(hour: 16, minute: 0),
    endTime: const TimeOfDay(hour: 22, minute: 0),
  );

  @override
  void dispose() {
    peakRateCon.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  int _getBufferMinutes() {
    if (selectedBufferTime == 'none') return 0;
    return int.tryParse(selectedBufferTime) ?? 0;
  }

  // Normalizes grouped Mon-Fri into individual records (1..5)
  List<DaySchedule> _getFinalScheduleForDatabase() {
    if (!isMonFriGrouped) {
      return individualDays;
    }

    final monFriGroup = groupedDays.firstWhere((item) => item.label == 'Mon - Fri');
    final List<DaySchedule> expandedList = [];

    for (int dayIndex = 0; dayIndex <= 6; dayIndex++) {
      if (dayIndex >= 1 && dayIndex <= 5) {
        expandedList.add(
          DaySchedule(
            label: _getDayLabel(dayIndex),
            dayOfWeek: dayIndex,
            isEnabled: monFriGroup.isEnabled,
            startTime: monFriGroup.startTime,
            endTime: monFriGroup.endTime,
          ),
        );
      } else {
        final dayItem = groupedDays.firstWhere(
          (item) => item.dayOfWeek == dayIndex,
          orElse: () => DaySchedule(label: _getDayLabel(dayIndex), dayOfWeek: dayIndex),
        );
        expandedList.add(dayItem);
      }
    }

    return expandedList;
  }

  String _getDayLabel(int dayIndex) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[dayIndex];
  }

  Future<void> _handleSave() async {
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

    final finalSchedule = _getFinalScheduleForDatabase();

    // 1. Daily operating hours payload
    final List<Map<String, dynamic>> operatingHoursData = finalSchedule.map((day) {
      return {
        'venue_id': widget.venueId,
        'day_of_week': day.dayOfWeek,
        'open_time': _formatTimeOfDay(day.startTime),
        'close_time': _formatTimeOfDay(day.endTime),
        'is_closed': !day.isEnabled,
        'is_peak': peakHourSchedule.isEnabled,
        'peak_start_time': peakHourSchedule.isEnabled ? _formatTimeOfDay(peakHourSchedule.startTime) : null,
        'peak_end_time': peakHourSchedule.isEnabled ? _formatTimeOfDay(peakHourSchedule.endTime) : null,
        'peak_rate': peakHourSchedule.isEnabled ? (double.tryParse(peakRateCon.text) ?? 0.0) : null,
      };
    }).toList();

    // 2. Global venue settings payload
    final Map<String, dynamic> venueSettingsData = {
      'slot_duration_mins': selectedDuration,
      'buffer_time_mins': _getBufferMinutes(),
      'is_peak_enabled': peakHourSchedule.isEnabled,
      'peak_start_time': peakHourSchedule.isEnabled ? _formatTimeOfDay(peakHourSchedule.startTime) : null,
      'peak_end_time': peakHourSchedule.isEnabled ? _formatTimeOfDay(peakHourSchedule.endTime) : null,
      'peak_rate': peakHourSchedule.isEnabled ? (double.tryParse(peakRateCon.text) ?? 0.0) : null,
    };

    // 3. Controller execution
    await controller.saveOperatingRules(
      venueId: widget.venueId,
      operatingHours: operatingHoursData,
      venueSettings: venueSettingsData,
    );
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
                      groupedDays: groupedDays,
                      isMonFriGrouped: isMonFriGrouped,
                      onGroupToggleChanged: (val) {
                        setState(() {
                          isMonFriGrouped = val;
                        });
                      },
                      onScheduleChanged: (updatedList) {
                        setState(() {
                          if (isMonFriGrouped) {
                            groupedDays = updatedList;
                          } else {
                            individualDays = updatedList;
                          }
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
    final controller = Get.find<OwnerController>();

    return Obx(() {
      final isLoading = controller.isLoadingData.value;

      return InkWell(
        onTap: isLoading ? null : _handleSave,
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
              isLoading
                  ? SizedBox(
                      height: 20.sp,
                      width: 20.sp,
                      child: const CircularProgressIndicator(
                        color: Color(0xFF107100),
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.check_circle_outline,
                      color: const Color(0xFF107100),
                      size: 20.sp,
                    ),
              SizedBox(width: 8.w),
              Text(
                isLoading ? 'Saving...' : 'Save Operating Rules',
                style: regularStyle(const Color(0xFF107100), 20.sp),
              ),
            ],
          ),
        ),
      );
    });
  }
}