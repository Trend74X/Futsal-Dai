import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:get/get.dart';

class OwnerPendingAll extends StatefulWidget {
  const OwnerPendingAll({super.key});

  @override
  State<OwnerPendingAll> createState() => _OwnerPendingAllState();
}

class _OwnerPendingAllState extends State<OwnerPendingAll> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  appbarWidget(),
                  SizedBox(height: 8.h),
                  pendingConfirmation(),
                  Padding(
                    padding: .all(16.sp),
                    child: Column(
                      children: [
                        pendingCardWidget(name: 'Anish Shrestha', noOfMatch: 82, courtName: 'Court 1', time: 'Today 7:00 PM', phone: 9806503201, remTime: '08:45'),
                        SizedBox(height: 16.h),
                        pendingCardWidget(name: 'Priya Thapa', noOfMatch: 57, courtName: 'Court 2', time: 'Today 8:30 PM', phone: 9876543210, remTime: '12:10'),
                        SizedBox(height: 16.h),
                        pendingCardWidget(name: 'Abhishek Bajracharya', noOfMatch: 25, courtName: '7*7 premium court 1', time: 'Today 8:30 PM', phone: 9876543210, remTime: '12:10')
                      ],
                    ),
                  )
                ],
              ),
            )
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
        Text('Pending', style: boldStyle(primaryTextColor, 28.sp)),
        SizedBox(width: 1),
      ],
    );
  }

  Widget pendingConfirmation() {
    return Container(
      color: lightFilledBgColor,
      padding: .symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: .center,
        mainAxisAlignment: .spaceBetween,
        children: [
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                'PENDING CONFIRMATIONS',
                style: boldStyle(Color(0xFF895600), 12.sp),
              ),
              Row(
                children: [
                  Icon(Icons.warning_amber, color: Color(0xFF895600)),
                  SizedBox(width: 4.w),
                  Text(
                    'Call player within 15 mins to confirm.',
                    style: regularStyle(subtitleTextColor, 14.sp),
                  )
                ],
              )
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFD6A8).withValues(alpha: 0.2),
              borderRadius: .circular(24.r),
              border: .all(
                color: Color(0xFF895600)
              )
            ),
            padding: .symmetric(vertical: 4.h, horizontal: 8.w),
            child: Text(
              '3 NEW',
              style: boldStyle(Color(0xFF895600), 12.sp)
            ),
          )
        ],
      ),
    );
  }

  Widget pendingCardWidget({
    required String name,
    required int noOfMatch,
    required String courtName,
    required String time,
    required int phone,
    required String remTime
  }) {
    return Container(
      decoration: BoxDecoration(
        color: filledBlueColor,
        borderRadius: .circular(24.r)
      ),
      padding: .all(16.sp),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Container(
                height: 46.h,
                width: 46.w,
                decoration: BoxDecoration(
                  shape: .circle,
                  color: filledBgColor
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      name,
                      style: boldStyle(whiteTextColor, 16.sp)
                    ),
                    Text(
                      'No. of Matches: $noOfMatch',
                      style: regularStyle(subtitleTextColor, 12.sp)
                    )
                  ],
                ),
              ),
              Spacer(),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      courtName,
                      maxLines: 2,
                      style: regularStyle(whiteTextColor, 16.sp)
                    ),
                    Text(
                      time,
                      style: boldStyle(primaryColor, 12.sp)
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: .infinity,
            height: 138.h,
            decoration: BoxDecoration(
              color: Color(0xFFFFD6A8).withValues(alpha: 0.05),
              borderRadius: .circular(24.r)
            ),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Text(
                  phone.toString(),
                  style: boldStyle(Color(0xFF653E00), 12.sp)
                ),
                SizedBox(height: 16.h),
                Container(
                  height: 56.h,
                  width: 258.w,
                  decoration: BoxDecoration(
                    color: Color(0xffFFD6A8),
                    borderRadius: .circular(12.r)
                  ),
                  child: Row(
                    mainAxisAlignment: .center,
                    children: [
                      Icon(Icons.call, color: Color(0xFF895600)),
                      SizedBox(width: 12.w),
                      Text(
                        'TAP TO CALL PLAYER',
                        style: regularStyle(Color(0xFF895600), 16.sp),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Column(
            children: [
              Row(
                children: [
                  Text(
                    'HOLD TIME REMAINING',
                    style: regularStyle(Color(0xFF895600), 10.sp),
                  ),
                  Spacer(),
                  Text(
                    '$remTime left',
                    style: boldStyle(Color(0xFF895600), 12.sp),
                  )
                ],
              ),
              SizedBox(height: 4.h),
              LinearProgressIndicator(
                value: 0.7, // Connects to the 5-second sequence
                backgroundColor: Colors.white.withValues(alpha: 0.15), // Muted track trail
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xffFFD6A8), // Uses your style helper's main text or highlight color
                ),
              )
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: gray01, thickness: 1.sp),
          SizedBox(height: 12.h),
          Row(
            children: [
              btnWidgets(icon: Icons.cancel_outlined, label: 'REJECT', onTap: () {}),
              SizedBox(width: 8.w),
              btnWidgets(icon: Icons.check_circle_outline, label: 'APPROVE', onTap: () {})
            ],
          )
        ],
      ),
    );
  }

  Widget btnWidgets({
    required IconData icon,
    required String label,
    required VoidCallback onTap
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: label == 'REJECT' ? transparent : primaryColor,
            borderRadius: .circular(12.r),
            border: .all(
              color: subtitleTextColor
            )
          ),
          padding: .symmetric(vertical: 16.h, horizontal: 12.w),
          child: Row(
            mainAxisAlignment: .center,
            children: [
              Icon(icon, color: label == 'REJECT' ? subtitleTextColor : Color(0xFF107100)),
              SizedBox(width: 4.w),
              Text(
                'REJECT',
                style: regularStyle(label == 'REJECT' ? subtitleTextColor : Color(0xFF107100), 16.sp),
              )
            ],
          ),
        ),
      ),
    );
  }

}