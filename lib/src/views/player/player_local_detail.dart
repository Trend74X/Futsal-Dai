import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';

class PlayerLocalDetail extends StatefulWidget {
  const PlayerLocalDetail({super.key});

  @override
  State<PlayerLocalDetail> createState() => _PlayerLocalDetailState();
}

class _PlayerLocalDetailState extends State<PlayerLocalDetail> {
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
            'Stadium Arena',
            style: semiBoldStyle(whiteTextColor, 20.sp).copyWith(height: 1.2),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: .start,
            children: [
              Icon(Icons.calendar_today, color: primaryColor, size: 15.sp),
              SizedBox(width: 4.w),
              Text(
                'Fri, Oct 27 · 20:00 - 22:00',
                style: regularStyle(subtitleTextColor, 14.sp),
              )
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            crossAxisAlignment: .start,
            children: [
              Icon(Icons.location_on_outlined, color: primaryColor, size: 15.sp),
              SizedBox(width: 4.w),
              Text(
                'Downtown Pitch A',
                style: regularStyle(subtitleTextColor, 14.sp),
              )
            ],
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
                    text: "2",
                    style: boldStyle(primaryColor, 48.sp),
                  ),
                  // WidgetSpan(child: SizedBox(width: 8.w)),
                  TextSpan(
                    text: " / 5",
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
          SizedBox(height: 12.h),
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
        ListView.separated(
          itemCount: 3,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder:(context, index) => SizedBox(height: 8.h), 
          itemBuilder:(context, index) {
            return inboundTileWidget();
          }, 
        )
      ],
    );
  }

  Widget inboundTileWidget() {
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
          ),
          SizedBox(width: 8.w), // Slightly increased spacing for better breathing room

          // 2. Name & Handle Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: .start, // Fixed shortcut syntax
              mainAxisSize: .min,
              children: [
                Text(
                  'Rohan Shakya',
                  style: semiBoldStyle(whiteTextColor, 18.sp).copyWith(height: 1.0),
                ),
                SizedBox(height: 2.h), // Added small gap between text lines
                Text(
                  '@rohan_shakya',
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
          itemCount: 5,
          shrinkWrap: true, // Makes the grid wrap its content height
          physics: const NeverScrollableScrollPhysics(), // Disables grid's own scroll; parent handles it
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 2.6,
          ),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: filledBgColor,
                borderRadius: .circular(12.r),
                border: .all(color: gray01)
              ),
              padding: .symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Container(
                    height: 42.h, width: 42.w,
                    decoration: BoxDecoration(
                      color: lightFilledBgColor,
                      shape: .circle
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      mainAxisAlignment: .center,
                      children: [
                        Text(
                          'Ashok Shakya',
                          style: boldStyle(whiteTextColor, 14.sp).copyWith(height: 1.0),
                          maxLines: 2,
                        ),
                        Text(
                          '@trend74x',
                          style: boldStyle(subtitleTextColor, 12.sp)
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          }, 
        ),
      ],
    );
  }

}