import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:futsal_dai/src/helper/constant.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:get/get.dart';

class PlayerTransactions extends StatelessWidget {
  const PlayerTransactions({super.key});

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
                    totalTilesCard(),
                    SizedBox(height: 16.h),
                    transactionHistory(),
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
        Text('TRANSACTIONS', style: boldStyle(primaryTextColor, 28.sp)),
        SizedBox(),
      ],
    );
  }

  Widget totalTilesCard() {
    return Container(
      decoration: BoxDecoration(
        color: filledBlueColor.withValues(alpha: 0.8),
        borderRadius: .circular(12.r),
      ),
      padding: .symmetric(vertical: 24.sp, horizontal: 24.sp),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text('TOTAL SPEND', style: boldStyle(subtitleTextColor, 12.sp)),
          Row(
            crossAxisAlignment: .center,
            children: [
              Text('Rs. 8450', style: boldStyle(primaryTextColor, 28.sp)),
              SizedBox(width: 8.w),
              Text('This Year', style: boldStyle(subtitleTextColor, 14.sp)),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                height: 26.h,
                width: 26.w,
                decoration: BoxDecoration(
                  shape: .circle,
                  color: primaryColor.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Text(
                    '12',
                    style: regularStyle(primaryTextColor, 10.sp),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Completed Bookings',
                style: regularStyle(subtitleTextColor, 14.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget transactionHistory() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: transactions.length,
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        var data = transactions[index];
        return Column(
          children: [
            Padding(
              padding: .symmetric(vertical: 12.h, horizontal: 8.w),
              child: Row(
                children: [
                  Container(color: primaryTextColor, height: 16.h, width: 4.w),
                  SizedBox(width: 8.w),
                  Text(
                    data['date'],
                    style: boldStyle(Color(0xFF2AE500), 12.sp),
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              itemCount: data['data'].length,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (subCtx, subIdx) => SizedBox(height: 8.h),
              itemBuilder: (subCtx, subIdx) {
                var subdata = data['data'][subIdx];
                return listTileCard(subdata);
              },
            ),
          ],
        );
      },
    );
  }

  Widget listTileCard(dynamic data) {
    return Container(
      decoration: BoxDecoration(
        color: filledBlueColor.withValues(alpha: 0.8),
        borderRadius: .circular(12.r),
      ),
      padding: .symmetric(vertical: 12.h, horizontal: 12.w),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: lightFilledBgColor.withValues(alpha: 0.3),
              borderRadius: .circular(8.r),
            ),
            padding: .symmetric(vertical: 12.h, horizontal: 12.w),
            child: SvgPicture.asset(
              'assets/icons/player.svg',
              width: 20.w,
              height: 20.h,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(data['status'] == 'SUCCESSFUL' ? primaryColor : whiteTextColor, BlendMode.srcIn),
            )
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  data['name'],
                  style: semiBoldStyle(
                    whiteTextColor,
                    16.sp,
                  ).copyWith(height: 1.0),
                ),
                SizedBox(height: 4.h),
                Text(
                  "${data['date']} • ${data['time']}",
                  style: regularStyle(subtitleTextColor, 14.sp),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: Get.width * 0.25,
            child: Column(
              crossAxisAlignment: .end,
              children: [
                Text(
                  "Rs. ${data['price']}",
                  style: semiBoldStyle(
                    data['status'] == 'SUCCESSFUL'
                        ? Color(0xFF2AE500)
                        : whiteTextColor,
                    16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  decoration: BoxDecoration(
                    color: data['status'] == 'SUCCESSFUL'
                        ? primaryColor.withValues(alpha: 0.1)
                        : filledBgColor,
                    borderRadius: .circular(12.r),
                  ),
                  padding: .symmetric(vertical: 4.h, horizontal: 12.w),
                  child: Text(
                    data['status'],
                    style: boldStyle(
                      data['status'] == 'SUCCESSFUL'
                          ? Color(0xFF2AE500)
                          : whiteTextColor,
                      10.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
