import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';

class OwnerReports extends StatefulWidget {
  const OwnerReports({super.key});

  @override
  State<OwnerReports> createState() => _OwnerReportsState();
}

class _OwnerReportsState extends State<OwnerReports> {
  String selectedFilter = 'today';

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
                    dateFilterWidget(),
                    SizedBox(height: 16.h),
                    totalCardTiles(),
                    SizedBox(height: 16.h),
                    peakOccupancyTrendWidget(),
                    SizedBox(height: 16.h),
                    recentTransactionWidgets()
                  ],
                )
              )
            )
          )
        )
      )
    );
  }

  Widget dateFilterWidget() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: .circular(12.r)
      ),
      child: Row(
        children: [
          filterWidget(label: 'Today'),
          filterWidget(label: 'This Week'),
          filterWidget(label: 'This Month'),
          filterWidget(label: 'Custom'),
        ]
      ),
    );
  }

  Widget filterWidget({required String label}) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedFilter = label.toLowerCase()),
        child: Container(
          decoration: BoxDecoration(
            color: selectedFilter == label.toLowerCase() ? primaryColor : transparent,
            borderRadius: .circular(12.r)
          ),
          padding: .symmetric(vertical: 12.h),
          child: Center(
            child: Text(
              label,
              style: boldStyle(selectedFilter == label.toLowerCase() ? Color(0xFF107100) : subtitleTextColor, 12.sp),
            ),
          ),
        ),
      ),
    );
  }

  Widget totalCardTiles() {
    return Column(
      mainAxisSize: .max,
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisSize: .max,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: filledBgColor,
                    borderRadius: .circular(24.r),
                    border: .all(color: gray01, width: 0.5)
                  ),
                  padding: .all(16.sp),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'TOTAL REVENUE',
                        style: boldStyle(subtitleTextColor, 12.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Rs. 42500',
                        style: boldStyle(Color(0xFFEFFFE3), 32.sp).copyWith(height: 1.0),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '+12% vs last week',
                        style: boldStyle(primaryTextColor, 14.sp),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(              
                  decoration: BoxDecoration(
                    color: filledBgColor,
                    borderRadius: .circular(24.r),
                    border: .all(color: gray01, width: 0.5)
                  ),
                  padding: .all(16.sp),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'OCCUPANCY RATE',
                        style: boldStyle(subtitleTextColor, 12.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '84%',
                        style: boldStyle(Color(0xFFEFFFE3), 32.sp),
                      ),
                      SizedBox(height: 8.h),
                      LinearProgressIndicator(
                        value: 0.84,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          primaryColor,
                        ),
                        borderRadius: .circular(4.r),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 8.h),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Container(              
                  decoration: BoxDecoration(
                    color: filledBgColor,
                    borderRadius: .circular(24.r),
                    border: .all(color: gray01, width: 0.5)
                  ),
                  padding: .all(16.sp),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'ONLINE BOOKINGS',
                        style: boldStyle(subtitleTextColor, 12.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '32 Matches',
                        style: boldStyle(Color(0xFFEFFFE3), 32.sp).copyWith(height: 1.0),
                      ),
                      SizedBox(height: 8.h),
                      Icon(
                        Icons.sports_soccer,
                        size: 20.sp,
                        color: Color(0xFF2AE500)
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(              
                  decoration: BoxDecoration(
                    color: filledBgColor,
                    borderRadius: .circular(24.r),
                    border: .all(color: gray01, width: 0.5)
                  ),
                  padding: .all(16.sp),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'NO-SHOW RATE',
                        style: boldStyle(subtitleTextColor, 12.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '2%',
                        style: boldStyle(Color(0xFFFFB4AB), 32.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Minimal Impact',
                        style: regularStyle(subtitleTextColor, 14.sp),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ]
    );
  }

  Widget peakOccupancyTrendWidget() {
    return Container(
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: .circular(24.r),
        border: .all(color: gray01, width: 0.5)
      ),
      padding: .all(16.sp),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            'Peak Occupancy Trends',
            style: semiBoldStyle(Color(0xFFEFFFE3), 20.sp)
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                'Evening (5 PM - 9 PM)',
                style: regularStyle(whiteTextColor, 16.sp),
              ),
              Text(
                '98% Filled',
                style: boldStyle(primaryTextColor, 12.sp),
              )
            ],
          ),
          SizedBox(height: 4.h),
          LinearProgressIndicator(
            value: 0.98,
            minHeight: 16.h,
            backgroundColor: Color(0xFF2D3828),
            valueColor: AlwaysStoppedAnimation<Color>(
              primaryColor,
            ),
            borderRadius: .circular(8.r),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                'Morning (6 AM - 10 AM)',
                style: regularStyle(whiteTextColor, 16.sp),
              ),
              Text(
                '45% Filled',
                style: boldStyle(subtitleTextColor, 12.sp),
              )
            ],
          ),
          SizedBox(height: 4.h),
          LinearProgressIndicator(
            value: 0.45,
            minHeight: 16.h,
            backgroundColor: Color(0xFF2D3828),
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFF3F465C)
            ),
            borderRadius: .circular(8.r),
          )
        ]
      )
    );
  }

  Widget recentTransactionWidgets() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: .end,
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: semiBoldStyle(Color(0xFFEFFFE3), 20.sp),
            ),
            Text(
              'VIEW ALL',
              style: boldStyle(primaryTextColor, 12.sp),
            )
          ],
        ),
        SizedBox(height: 8.h),
        ListView.separated(
          shrinkWrap: true,
          itemCount: 3,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
          itemBuilder:(context, index) {
            return Container(
              decoration: BoxDecoration(
                color: filledBgColor,
                borderRadius: .circular(24.r),
                border: .all(color: gray01, width: 0.5)
              ),
              padding: .all(16.sp),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    'Payout - September 14, 2026',
                    style: semiBoldStyle(whiteTextColor, 20.sp),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: primaryColor, size: 12.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Direct Bank Transfer Completed',
                          style: regularStyle(subtitleTextColor, 16.sp).copyWith(height: 1.0),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Rs. 12000',
                          style: semiBoldStyle(primaryColor, 16.sp).copyWith(height: 1.0),
                        ),
                      ),
                    ],
                  )
                ]
              )
            );
          },
        )
      ],
    ); 
  }

}