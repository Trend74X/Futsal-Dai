import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/model/day_schedule_model.dart';

class BusinessHoursScreen extends StatefulWidget {
  final List<DaySchedule> individualDays;
  final List<DaySchedule> groupedDays;
  final bool isMonFriGrouped;
  final ValueChanged<bool> onGroupToggleChanged;
  final ValueChanged<List<DaySchedule>> onScheduleChanged;

  const BusinessHoursScreen({
    super.key,
    required this.individualDays,
    required this.groupedDays,
    required this.isMonFriGrouped,
    required this.onGroupToggleChanged,
    required this.onScheduleChanged,
  });

  @override
  State<BusinessHoursScreen> createState() => _BusinessHoursScreenState();
}

class _BusinessHoursScreenState extends State<BusinessHoursScreen> {
  @override
  Widget build(BuildContext context) {
    // Pick current working list based on grouped toggle state
    List<DaySchedule> currentList = widget.isMonFriGrouped ? widget.groupedDays : widget.individualDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // "Apply Mon-Fri" Action Header
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
              style: semiBoldStyle(whiteTextColor, 20.sp),
            ),
            const Spacer(),
            InkWell(
              onTap: () => widget.onGroupToggleChanged(!widget.isMonFriGrouped),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isMonFriGrouped ? primaryColor.withValues(alpha: 0.1) : transparent,
                  borderRadius: .circular(8.r),
                  border: .all(color: widget.isMonFriGrouped ? primaryColor : gray06, width: 0.5)
                ),
                padding: .symmetric(vertical: 12.h, horizontal: 12.w),
                child: Text(
                  widget.isMonFriGrouped ? 'Separate Days' : 'Apply Mon-Fri',
                  style: boldStyle(const Color(0xFFBEC6E0), 12.sp),
                )
              )
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Schedule List
        Column(
          children: currentList.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _buildDayRow(item, currentList),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDayRow(DaySchedule item, List<DaySchedule> currentList) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: gray01),
      ),
      child: Row(
        children: [
          // Enable / Disable Switch
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
                widget.onScheduleChanged(currentList);
              },
            ),
          ),
          SizedBox(width: 4.w),

          // Day / Group Label
          Expanded(
            child: Text(
              item.label,
              style: semiBoldStyle(whiteTextColor, 18.sp).copyWith(height: 1.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Closed Indicator OR Time Pickers
          if (!item.isEnabled)
            Text(
              'Closed all day',
              style: regularStyle(subtitleTextColor, 16.sp),
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
                      builder: buildPickerTheme,
                    );
                    if (picked != null) {
                      setState(() {
                        item.startTime = picked;
                      });
                      widget.onScheduleChanged(currentList);
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0.w),
                  child: Text(
                    'to',
                    style: regularStyle(subtitleTextColor, 16.sp),
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
                      setState(() {
                        item.endTime = picked;
                      });
                      widget.onScheduleChanged(currentList);
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
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
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

}