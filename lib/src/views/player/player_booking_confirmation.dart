import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';

class PlayerBookingConfirm extends StatelessWidget {
  const PlayerBookingConfirm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(16.sp),
      width: double.infinity,
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: .vertical(top: .circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Text(
                'Booking Confirmation',
                style: TextStyle(fontSize: 20.sp, fontWeight: .w600, color: whiteTextColor),
              ),
              Spacer(),
              IconButton(
                onPressed: () => Get.back(), 
                icon: Icon(Icons.close, color: whiteTextColor)
              )
            ],
          ),
          const SizedBox(height: 20),
          imageCard(),
          const SizedBox(height: 20),
          timeCards(),
          const SizedBox(height: 20),
          priceWidget(),
          const SizedBox(height: 20),
          verificationWidget(),
          const SizedBox(height: 20),
          reqBookingBtnWidget(),
          const SizedBox(height: 20),
          cancellationTextWidget(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget imageCard() {
    return Stack(
      alignment: .bottomLeft,
      children: [
        Image.asset(
          'assets/images/court.png',
          fit: .cover,
        ),
        Padding(
          padding: .symmetric(vertical: 16.h, horizontal: 16.w),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Container(
                width: 61.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: .circular(4.r)
                ),
                child: Center(
                  child: Text(
                    'VENUE',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 12.sp,
                      fontWeight: .bold
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Prismatic Futsal & Recreation Center',
                style: TextStyle(
                  color: whiteTextColor,
                  fontWeight: .bold,
                  fontSize: 28.sp,
                  height: 1.1
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget timeCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: lightFilledBgColor,
              borderRadius: .circular(12.r)
            ),
            child: Padding(
              padding: .symmetric(vertical: 16.h, horizontal: 16.w),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.date_range, color: whiteTextColor),
                      SizedBox(width: 4.w),
                      Text(
                        'DATE',
                        style: TextStyle(
                          color: whiteTextColor,
                          fontSize: 12.sp,
                          fontWeight: .bold
                        ),
                      )
                    ]
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Sat, Dec 14',
                    style: TextStyle(
                      color: whiteTextColor,
                      fontSize: 20.sp,
                      fontWeight: .w600
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: lightFilledBgColor,
              borderRadius: .circular(12.r)
            ),
            child: Padding(
              padding: .symmetric(vertical: 16.h, horizontal: 16.w),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: whiteTextColor),
                      SizedBox(width: 4.w),
                      Text(
                        'TIME',
                        style: TextStyle(
                          color: whiteTextColor,
                          fontSize: 12.sp,
                          fontWeight: .bold
                        ),
                      )
                    ]
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '17:00 - 18:00',
                    style: TextStyle(
                      color: whiteTextColor,
                      fontSize: 20.sp,
                      fontWeight: .w600
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget priceWidget() {
    return Container(
      decoration: BoxDecoration(
        color: lightFilledBgColor,
        borderRadius: .circular(12.r)
      ),
      child: Padding(
        padding: .all(16.sp),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  'Weekend Peak Rate',
                  style: TextStyle(
                    color: Color(0xFFADB4CE),
                    fontWeight: .bold, 
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  'Standard 1 hour slot',
                  style: TextStyle(
                    color: whiteTextColor,
                    fontSize: 14.sp,
                  ),
                )
              ],
            ),
            Spacer(),
            Text(
              'Rs. 1300',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 28.sp,
                fontWeight: .bold
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget verificationWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFFD6A8).withValues(alpha: 0.1),
        borderRadius: .circular(12.r)
      ),
      padding: .symmetric(vertical: 16.h, horizontal: 16.w),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Icon(Icons.verified_user_outlined, color: brownTextColor),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  'Verification Required',
                  style: TextStyle(
                    color: Color(0xFFFFDDB8),
                    fontSize: 12.sp,
                    fontWeight: .bold
                  ),
                ),
                Text(
                  'Note: Owner will call your phone to verify identity and confirm the booking request.',
                  style: TextStyle(
                    color: whiteTextColor,
                    fontSize: 14.sp,
                    height: 1.2
                  ),
                  maxLines: 3,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget reqBookingBtnWidget() {
    return Center(
      child: CustomUsualButton(
        text: 'REQUEST BOOOKING SLOT', 
        onPressed: () {},
        fontColor: Color(0xFF053900),
        fontSize: 18.sp,
        color: primaryTextColor,
      ),
    );
  }

  Widget cancellationTextWidget() {
    return Center(
      child: Text(
        'Cancelation policy applies. 15m grace period.',
        style: TextStyle(
          fontWeight: .bold,
          fontSize: 12.sp,
          color: subtitleTextColor.withValues(alpha: 0.5)
        ),
      ),
    );
  }

}