import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/widgets/custom_datetime_picker.dart';
import 'package:intl/intl.dart';

class OwnerSchedulePage extends StatefulWidget {
  const OwnerSchedulePage({super.key});

  @override
  State<OwnerSchedulePage> createState() => _OwnerSchedulePageState();
}

class _OwnerSchedulePageState extends State<OwnerSchedulePage> {
  
  DateTime selectedDate = DateTime.now();
  DateTime selectedDateTime = DateTime.now();

  int selectedCourtIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            child: Padding(
              padding: .all(16.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    dateSelectionWidget(),
                    SizedBox(height: 16.h),
                    pitchesFilterWidget(),
                    SizedBox(height: 16.h),
                    timelineWidget()
                  ],
                )
              )
            )
          )
        )
      )
    );
  }

  Widget dateSelectionWidget() {
    return Row(
      crossAxisAlignment: .end,
      children: [
        Expanded(
          flex: 4, 
          child: selectDate()
        ),
        Expanded(
          child: InkWell(
            onTap: () => _handleSelectDateTime(),
            child: Container(
              height: 85.h,
              margin: EdgeInsets.only(left: 8.w),
              decoration: BoxDecoration(
                color: filledBgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Icon(
                  Icons.calendar_month,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget selectDate() {
    List<DateTime> dates = List.generate(14, (index) => DateTime.now().add(Duration(days: index)));
    return Column(
      crossAxisAlignment: .start,
      children: [
        SizedBox(height: 8.h),
        SizedBox(
          height: 85.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              DateTime date = dates[index];
              bool isSelected = DateUtils.isSameDay(date, selectedDate);
              bool isToday = DateUtils.isSameDay(date, DateTime.now());
              String dayName = isToday 
                ? 'TODAY' 
                : DateFormat('E').format(date).toUpperCase(); // MON, TUE
              String dayNumber = DateFormat('d').format(date); // 10, 11

              return GestureDetector(
                onTap: () => setState(() => selectedDate = date),
                child: Container(
                  width: 60.w,
                  height: 80.h,
                  margin: .symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: boldStyle(isSelected ? Color(0xFF107100) : whiteTextColor, 12.sp)
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        dayNumber,
                        style: semiBoldStyle(isSelected ? Color(0xFF107100) : whiteTextColor, 20.sp)
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget pitchesFilterWidget() {
    return Container(
      height: 56.h,
      width: .infinity,
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: .circular(24.r)
      ),
      child: ListView.builder(
        itemCount: 3,
        shrinkWrap: true,
        scrollDirection: .horizontal,
        itemBuilder:(context, index) {
          return InkWell(
            onTap: () => setState(() => selectedCourtIndex = index),
            child: Container(
              decoration: BoxDecoration(
                color: selectedCourtIndex == index ? primaryColor : transparent,
                borderRadius: .circular(24.r)
              ),
              padding: .symmetric(horizontal: 24.w, vertical: 8.h),
              child: Center(
                child: Text(
                  'Court ${index + 1} \n${index % 2 == 0 ? 'Indoor' : 'Outdoor'}',
                  style: boldStyle(selectedCourtIndex == index ? Color(0xFF107100) : whiteTextColor, 12.sp),
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
      padding: .symmetric(vertical: 16.h, horizontal: 16.w),
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
      padding: .symmetric(vertical: 12.h),
      child: Row(
        children: [
          Expanded(child: Container(color: Color(0xFF85967C), height: 1.h)),
          SizedBox(width: 8.w),
          Text('EVENING SESSIONS', style: regularStyle(Color(0xFF85967C), 10.sp)),
          SizedBox(width: 8.w),
          Expanded(child: Container(color: Color(0xFF85967C), height: 1.h)),
        ]
      ),
    );
  }

  Widget timeLineTile({
    required String time,
    String? status,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: .start,
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
              borderRadius: .circular(8.r),
              border: .all(color: subtitleTextColor.withValues(alpha: 0.5))
            ),
            child: status == 'AVAILABLE' || status == 'EMPTY'
                    ? InkWell(
                      onTap: () {}, //=> Get.to(() => OwnserMaunualSlotEntry()),
                      child: Row(
                        mainAxisAlignment: .center,
                        children: [
                          Icon(Icons.add, color: subtitleTextColor),
                          Text(
                            status,
                            style: boldStyle(subtitleTextColor, 12.sp),
                          )
                        ],
                      ),
                    )
                    : Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: .infinity,
                          color: getInnerContainerColor(status: status),                          
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          mainAxisAlignment: .center,
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              status == 'Offline' ? 'Offline/Call/Walk-In' : status,
                              style: boldStyle(status == 'IN PROGESS' ? primaryColor : whiteTextColor, 12.sp),
                            ),
                            subtitle == null 
                              ? SizedBox()
                              : Text(
                                status == 'Offline' ? 'Pay on Arrival' : subtitle,
                                style: boldStyle(subtitleTextColor, 10.sp),
                              )
                          ],
                        ),
                      ],
                    ),
          ),
        )
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
              ? Color(0xFF93000A).withValues(alpha: 0.1)
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
            ? Color(0xFF93000A).withValues(alpha: 0.3)
            : textBlue;
  }

}