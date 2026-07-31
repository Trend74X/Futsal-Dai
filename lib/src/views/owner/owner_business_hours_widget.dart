import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/model/day_schedule_model.dart';

class BusinessHoursScreen extends StatefulWidget {
  final List<DaySchedule> individualDays;
  final Function(List<DaySchedule>) onScheduleChanged;

  const BusinessHoursScreen({
    super.key,
    required this.individualDays,
    required this.onScheduleChanged,
  });

  @override
  State<BusinessHoursScreen> createState() => _BusinessHoursScreenState();
}

// class DaySchedule {
//   String label;
//   bool isEnabled;
//   TimeOfDay startTime;
//   TimeOfDay endTime;

//   DaySchedule({
//     required this.label,
//     this.isEnabled = true,
//     this.startTime = const TimeOfDay(hour: 6, minute: 0),
//     this.endTime = const TimeOfDay(hour: 23, minute: 0),
//   });
// }

class _BusinessHoursScreenState extends State<BusinessHoursScreen> {
  bool isMonFriGrouped = false;

  // Individual schedules for 7 days
  List<DaySchedule> individualDays = [
    DaySchedule(dayOfWeek: 0, label: 'Sunday'),
    DaySchedule(dayOfWeek: 1, label: 'Monday'),
    DaySchedule(dayOfWeek: 2, label: 'Tuesday'),
    DaySchedule(dayOfWeek: 3, label: 'Wednesday'),
    DaySchedule(dayOfWeek: 4, label: 'Thursday'),
    DaySchedule(dayOfWeek: 5, label: 'Friday'),
    DaySchedule(dayOfWeek: 6, label: 'Saturday'),
  ];

  // Grouped schedule (3 rows)
  final List<DaySchedule> groupedDays = [
    DaySchedule(label: 'Mon - Fri', dayOfWeek: null),
    DaySchedule(label: 'Saturday', isEnabled: false, dayOfWeek: null),
    DaySchedule(label: 'Sunday', isEnabled: false, dayOfWeek: null),
  ];

  @override
  Widget build(BuildContext context) {
    List<DaySchedule> currentList = isMonFriGrouped ? groupedDays : individualDays;

    return Column(
      crossAxisAlignment: .end,
      children: [
        // "Apply Mon-Fri" Action Button
        Row(
          children: [
            Icon(
              Icons.calendar_month,
              size: 21.sp,
              color: primaryColor,
            ),
            SizedBox(width: 6.w),
            Text(
              'Weekly Hours',
              style: semiBoldStyle(whiteTextColor, 20.sp)
            ),
            Spacer(),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  isMonFriGrouped = !isMonFriGrouped;
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isMonFriGrouped ? Colors.greenAccent : Colors.grey[700]!,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                backgroundColor: isMonFriGrouped
                    ? Colors.greenAccent.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
              child: Text(
                isMonFriGrouped ? 'Separate Days' : 'Apply Mon-Fri',
                style: boldStyle(Color(0xFFBEC6E0), 12.sp)
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // List of Days
        Column(
          children: currentList.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _buildDayRow(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDayRow(DaySchedule item) {
    return Container(
      padding: .symmetric(horizontal: 6.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: .circular(12.r),
        border: .all(color: gray01),
      ),
      child: Row(
        children: [
          // Switch Button
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: item.isEnabled,
              activeThumbColor: white,
              activeTrackColor: primaryColor,
              inactiveThumbColor: white,
              inactiveTrackColor: gray01,
              onChanged: (val) {
                setState(() {
                  item.isEnabled = val;
                });
              },
            ),
          ),
          SizedBox(width: 4.w),

          // Day Label
          Expanded(
            child: Text(
              item.label,
              style: semiBoldStyle(whiteTextColor, 18.sp).copyWith(height: 1.0),
              maxLines: 1,
              overflow: .ellipsis,
            ),
          ),

          // Closed or Time Selectors
          if (!item.isEnabled)
            Text(
              'Closed all day',
              style: regularStyle(subtitleTextColor, 16.sp)
            )
          else
            Row(
              children: [
                _buildTimeButton(
                  time: item.startTime,
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: item.startTime,
                      builder: buildPickerTheme
                    );
                    if (picked != null) {
                      setState(() => item.startTime = picked);
                    }
                  },
                ),
                Padding(
                  padding: .symmetric(horizontal: 4.0.w),
                  child: Text(
                    'to',
                    style: regularStyle(subtitleTextColor, 16.sp)
                  ),
                ),
                _buildTimeButton(
                  time: item.endTime,
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: item.endTime,
                      builder: buildPickerTheme,
                    );
                    if (picked != null) {
                      setState(() => item.endTime = picked);
                    }
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimeButton({
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: .circular(6.r),
      child: Container(
        padding: .symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: lightFilledBgColor,
          borderRadius: .circular(6.r),
        ),
        child: Text(
          time.format(context),
          style: regularStyle(whiteTextColor, 16.sp)
        ),
      ),
    );
  }
}