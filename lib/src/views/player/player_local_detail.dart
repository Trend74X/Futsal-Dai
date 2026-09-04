import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/group_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';
import 'package:futsal_dai/src/widgets/display_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PlayerLocalDetail extends StatefulWidget {
  final String postId;
  final dynamic details;
  const PlayerLocalDetail({super.key, required this.postId, required this.details});

  @override
  State<PlayerLocalDetail> createState() => _PlayerLocalDetailState();
}

class _PlayerLocalDetailState extends State<PlayerLocalDetail> {
  final controller = Get.put(GroupController());
  List pendingRequests = [];
  List confirmedPlayers = [];

  @override
  void initState() {
    super.initState();
    getPlayersList();
  }

  Future<void> getPlayersList() async {
    List players = await controller.fetchMatchJoinRequests(widget.postId);
    pendingRequests = players.where((req) => req['status'] == 'pending').toList();
    confirmedPlayers = players.where((req) => req['status'] == 'accepted' || req['status'] == 'confirmed').toList();
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(title: 'Recruitment'),
      extendBodyBehindAppBar: true,
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
                    futsalDetail(),
                    SizedBox(height: 12.h),
                    slotDetail(),
                    SizedBox(height: 16.h),
                    requesWidget(),
                    SizedBox(height: 8.h),
                    confirmedSqudWidget()
                  ]
                )
              )
            )
          )
        )
      )
    );
  }

  Widget futsalDetail() {
    return Container(
      decoration: BoxDecoration(
        color: lightFilledBgColor,
        borderRadius: .circular(12.r)
      ),
      padding: .all(16.sp),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          SizedBox(
            height: 128.h,
            width: .infinity,
            child: ClipRRect(
              borderRadius: .circular(12.r),
              child: SizedBox(
                height: 64.h,
                width: 64.w,
                child: Image.asset(
                  'assets/images/court.png',
                  fit: .cover,
                )
              )
            )
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: .circular(4.r)
            ),
            padding: .symmetric(vertical: 2.h, horizontal: 4.w),
            child: Text(
              'ACTIVE',
              style: boldStyle(black, 12.sp),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.details['venue_name'],
            style: semiBoldStyle(whiteTextColor, 28.sp).copyWith(height: 1.0),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: .start,
            children: [
              Icon(Icons.calendar_today, color: primaryColor, size: 15.sp),
              SizedBox(width: 4.w),
              Text(
                formatBookingDateTime(
                  widget.details['booking_date'], 
                  widget.details['start_time'], 
                  widget.details['end_time']
                ),
                // 'Fri, Oct 27 · 20:00 - 22:00',
                style: semiBoldStyle(subtitleTextColor, 14.sp),
              )
            ],
          ),
          SizedBox(height: 4.h),
          Visibility(
            visible: widget.details['address'] != null,
            child: Row(
              crossAxisAlignment: .start,
              children: [
                Icon(Icons.location_on_outlined, color: primaryColor, size: 15.sp),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    widget.details['address'] ?? '',
                    style: semiBoldStyle(subtitleTextColor, 14.sp).copyWith(height: 1.2),
                    maxLines: 2
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget slotDetail() {
    return Container(
      decoration: BoxDecoration(
        color: filledBlueColor,
        borderRadius: .circular(12.r),
        border: .all(color: gray01)
      ),
      padding: .all(16.sp),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            'SLOTS NEEDED',
            style: regularStyle(subtitleTextColor, 14.sp)
          ),
          SizedBox(height: 12.h),
          Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: (widget.details['slots_needed'] - confirmedPlayers.length).toString(),
                    style: boldStyle(primaryColor, 48.sp),
                  ),
                  // WidgetSpan(child: SizedBox(width: 8.w)),
                  TextSpan(
                    text: " / ${widget.details['slots_needed']}",
                    style: semiBoldStyle(subtitleTextColor, 20.sp),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: 2/5,
            minHeight: 8.h,
            valueColor: AlwaysStoppedAnimation<Color>(
              primaryTextColor
            ),
            backgroundColor: Colors.white.withValues(alpha: 0.15),
          ),
          SizedBox(height: 16.h),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF93000A),
              borderRadius: .circular(8.r)
            ),
            padding: .symmetric(vertical: 8.h),
            child: Row(
              mainAxisAlignment: .center,
              children: [
                Icon(Icons.not_interested_outlined, color: whiteTextColor),
                SizedBox(width: 8.w),
                Text(
                  'Stop Recruitment',
                  style: boldStyle(whiteTextColor, 12.sp)
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget requesWidget() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.email_outlined, color: Color(0xFFFFB95F), size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Inbound Requests',
              style: semiBoldStyle(whiteTextColor, 20.sp)
            )
          ],
        ),
        Divider(color: gray01),
        pendingRequests.isEmpty
          ? SizedBox(
            height: 50.h,
            child: Center(
              child: Text(
                'No request at the moment.',
                style: boldStyle(gray03, 14.sp),
              )
            )
          )
          : ListView.separated(
            itemCount: pendingRequests.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder:(context, index) => SizedBox(height: 8.h), 
            itemBuilder:(context, index) {
              var data = pendingRequests[index];
              return inboundTileWidget(data);
            }, 
          )
      ],
    );
  }

  Widget inboundTileWidget(dynamic data) {
    return Container(
      decoration: BoxDecoration(
        color: filledBlueColor,
        borderRadius: .circular(12.r), // Fixed shortcut syntax
      ),
      padding: .symmetric(vertical: 16.h, horizontal: 8.w), // Fixed shortcut syntax
      child: Row(
        crossAxisAlignment: .center,
        children: [
          // 1. Avatar container
          Container(
            height: 48.h, 
            width: 48.w,
            decoration: BoxDecoration(
              color: lightFilledBgColor,
              shape: .circle, // Fixed shortcut syntax
            ),
            child: ClipRRect(
              borderRadius: .circular(24.r),
              child: DisplayNetworkImage(
                imageUrl: data['player']['profile_pic'],
                boxFit: .cover,
              ),
            )
          ),
          SizedBox(width: 8.w), // Slightly increased spacing for better breathing room

          // 2. Name & Handle Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: .start, // Fixed shortcut syntax
              mainAxisSize: .min,
              children: [
                Text(
                  data['player']['full_name'],
                  style: semiBoldStyle(whiteTextColor, 18.sp).copyWith(height: 1.0),
                ),
                SizedBox(height: 2.h), // Added small gap between text lines
                Text(
                  '@${data['player']['username']}',
                  style: semiBoldStyle(subtitleTextColor, 12.sp),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // 3. Action Buttons pushed to the end
          Row(
            mainAxisSize: .min,
            children: [
              Container(
                height: 40.h,
                width: 40.w, 
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: .circle,
                ),
                child: Icon(Icons.check, color: black, size: 20.sp),
              ),
              SizedBox(width: 8.w),
              Container(
                height: 40.h,
                width: 40.w,
                decoration: BoxDecoration(
                  color: Color(0xFFFFB4AB).withValues(alpha: 0.05),
                  shape: .circle,
                  border: .all(color: Color(0xFFFFB4AB).withValues(alpha: 0.5)),
                ),
                child: Icon(Icons.close, color: Color(0xFFFFB4AB), size: 20.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget confirmedSqudWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align title and divider to the left
      children: [
        Row(
          children: [
            Icon(Icons.verified, color: primaryColor, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Confirmed Squad',
              style: semiBoldStyle(whiteTextColor, 20.sp),
            )
          ],
        ),
        Divider(color: gray01),
        
        // 👇 FIXED: Added shrinkWrap and physics
        GridView.builder(
          itemCount: widget.details['slots_needed'],
          shrinkWrap: true, // Makes the grid wrap its content height
          physics: const NeverScrollableScrollPhysics(), // Disables grid's own scroll; parent handles it
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 2.6,
          ),
          itemBuilder: (context, index) {
            var data = index < confirmedPlayers.length ? confirmedPlayers[index] : '';
            return Container(
              decoration: BoxDecoration(
                color: filledBgColor,
                borderRadius: .circular(12.r),
                border: .all(color: gray01)
              ),
              padding: .symmetric(horizontal: 4.w),
              child: data == ''
                ? Center(
                  child: Text(
                    'Slot still available.',
                    style: boldStyle(gray03, 14.sp),
                    maxLines: 2
                  )
                )
                : Row(
                  children: [
                    Container(
                      height: 42.h, width: 42.w,
                      decoration: BoxDecoration(
                        color: lightFilledBgColor,
                        shape: .circle
                      ),
                      child: ClipRRect(
                        borderRadius: .circular(24.r),
                        child: DisplayNetworkImage(
                          imageUrl: data['player']['profile_pic'],
                          boxFit: .cover,
                        ),
                      )
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        mainAxisAlignment: .center,
                        children: [
                          Text(
                            data['player']['full_name'],
                            style: boldStyle(whiteTextColor, 14.sp).copyWith(height: 1.0),
                            maxLines: 2,
                          ),
                          Text(
                            '@${data['player']['username']}',
                            style: boldStyle(subtitleTextColor, 12.sp)
                          )
                        ],
                      )
                    )
                  ],
                ),
            );
          }, 
        ),
      ],
    );
  }

  String formatBookingDateTime(String bookingDate, String startTime, String endTime) {
    try {
      // Parse the date string (e.g., "2026-09-05")
      DateTime date = DateTime.parse(bookingDate);
      
      // Format date to "EEE, MMM d" -> Fri, Sep 5
      String formattedDate = DateFormat('EEE, MMM d').format(date);
      
      // Trim seconds from time strings ("06:00:00" -> "06:00")
      String formattedStart = startTime.length >= 5 ? startTime.substring(0, 5) : startTime;
      String formattedEnd = endTime.length >= 5 ? endTime.substring(0, 5) : endTime;
      
      return '$formattedDate · $formattedStart - $formattedEnd';
    } catch (e) {
      return 'Invalid Date/Time';
    }
  }

}