import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/url_launcher_helper.dart';
import 'package:futsal_dai/src/views/owner/owner_pending_all.dart';
import 'package:futsal_dai/src/views/owner/owner_slot_entry.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: Padding(
            padding: EdgeInsets.only(top: 16.sp, left: 16.sp, right: 16.sp),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    todayCardsWidget(),
                    SizedBox(height: 16.h),
                    pendingQueueWidget(),
                    SizedBox(height: 16.h),
                    timeLine()
                  ],
                )
              )
            )
          )
        ),
      ),
    );
  }

  Widget todayCardsWidget() {
    return Row(
      children: [
        cardsToday(icon: 'assets/icons/ball.png', title: '24', subtitle: 'BOOKINGS TODAY', color: primaryColor),
        SizedBox(width: 16.w),
        cardsToday(icon: 'assets/icons/money.png', title: '12.4k', subtitle: 'REVENUE TODAY', color: Color(0xFFFFB95F))
      ],
    );
  }

  Widget cardsToday({required String icon, required String title, required String subtitle, required Color color}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: filledBgColor
        ),
        padding: .symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Image.asset(
              icon,
              height: 20.h,
              width: 20.w,
            ),
            Text(
              title,
              style: boldStyle(color, 48.sp),
            ),
            Text(
              subtitle,
              style: boldStyle(subtitleTextColor, 12.sp),
            )
          ],
        ),
      ),
    );
  }

  Widget pendingQueueWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Fixed syntax from .start
      children: [
        Row(
          children: [
            Text(
              'Pending Queue',
              style: semiBoldStyle(whiteTextColor, 20.sp),
            ),
            SizedBox(width: 8.w),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF93000A),
                borderRadius: BorderRadius.circular(24.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Text(
                '3 NEW',
                style: boldStyle(whiteTextColor, 10.sp),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () => Get.to(() => OwnerPendingAll()),
              child: Text(
                'SEE ALL',
                style: boldStyle(primaryColor, 12.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        
        // Horizontal List View container height adjusted to safely fit contents
        SizedBox(
          height: 210.h, 
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: 3,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (ctx, idx) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              return pendingQueCard();
            },
          ),
        ),
      ],
    );
  }

  Widget pendingQueCard() {
    return Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Container(
                height: 40.h,
                width: 40.w,
                decoration: const BoxDecoration(
                  shape: .circle,
                  color: Color(0xFF3F465C),
                ),
                child: Center(
                  child: Text(
                    'A',
                    style: boldStyle(Color(0xFFADB4CE), 20.sp),
                  ),
                )
              ),
              SizedBox(width: 8.w),
              
              // Pushes call icon to the far right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ashok Shakya',
                      style: semiBoldStyle(whiteTextColor, 20.sp).copyWith(height: 1.0),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '9876543210',
                      style: semiBoldStyle(whiteTextColor, 14.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              
              InkWell(
                onTap: () => makePhoneCall('9876543210'),
                child: Container(
                  height: 40.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.call_outlined, color: primaryColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // TODAY Banner (stretches to card full width automatically now)
          Container(
            height: 32.h,
            decoration: BoxDecoration(
              color: lightFilledBgColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
            child: Row(
              children: [
                Icon(Icons.access_time, color: primaryColor),
                SizedBox(width: 8.w),
                Text(
                  'TODAY | 19:00 - 20:00',
                  style: boldStyle(whiteTextColor, 12.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          
          // Action Buttons (Using Expanded so they fit cleanly inside 280.w width)
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CustomUsualButton(
                    text: 'APPROVE', 
                    onPressed: () {},
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    height: 42.h,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomUsualButton(
                    text: 'REJECT', 
                    onPressed: () {},
                    bgColor: Colors.transparent,
                    fontSize: 14.sp,
                    fontColor: whiteTextColor,
                    borderColor: const Color(0xFF3C4B35),
                    height: 42.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget timeLine() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Timeline',
              style: semiBoldStyle(whiteTextColor, 20.sp),
            ),
            Row(
              children: [
                _buildHeaderBadge('COURT A', isLive: false),
                const SizedBox(width: 8),
                _buildHeaderBadge('LIVE', isLive: true),
              ],
            )
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: filledBgColor,
            borderRadius: .circular(12.r)
          ),
          padding: .symmetric(vertical: 16.h, horizontal: 16.w),
          child: Column(
            children: [
              timeLineTile(time: '16:00', status: 'Completed', subtitle: 'Team Wolves'),
              SizedBox(height: 8.h),
              timeLineTile(time: '17:00', status: 'IN PROGESS', subtitle: 'Strikers FC'),
              SizedBox(height: 8.h),
              timeLineTile(time: '18:00', status: 'AVAILABLE'),
              SizedBox(height: 8.h),
              timeLineTile(time: '17:00', status: 'Booked', subtitle: 'Corporate Group A'),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHeaderBadge(String label, {required bool isLive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLive ? primaryColor.withValues(alpha: 0.2) : whiteTextColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isLive ? primaryColor : whiteTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
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
        Text(
          time,
          style: boldStyle(status == 'Completed' ? gray02 : subtitleTextColor, 12.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Container(
            height: 80.h,
            decoration: BoxDecoration(
              color: status == 'AVAILABLE' 
                      ? transparent 
                      : status == 'Completed'
                        ? lightFilledBgColor
                        : status == 'IN PROGESS'
                          ? primaryColor.withValues(alpha: 0.2)
                          : filledBgColor,
              borderRadius: .circular(8.r),
              border: .all(
                color: subtitleTextColor.withValues(alpha: 0.5),
              )
            ),
            child: status == 'AVAILABLE' || status == 'EMPTY'
                    ? InkWell(
                      onTap: () => Get.to(() => OwnserMaunualSlotEntry()),
                      child: Row(
                        mainAxisAlignment: .center,
                        children: [
                          Icon(Icons.add, color: subtitleTextColor),
                          Text(
                            status!,
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
                          color: status == 'Completed'
                                  ? subtitleTextColor
                                  : status == 'IN PROGESS'
                                    ? primaryColor
                                    : textBlue,
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          mainAxisAlignment: .center,
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              status!,
                              style: boldStyle(status == 'IN PROGESS' ? primaryColor : whiteTextColor, 12.sp),
                            ),
                            subtitle == null 
                              ? SizedBox()
                              : Text(
                                subtitle,
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

}