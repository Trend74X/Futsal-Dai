
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/constant.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:get/get.dart';

class MatchAttendance extends StatefulWidget {
  const MatchAttendance({super.key});

  @override
  State<MatchAttendance> createState() => _MatchAttendanceState();
}

class _MatchAttendanceState extends State<MatchAttendance> {
  
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
                  crossAxisAlignment: .start,
                  children: [
                    appbarWidget(),
                    SizedBox(height: 16.h),
                    attendanceCount(),
                    SizedBox(height: 16.h),
                    userChoice(),
                    SizedBox(height: 16.h),
                    squadStatus()
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
      mainAxisAlignment: .spaceBetween,
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, color: subtitleTextColor),
        ),
        Text('Match Attendance', style: boldStyle(primaryTextColor, 28.sp)),
        SizedBox(),
      ],
    );
  }

  Widget attendanceCount() {
    return Container(
      margin: .all(4.sp),
      padding: .symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: .circular(24.r),
      ),
      child: Row(
        mainAxisAlignment: .center,
        children: [
          countCircleWidget(count: 5, color: primaryColor, label: 'IN'),
          countCircleWidget(count: 3, color: Color(0xFFFFB4AB), label: 'OUT'),
          countCircleWidget(count: 2, color: grayDark, label: 'N/A')
        ]
      ),
    );
  }

  Widget countCircleWidget({required int count, required Color color, required String label}) {
    return Column(
      children: [
        Container(
          height: 80.h,
          width: 80.w,
          decoration: BoxDecoration(
            shape: .circle,
            border: .all(
              color: color,
              width: 4.w
            )
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: regularStyle(color, 20.sp)
            )
          )
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: regularStyle(color, 16.sp)
        )
      ]
    );
  }

  Widget userChoice() {
    return Container(
      width: double.infinity,
      margin: .all(4.sp),
      padding: .symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: .circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            'Are you showing up for this game?',
            style: regularStyle(whiteTextColor, 16.sp),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              userChoiceTile(
                title: "I'm In",
                subtitle: "I'll be there",
                color: primaryColor,
                icon: Icons.check
              ),
              SizedBox(width: 12.h),
              userChoiceTile(
                title: "I'm Out",
                subtitle: "Can't make it",
                color: Color(0xFFFFB4AB),
                icon: Icons.close
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget userChoiceTile({required String title, required String subtitle, required Color color, required IconData icon}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: .circular(12.r),
          border: .all(color: color, width: 2.w)
        ),
        padding: .symmetric(vertical: 8.h, horizontal: 16.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: .center,
              children: [
                Text(
                  title,
                  style: regularStyle(color, 16.sp),
                ),
                SizedBox(width: 8.w),
                Icon(
                  icon,
                  color: color
                )
              ],
            ),
            Text(
              subtitle,
              style: regularStyle(whiteTextColor, 16.sp),
            )
          ],
        ),
      ),
    );
  }

  Widget squadStatus() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Squad Status Feed',
          style: regularStyle(whiteTextColor, 16.sp)
        ),
        SizedBox(height: 8.h),
        ListView.separated(
          itemCount: squadStatusList.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => SizedBox(height: 4.w),
          itemBuilder: (context, index) {
            var data = squadStatusList[index];
            Color color = data['status'] == 'IN'
                            ? primaryColor
                            : data['status'] == 'OUT'
                              ? Color(0xFFFFB4AB)
                              : grayDark;
            return Container(
              width: double.infinity,
              margin: .all(4.sp),
              padding: .symmetric(vertical: 16.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: .circular(24.r),
              ),
              child: Row(
                children: [
                  Container(
                    height: 48.h,
                    width: 48.w,
                    decoration: BoxDecoration(
                      color: lightFilledBgColor,
                      shape: .circle
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        data['name'],
                        style: regularStyle(whiteTextColor, 16.sp),
                      ),
                      Text(
                        "Matches Played: ${data['matches_played']}",
                        style: regularStyle(subtitleTextColor, 14.sp),
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                    width: Get.width * 0.2,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: .circular(8.r)
                    ),
                    padding: .symmetric(vertical: 4.h, horizontal: 4.w),
                    child: Row(
                      mainAxisAlignment: .center,
                      children: [
                        Icon(
                          data['status'] == 'IN'
                            ? Icons.check
                            : data['status'] == 'OUT'
                              ? Icons.close
                              : Icons.question_mark,
                          size: 16.sp,
                          color: color
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          data['status'],
                          style: regularStyle(color, 16.sp),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        )
      ]
    );
  }

}