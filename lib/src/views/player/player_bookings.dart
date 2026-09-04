import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/group_controller.dart';
import 'package:futsal_dai/src/controller/player_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/url_launcher_helper.dart';
import 'package:futsal_dai/src/model/booking_model.dart';
import 'package:futsal_dai/src/views/player/match_attendance.dart';
import 'package:futsal_dai/src/views/player/player_team_shuffler.dart';
import 'package:futsal_dai/src/widgets/custom_map.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PlayerBookingPage extends StatefulWidget {
  const PlayerBookingPage({super.key});

  @override
  State<PlayerBookingPage> createState() => _PlayerBookingPageState();
}

class _PlayerBookingPageState extends State<PlayerBookingPage> {
  final playerCon = Get.put(PlayerController());
  final groupCon  = Get.put(GroupController());

  String selected        = 'Upcoming';
  List   upcomingMatches = [];
  List   pendingMatches  = [];
  List   matchHistory    = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getBookingsList();
    });
  }

  Future<void> getBookingsList() async {
    await playerCon.getBookingDatas();
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final currentTimeStr = DateFormat('HH:mm:ss').format(now);

    List<BookingModel> filterAndSort(String status, {bool ascending = false}) {
      final list = playerCon.myMatches
          .where((match) {
            if (match.status != status) return false;
            
            // Only include future matches for pending status (or apply generally if needed)
            if (status == 'pending') {
              final matchDateOnly = match.bookingDate.split('T')[0];
              if (matchDateOnly.compareTo(todayStr) > 0) return true;
              if (matchDateOnly == todayStr && match.startTime.compareTo(currentTimeStr) >= 0) return true;
              return false;
            }
            
            return true;
          })
          .toList()
        ..sort((a, b) {
          int dateComp = ascending 
              ? a.bookingDate.compareTo(b.bookingDate) 
              : b.bookingDate.compareTo(a.bookingDate);
          return dateComp != 0 
              ? dateComp 
              : (ascending ? a.startTime.compareTo(b.startTime) : b.startTime.compareTo(a.startTime));
        });
      return list.cast<BookingModel>();
    }

    // Upcoming matches (Only future dates/times)
    upcomingMatches = playerCon.myMatches.where((match) {
      if (match.status != 'booked') return false;
      final matchDateOnly = match.bookingDate.split('T')[0];
      if (matchDateOnly.compareTo(todayStr) > 0) return true;
      if (matchDateOnly == todayStr && match.startTime.compareTo(currentTimeStr) >= 0) return true;
      return false;
    }).toList()
      ..sort((a, b) {
        int dateComp = a.bookingDate.compareTo(b.bookingDate);
        return dateComp != 0 ? dateComp : a.startTime.compareTo(b.startTime);
      });

    pendingMatches = filterAndSort('pending');

    matchHistory = playerCon.myMatches.where((match) {
        if (match.status != 'booked') return false;

        // Parse bookingDate safely (handling potential time component like '2026-08-10T00:00:00')
        final matchDateOnly = match.bookingDate.split('T')[0];
        final int dateComparison = matchDateOnly.compareTo(todayStr);

        // 1. Show every past record that is yesterday or before (date strictly less than today)
        if (dateComparison < 0) {
          return true;
        }

        // 2. Show past records of today that started before the current time
        if (dateComparison == 0) {
          final matchStartTime = match.startTime.substring(0, 8); // Ensure 'HH:mm:ss' format
          if (matchStartTime.compareTo(currentTimeStr) < 0) {
            return true;
          }
        }

        return false;
      }).toList()
        ..sort((a, b) {
          int dateComp = b.bookingDate.compareTo(a.bookingDate);
          return dateComp != 0 ? dateComp : b.startTime.compareTo(a.startTime);
        });
    
    setState(() {});
  }

  /// Calculates remaining time dynamically from the very first upcoming match
  String _getRemainingTimeText() {
    if (upcomingMatches.isEmpty) return '';

    try {
      final firstMatch = upcomingMatches.first;
      final datePart = firstMatch.bookingDate.split('T')[0];
      final timePart = firstMatch.startTime;
      final matchDateTime = DateTime.parse('$datePart $timePart');

      final difference = matchDateTime.difference(DateTime.now());

      if (difference.isNegative) {
        return 'STARTED / PAST';
      }

      int days = difference.inDays;
      int hours = difference.inHours % 24;
      int minutes = difference.inMinutes % 60;

      if (days > 0) {
        return 'NEXT MATCH: IN ${days}D ${hours}H';
      } else if (hours > 0) {
        return 'NEXT MATCH: IN ${hours}H ${minutes}M';
      } else {
        return 'NEXT MATCH: IN ${minutes}M';
      }
    } catch (e) {
      return 'NEXT MATCH';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: .all(16.sp),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    titlesWidget(),
                    SizedBox(height: 16.h),
                    tabButtons(),
                    SizedBox(height: 24.h),
                    tabViews(),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            )
          ),
        ),
      )
    );
  }

  Widget titlesWidget() {
    String remainingText = _getRemainingTimeText();

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
        upcomingMatches.isEmpty || remainingText.isEmpty
          ? SizedBox()
          : Container(
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
                  remainingText,
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
          onTap();
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
    return upcomingMatches.isEmpty
      ? SizedBox(
        height: Get.height * 0.5,
        child: Center(
          child: Text(
            'There is no upcoming matches.',
            style: semiBoldStyle(subtitleTextColor, 14.sp),
          )
        )
      )
      : ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: upcomingMatches.length,
        separatorBuilder:(context, index) => SizedBox(height: 16.h), 
        itemBuilder:(context, index) {
          var data = upcomingMatches[index];
          String date = DateFormat('EEE, MMM d, yyyy').format(DateTime.parse(data.bookingDate));
          String time = "${data.startTime.substring(0, 5)} - ${data.endTime.substring(0, 5)}";
          return InkWell(
            onTap: () => Get.to(() => MatchAttendance(bookingId: data.id, groupId: data.groupId, address: data.futsalVenues.address)),
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
              child: Stack(
                children: [
                  Column(
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
                              data.venueName,
                              style: semiBoldStyle(primaryTextColor, 20.sp).copyWith(height: 1.0)
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              data.groundName,
                              style: TextStyle(
                                color: subtitleTextColor,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              crossAxisAlignment: .center,
                              children: [
                                Icon(Icons.location_on_outlined, color: primaryTextColor, size: 13.sp),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    data.futsalVenues.address,
                                    style: regularStyle(subtitleTextColor, 14.sp).copyWith(height: 1.0),
                                    maxLines: 2,
                                    overflow: .ellipsis,
                                  ),
                                )
                              ],
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
                                      '$date | $time',
                                      style: TextStyle(
                                        color: whiteTextColor,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => Get.to(() => CustomMapScreen(
                                        initialLat: data.futsalVenues!.latitude,
                                        initialLng: data.futsalVenues!.longitude,
                                        showCurrentLocation: true,
                                        showDirection: true,
                                        enableSearch: false,
                                        isFullScreenView: true,
                                      )),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: .all(color: primaryTextColor),
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
                                              style: regularStyle(primaryTextColor, 16.sp)
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => makePhoneCall(data.futsalVenues!.phoneNumber),
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
                                CustomUsualButton(
                                  text: 'Cancel Booking', 
                                  onPressed: () {
                                    playerCon.updateBookingStatus(data.id, 'cancelled_player');
                                    getBookingsList();
                                  },
                                  fontColor: Color(0xFFFFB4AB),
                                  fontWeight: .w600,
                                  fontSize: 16.sp,
                                  borderColor: Color(0xFFFFB4AB),
                                  bgColor: Color(0xFFFFB4AB).withValues(alpha: 0.01),
                                  height: 52.h,
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                          ],
                        ),
                      )
                    ],
                  ),
                  Align(
                    alignment: .topRight,
                    child: InkWell(
                      onTap: () => Get.to(() => PlayerTeamShuffler(bookingId: data.id, groupId: data.groupId)),
                      child: Container(
                        margin: .all(16.sp),
                        decoration: BoxDecoration(
                          color: filledBgColor,
                          borderRadius: .circular(12.r)
                        ),
                        padding: .all(12.sp),
                        child: Icon(
                          Icons.diversity_3,
                          size: 24.sp,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        } 
      );
  }

  Widget pendingWidget() {
    return pendingMatches.isEmpty
      ? SizedBox(
        height: Get.height * 0.5,
        child: Center(
          child: Text(
            'There is no pending matches.',
            style: semiBoldStyle(subtitleTextColor, 14.sp),
          )
        )
      )
      : ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: pendingMatches.length,
        separatorBuilder:(context, index) => SizedBox(height: 16.h), 
        itemBuilder:(context, index) {
          var data = pendingMatches[index];
          String date = DateFormat('EEE, MMM d, yyyy').format(DateTime.parse(data.bookingDate));
          String time = "${data.startTime.substring(0, 5)} - ${data.endTime.substring(0, 5)}";
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
                        data.venueName,
                        style: boldStyle(whiteTextColor, 28.sp).copyWith(height: 1.0)
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: Color(0xFFF59E0B), size: 15.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              data.futsalVenues.address,
                              style: regularStyle(subtitleTextColor, 14.sp).copyWith(height: 1.0),
                              maxLines: 2,
                              overflow: .ellipsis,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: .start,
                        children: [
                          Icon(Icons.date_range_rounded, color: Color(0xFFF59E0B), size: 15.sp),
                          SizedBox(width: 8.w),
                          Text(
                            '$date | $time',
                            style: TextStyle(
                              color: whiteTextColor,
                              fontSize: 14.sp,
                            ),
                          )
                        ]
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        decoration: BoxDecoration(
                          color: lightFilledBgColor.withValues(alpha: 0.5),
                          borderRadius: .circular(12.r)
                        ),
                        padding: .all(16.sp),
                        child: Text(
                          "Your booking request has been submitted to ${data.venueName} for confirmation. If it is not confirmed within 2 to 3 hours, please feel free to contact the venue owner directly to check on its status.",
                          style: regularStyle(whiteTextColor, 14.sp).copyWith(height: 1.3),
                        )
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: CustomUsualButton(
                              text: 'Call Owner', 
                              onPressed: () => makePhoneCall(data.futsalVenues!.phoneNumber),
                              fontColor: Color(0xFFF59E0B),
                              fontWeight: .w600,
                              fontSize: 16.sp,
                              borderColor: Color(0xFFF59E0B),
                              bgColor: Color(0xFFF59E0B).withValues(alpha: 0.01),
                              height: 52.h,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: CustomUsualButton(
                              text: 'Cancel Booking', 
                              onPressed: () {
                                playerCon.updateBookingStatus(data.id, 'cancelled_player');
                                getBookingsList();
                              },
                              fontColor: Color(0xFFFFB4AB),
                              fontWeight: .w600,
                              fontSize: 16.sp,
                              borderColor: Color(0xFFFFB4AB),
                              bgColor: Color(0xFFFFB4AB).withValues(alpha: 0.01),
                              height: 52.h,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                    ],
                  )
                )
              ]
            )
          );
        }
      );
  }

  Widget pastWidget() {
    return matchHistory.isEmpty
      ? SizedBox(
        height: Get.height * 0.5,
        child: Center(
          child: Text(
            'There are no past matches.',
            style: semiBoldStyle(subtitleTextColor, 14.sp),
          )
        )
      )
      : ListView.separated(
        itemCount: matchHistory.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          var data = matchHistory[index];
          String date = DateFormat('EEE, MMM d, yyyy').format(DateTime.parse(data.bookingDate));
          String time = "${data.startTime.substring(0, 5)} - ${data.endTime.substring(0, 5)}";
          return Container(
            decoration: BoxDecoration(
              color: lightFilledBgColor,
              borderRadius: .circular(12.r)
            ),
            padding: .symmetric(vertical: 16.h, horizontal: 12.w),
            child: Row(
              crossAxisAlignment: .start,
              children: [
                ClipRRect(
                  borderRadius: .circular(12.r),
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
                        data.venueName,
                        style: TextStyle(
                          color: whiteTextColor,
                          fontSize: 20.sp,
                          fontWeight: .w600,
                          height: 1.0
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 8.w),
                      Text(
                        '$date | $time',
                        style: TextStyle(
                          color: subtitleTextColor,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        "Paid: Rs. ${data.totalPrice.toInt()}",
                        style: TextStyle(
                          color: subtitleTextColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      );
  }
}