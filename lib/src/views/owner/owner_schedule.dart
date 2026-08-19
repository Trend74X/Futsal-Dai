import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';

class OwnerSchedulePage extends StatefulWidget {
  const OwnerSchedulePage({super.key});

  @override
  State<OwnerSchedulePage> createState() => _OwnerSchedulePageState();
}

class _OwnerSchedulePageState extends State<OwnerSchedulePage> {
  
  DateTime selectedDateTime = DateTime.now();
  int selectedCourtIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dateSelectionWidget(),
                    SizedBox(height: 16.h),
                    pitchesFilterWidget(),
                    SizedBox(height: 16.h),
                    timelineWidget()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Replaces the list/picker with an inline calendar widget
  Widget dateSelectionWidget() {
    return Container(
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: subtitleTextColor.withValues(alpha: 0.3),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: primaryColor, // Selected date circle color
            onPrimary: black,
            surface: filledBgColor,
            onSurface: whiteTextColor,
          ),
        ),
        child: CalendarDatePicker(
          initialDate: selectedDateTime,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          onDateChanged: (DateTime newDate) {
            setState(() {
              selectedDateTime = newDate;
            });
          },
        ),
      ),
    );
  }

  Widget pitchesFilterWidget() {
    return Container(
      height: 56.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: ListView.builder(
        itemCount: 3,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => setState(() => selectedCourtIndex = index),
            child: Container(
              decoration: BoxDecoration(
                color: selectedCourtIndex == index ? primaryColor : transparent,
                borderRadius: BorderRadius.circular(24.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: Center(
                child: Text(
                  'Court ${index + 1} \n${index % 2 == 0 ? 'Indoor' : 'Outdoor'}',
                  style: boldStyle(selectedCourtIndex == index ? const Color(0xFF107100) : whiteTextColor, 12.sp),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget timelineWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Column(
        children: [
          timeLineTile(time: '6:00\nAM', status: 'Completed', subtitle: 'Team Wolves'),
          SizedBox(height: 8.h),
          timeLineTile(time: '7:00\nAM', status: 'IN PROGESS', subtitle: 'Strikers FC'),
          SizedBox(height: 8.h),
          timeLineTile(time: '8:00\nAM', status: 'AVAILABLE'),
          SizedBox(height: 8.h),
          timeLineTile(time: '9:00\nAM', status: 'Booked', subtitle: 'Corporate Group A'),
          SizedBox(height: 8.h),
          timeLineTile(time: '10:00\nAM', status: 'Booked', subtitle: 'Corporate Group A'),
          SizedBox(height: 8.h),
          dividerWidget(),
          SizedBox(height: 8.h),
          timeLineTile(time: '4:00\nPM', status: 'Completed', subtitle: 'Corporate Group A'),
          SizedBox(height: 8.h),
          timeLineTile(time: '5:00\nPM', status: 'Offline', subtitle: 'Corporate Group A'),
          SizedBox(height: 8.h),
          timeLineTile(time: '6:00\nPM', status: 'AVAILABLE', subtitle: ''),
          SizedBox(height: 8.h),
          timeLineTile(time: '7:00\nPM', status: 'Booked', subtitle: 'Corporate Group A'),
          SizedBox(height: 8.h),
          timeLineTile(time: '8:00\nPM', status: 'Cancelled', subtitle: ''),
          SizedBox(height: 8.h),
          timeLineTile(time: '9:00\nPM', status: 'AVAILABLE', subtitle: ''),
        ],
      ),
    );
  }

  Widget dividerWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Expanded(child: Container(color: const Color(0xFF85967C), height: 1.h)),
          SizedBox(width: 8.w),
          Text('EVENING SESSIONS', style: regularStyle(const Color(0xFF85967C), 10.sp)),
          SizedBox(width: 8.w),
          Expanded(child: Container(color: const Color(0xFF85967C), height: 1.h)),
        ],
      ),
    );
  }

  Widget timeLineTile({
    required String time,
    String? status,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            time,
            style: boldStyle(status == 'Completed' ? gray02 : subtitleTextColor, 12.sp),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 6,
          child: Container(
            height: 80.h,
            decoration: BoxDecoration(
              color: getContainerColor(status: status!),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: subtitleTextColor.withValues(alpha: 0.5)),
            ),
            child: status == 'AVAILABLE' || status == 'EMPTY'
                ? InkWell(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: subtitleTextColor),
                        Text(
                          status,
                          style: boldStyle(subtitleTextColor, 12.sp),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: double.infinity,
                        color: getInnerContainerColor(status: status),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status == 'Offline' ? 'Offline/Call/Walk-In' : status,
                            style: boldStyle(status == 'IN PROGESS' ? primaryColor : whiteTextColor, 12.sp),
                          ),
                          subtitle == null
                              ? const SizedBox()
                              : Text(
                                  status == 'Offline' ? 'Pay on Arrival' : subtitle,
                                  style: boldStyle(subtitleTextColor, 10.sp),
                                ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Color getContainerColor({required String status}) {
    return status == 'AVAILABLE'
        ? transparent
        : status == 'Completed'
            ? lightFilledBgColor
            : status == 'IN PROGESS'
                ? primaryColor.withValues(alpha: 0.2)
                : status == 'Offline'
                    ? gray01
                    : status == 'Cancelled'
                        ? const Color(0xFF93000A).withValues(alpha: 0.1)
                        : filledBgColor;
  }

  Color getInnerContainerColor({required String status}) {
    return status == 'Completed'
        ? subtitleTextColor
        : status == 'IN PROGESS'
            ? primaryColor
            : status == 'Offline'
                ? gray01
                : status == 'Cancelled'
                    ? const Color(0xFF93000A).withValues(alpha: 0.3)
                    : textBlue;
  }
}