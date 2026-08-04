import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/owner_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/timer_helper.dart';
import 'package:futsal_dai/src/helper/url_launcher_helper.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';
import 'package:futsal_dai/src/widgets/display_image.dart';
import 'package:get/get.dart';

class OwnerPendingAll extends StatefulWidget {
  const OwnerPendingAll({super.key});

  @override
  State<OwnerPendingAll> createState() => _OwnerPendingAllState();
}

class _OwnerPendingAllState extends State<OwnerPendingAll> {

  final OwnerController ownerCon = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(title: 'Pending'),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  // SizedBox(height: 8.h),
                  // pendingConfirmation(),
                  Padding(
                    padding: .all(16.sp),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: ownerCon.pendingBookings.length,
                      physics: NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => SizedBox(height: 16.h),
                      itemBuilder:(context, index) {
                        var data = ownerCon.pendingBookings[index];
                        return pendingCardWidget(
                          name: data['Users']['full_name'],
                          bookingId: data['id'], 
                          courtName: data['ground_name'],
                          time: getTime(date: data['booking_date'], time: data['start_time']), // 'Today ${data['start_time']}', 
                          phone: data['Users']['phone_number'], 
                          // remTime: '08:45',
                          profilePic: data['Users']['profile_pic']
                        );
                      },
                    )
                  )
                ],
              ),
            )
          ),
        ),
      ),
    );
  }

  // Widget pendingConfirmation() {
  //   return Container(
  //     color: lightFilledBgColor,
  //     padding: .symmetric(horizontal: 12.w, vertical: 8.h),
  //     child: Row(
  //       crossAxisAlignment: .center,
  //       mainAxisAlignment: .spaceBetween,
  //       children: [
  //         Column(
  //           crossAxisAlignment: .start,
  //           children: [
  //             Text(
  //               'PENDING CONFIRMATIONS',
  //               style: boldStyle(Color(0xFF895600), 12.sp),
  //             ),
  //             Row(
  //               children: [
  //                 Icon(Icons.warning_amber, color: Color(0xFF895600)),
  //                 SizedBox(width: 4.w),
  //                 Text(
  //                   'Call player within 15 mins to confirm.',
  //                   style: regularStyle(subtitleTextColor, 14.sp),
  //                 )
  //               ],
  //             )
  //           ],
  //         ),
  //         Container(
  //           decoration: BoxDecoration(
  //             color: Color(0xFFFFD6A8).withValues(alpha: 0.2),
  //             borderRadius: .circular(24.r),
  //             border: .all(
  //               color: Color(0xFF895600)
  //             )
  //           ),
  //           padding: .symmetric(vertical: 4.h, horizontal: 8.w),
  //           child: Text(
  //             '${ownerCon.pendingBookings.length} NEW',
  //             style: boldStyle(Color(0xFF895600), 12.sp)
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget pendingCardWidget({
    required String name,
    required String bookingId,
    required String courtName,
    required String time,
    required String phone,
    // required String remTime,
    required String profilePic
  }) {
    return Container(
      decoration: BoxDecoration(
        color: filledBgColor,
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
                  color: lightFilledBgColor
                ),
                child: profilePic == ''
                  ? Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: boldStyle(const Color(0xFFADB4CE), 20.sp),
                    ),
                  )
                  : ClipOval(
                    child: DisplayNetworkImage(
                      imageUrl: profilePic,
                      boxFit: .cover,
                    ),
                  )
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
                      courtName,
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
            height: 120.h,
            decoration: BoxDecoration(
              color: lightFilledBgColor,
              borderRadius: .circular(24.r)
            ),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Text(
                  phone.toString(),
                  style: boldStyle(whiteTextColor, 12.sp)
                ),
                SizedBox(height: 16.h),
                InkWell(
                  onTap: () => makePhoneCall(phone),
                  child: Container(
                    height: 48.h,
                    width: 240.w,
                    decoration: BoxDecoration(
                      color: Color(0xffFFD6A8),
                      borderRadius: .circular(12.r)
                    ),
                    child: Row(
                      mainAxisAlignment: .center,
                      children: [
                        Icon(Icons.call, color: Color(0xFF895600), size: 16.sp),
                        SizedBox(width: 12.w),
                        Text(
                          'TAP TO CALL PLAYER',
                          style: boldStyle(Color(0xFF895600), 14.sp),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Column(
          //   children: [
          //     Row(
          //       children: [
          //         Text(
          //           'HOLD TIME REMAINING',
          //           style: regularStyle(Color(0xFF895600), 10.sp),
          //         ),
          //         Spacer(),
          //         Text(
          //           '$remTime left',
          //           style: boldStyle(Color(0xFF895600), 12.sp),
          //         )
          //       ],
          //     ),
          //     SizedBox(height: 4.h),
          //     LinearProgressIndicator(
          //       value: 0.7, // Connects to the 5-second sequence
          //       backgroundColor: Colors.white.withValues(alpha: 0.15), // Muted track trail
          //       valueColor: AlwaysStoppedAnimation<Color>(
          //         Color(0xffFFD6A8), // Uses your style helper's main text or highlight color
          //       ),
          //     )
          //   ],
          // ),
          // SizedBox(height: 12.h),
          Divider(color: gray01, thickness: 1.sp),
          SizedBox(height: 12.h),
          Row(
            children: [
              btnWidgets(
                icon: Icons.check_circle_outline, 
                label: 'APPROVE', 
                onTap: () async {
                  await ownerCon.updateBookingStatus(bookingId.toString(), 'booked');
                  setState(() { });
                }
              ),
              SizedBox(width: 8.w),
              btnWidgets(
                icon: Icons.cancel_outlined, 
                label: 'REJECT', 
                onTap: () async {
                  await ownerCon.updateBookingStatus(bookingId.toString(), 'rejected');
                  setState(() { });
                }
              ),
              // btnWidgets(icon: Icons.cancel_outlined, label: 'REJECT', onTap: () => ownerCon.updateBookingStatus(bookingId.toString(), 'rejected'))
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
            color: label == 'REJECT' ? red : primaryColor,
            borderRadius: .circular(12.r),
            border: .all(
              color: label == 'REJECT' ? red : primaryColor
            )
          ),
          padding: .symmetric(vertical: 8.h, horizontal: 12.w),
          child: Row(
            mainAxisAlignment: .center,
            children: [
              Icon(icon, color: label == 'REJECT' ? whiteTextColor : black, size: 16.sp,),
              SizedBox(width: 4.w),
              Text(
                label,
                style: semiBoldStyle(label == 'REJECT' ? whiteTextColor : black, 14.sp),
              )
            ],
          ),
        ),
      ),
    );
  }

  String getTime({required String date, required String time}) {
    String dateStr = getRelativeDate(date);
    String timeStr = time.substring(0,5);
    return '$dateStr $timeStr';
  }

}