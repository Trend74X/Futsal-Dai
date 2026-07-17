import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/constant.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/url_launcher_helper.dart';
import 'package:futsal_dai/src/views/player/match_attendance.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';

class PlayerBookingPage extends StatefulWidget {
  const PlayerBookingPage({super.key});

  @override
  State<PlayerBookingPage> createState() => _PlayerBookingPageState();
}

class _PlayerBookingPageState extends State<PlayerBookingPage> {

  String selected = 'Upcoming';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            child: Padding(
              padding: .all(16.sp),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  titlesWidget(),
                  SizedBox(height: 16.h),
                  tabButtons(),
                  SizedBox(height: 24.h),
                  tabViews()
                ],
              ),
            )
          ),
        ),
      )
    );
  }

  Widget titlesWidget() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'My Matches',
          style: TextStyle(
            color: whiteTextColor,
            fontWeight: .bold,
            fontSize: 28.sp
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: .circular(8.r),
            border: Border.all(
              color: primaryTextColor,
            )
          ),
          padding: .symmetric(vertical: 4.h, horizontal: 8.w),
          margin: .only(top: 2.h),
          child: Row(
            mainAxisSize: .min,
            children: [
              Icon(Icons.timer_outlined, color: primaryTextColor, size: 12.sp),
              SizedBox(width: 8.w),
              Text(
                'NEXT MATCH: IN 4 HOURS',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 12.sp,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget tabButtons() {
    return Container(
      decoration: BoxDecoration(
        color: lightFilledBgColor,
        borderRadius: .circular(24.r)
      ),
      child: Row(
        mainAxisSize: .max,
        children: [
          buttonWidget(label: 'Upcoming', onTap: () {}, isSelected: selected == 'Upcoming'),
          buttonWidget(label: 'Pending', onTap: () {}, isSelected: selected == 'Pending'),
          buttonWidget(label: 'Past Matches', onTap: () {}, isSelected: selected == 'Past Matches')
        ]
      ),
    );
  }

  Widget buttonWidget({required String label, required VoidCallback onTap, required bool isSelected}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          onTap;
          setState(() => selected = label);
        },
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : transparent,
            borderRadius: .circular(24.r)
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: .bold,
                color: isSelected ? Color(0xFF053900) : whiteTextColor
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget tabViews() {
    return selected == 'Upcoming'
      ? upcomingWidget()
      : selected == 'Pending'
        ? pendingWidget()
        : pastWidget();
  }

  Widget upcomingWidget() {
    return InkWell(
      onTap: () => Get.to(() => MatchAttendance()),
      child: Container(
        margin: .all(4.sp),
        decoration: BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: .circular(24.r),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.5),
              offset: Offset(0, 0),
              blurRadius: 9.sp,
              spreadRadius: 3.sp
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            ClipRRect(
              borderRadius: .only(
                topLeft: .circular(24.r),
                topRight: .circular(24.r)
              ),
              child: SizedBox(
                height: 128.h,
                width: .infinity,
                child: Image.asset(
                  'assets/images/court.png',
                  fit: .cover,
                )
              )
            ),
            Padding(
              padding: .all(16.sp),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    'X-Arena Pro',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 20.sp,
                      fontWeight: .w600
                    ),
                  ),
                  Text(
                    '[PITCH 1 • INDOOR 5-A-SIDE]',
                    style: TextStyle(
                      color: subtitleTextColor,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: .start,
                    children: [
                      Icon(Icons.date_range_rounded, color: primaryTextColor, size: 15.sp),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            'Sat, Dec 16 | 7:00 PM - 8:00 PM',
                            style: TextStyle(
                              color: whiteTextColor,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(Icons.timer, color: primaryTextColor, size: 15.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Starts in 2h 15m',
                                style: TextStyle(
                                  color: Color(0xFF2AE500),
                                  fontSize: 12.sp,
                                  fontWeight: .bold
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(Icons.flash_on, color: subtitleTextColor, size: 12.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Extra Bibs Requested',
                        style: TextStyle(
                          color: subtitleTextColor,
                          fontSize: 12.sp
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset('assets/icons/ball.png', color: subtitleTextColor, height: 12.h),
                      SizedBox(width: 8.w),
                      Text(
                        '2 Match Balls',
                        style: TextStyle(
                          color: subtitleTextColor,
                          fontSize: 12.sp
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => launchMapDirections(),
                        child: Container(
                          decoration: BoxDecoration(
                            border: .all(
                              color: primaryTextColor
                            ),
                            borderRadius: .circular(12.r)
                          ),
                          padding: .symmetric(vertical: 12.h, horizontal: 12.w),
                          child: Row(
                            mainAxisSize: .min,
                            children: [
                              Icon(Icons.map_outlined, size: 18.sp, color: primaryTextColor),
                              SizedBox(width: 8.w),
                              Text(
                                'Get Directions',
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 16.sp,
                                )
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: InkWell(
                          onTap: () => makePhoneCall('9809809809'),
                          child: Container(
                            decoration: BoxDecoration(
                              border: .all(
                               color:  primaryTextColor
                              ),
                              borderRadius: .circular(12.r)
                            ),
                            padding: .symmetric(vertical: 12.h, horizontal: 12.w),
                            child: Row(
                              mainAxisSize: .min,
                              children: [
                                Icon(Icons.phone, size: 18.sp, color: primaryTextColor),
                                SizedBox(width: 8.w),
                                Text(
                                  'Call Owner',
                                  style: TextStyle(
                                    color: primaryTextColor,
                                    fontSize: 16.sp,
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Center(
                  //   child: Text(
                  //     'Free cancellation valid for 45 more minutes',
                  //     style: TextStyle(
                  //       color: subtitleTextColor,
                  //       fontSize: 10.sp
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 12.h),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget pendingWidget() {
    return Container(
      margin: .all(4.sp),
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: .circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFF59E0B).withValues(alpha: 0.5),
            offset: Offset(0, 0),
            blurRadius: 9.sp,
            spreadRadius: 3.sp
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          ClipRRect(
            borderRadius: .only(
              topLeft: .circular(24.r),
              topRight: .circular(24.r)
            ),
            child: SizedBox(
              height: 128.h,
              width: .infinity,
              child: Image.asset(
                'assets/images/court.png',
                fit: .cover,
              )
            )
          ),
          Padding(
            padding: .all(16.sp),
            child: Column(
              children: [
                Text(
                  'Prismatic Futsal & Recreation Center',
                  style: TextStyle(
                    color: whiteTextColor,
                    fontWeight: .bold,
                    fontSize: 28.sp,
                    height: 1.0
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: subtitleTextColor, size: 13.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Sanepa, Lalitpur, Nepal',
                      style: TextStyle(
                        color: subtitleTextColor,
                        fontSize: 14.sp
                      ),
                    )
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  decoration: BoxDecoration(
                    color: lightFilledBgColor.withValues(alpha: 0.5),
                    borderRadius: .circular(12.r)
                  ),
                  padding: .all(16.sp),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: whiteTextColor,
                        fontSize: 14.sp,
                        height: 1.3,
                      ),
                      children: [
                        const TextSpan(
                          text: "The manager of Prismatic Futsal & Recreation Center will call your number (",
                        ),
                        TextSpan(
                          text: "+977 9809809801",
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => makePhoneCall('+977 9809809801'),
                        ),
                        const TextSpan(
                          text: ") directly to verify this booking request within 15 minutes before the slot expires.",
                        ),
                      ],
                    ),
                  )
                ),
                SizedBox(height: 16.h),
                CustomUsualButton(
                  text: 'Call Owner Directly', 
                  onPressed: () {},
                  fontColor: Color(0xFFF59E0B),
                  fontWeight: .w600,
                  fontSize: 20.sp,
                  borderColor: Color(0xFFF59E0B),
                  bgColor: Color(0xFFF59E0B).withValues(alpha: 0.01),
                  height: 64.h,
                ),
                SizedBox(height: 8.h),
              ],
            )
          )
        ]
      )
    );
  }

  Widget pastWidget() {
    return ListView.separated(
      itemCount: pastMatches.length,
      shrinkWrap: true,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        var data = pastMatches[index];
        return Container(
          decoration: BoxDecoration(
            color: data['status'] == 'completed'
                    ? Color(0xFF1E293B).withValues(alpha: 0.9)
                    : Color(0xFF93000A).withValues(alpha: 0.25),
            borderRadius: .circular(12.r)
          ),
          padding: .symmetric(vertical: 16.h, horizontal: 12.w),
          child: Row(
            crossAxisAlignment: .start,
            children: [
              ClipRRect(
                borderRadius: .circular((12.r)
                ),
                child: SizedBox(
                  height: 64.h,
                  width: 64.w,
                  child: Image.asset(
                    'assets/images/court.png',
                    fit: .cover,
                  )
                )
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      data['label'],
                      style: TextStyle(
                        color: whiteTextColor,
                        fontSize: 20.sp,
                        fontWeight: .w600,
                        height: 1.0
                      ),
                      maxLines: 2,
                    ),
                    Text(
                      data['date'],
                      style: TextStyle(
                        color: subtitleTextColor,
                        fontSize: 14.sp,
                      ),
                    ),
                    data['status'] != 'completed'
                      ? SizedBox.shrink()
                      : Text(
                        "Paid: Rs. ${data['amount']}",
                        style: TextStyle(
                          color: subtitleTextColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: data['status'] == 'completed'
                              ? primaryColor.withValues(alpha: 0.1)
                              : Color(0xFF93000A).withValues(alpha: 0.2),
                        borderRadius: .circular(12.r),
                        border: Border.all(
                          color: data['status'] == 'completed'
                                  ? Color(0xFFEFFFE3).withValues(alpha: 0.2)
                                  : Color(0xFFFFB4AB).withValues(alpha: 0.3)
                        )
                      ),
                      padding: .symmetric(vertical: 4.h, horizontal: 8.w),
                      child: Text(
                        data['status'].toUpperCase(),
                        style: TextStyle(
                          color: data['status'] == 'completed'
                                  ? primaryColor
                                  : Color(0xFFFFB4AB),
                          fontSize: 10.sp
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              Visibility(
                visible: data['status'] == 'completed',
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: .circular(8.r)
                  ),
                  padding: .symmetric(vertical: 4.h, horizontal: 8.w),
                  child: Text(
                    'REBOOK',
                    style: TextStyle(
                      color: Color(0xFF107100),
                      fontWeight: .bold,
                      fontSize: 12.sp
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
  }

}