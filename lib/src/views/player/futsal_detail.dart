import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/constant.dart';
import 'package:futsal_dai/src/helper/share_url.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/views/player/player_booking_confirmation.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FutsalDetail extends StatefulWidget {
  const FutsalDetail({super.key});

  @override
  State<FutsalDetail> createState() => _FutsalDetailState();
}

class _FutsalDetailState extends State<FutsalDetail> {
  DateTime selectedDate = DateTime.now();
  bool isFav = false;
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [white, Colors.transparent],
                      stops: [0.6, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Container(
                    height: 360.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: .only(
                        topLeft: .circular(24.r),
                        topRight: .circular(24.r),
                      )
                    ),
                    child: Image.asset(
                      'assets/images/court.png',
                      fit: .cover,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(8.sp),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        SizedBox(height: Get.height * 0.25),
                        futsalInfoCard(),
                        SizedBox(height: 16.h),
                        selectDate(),
                        SizedBox(height: 16.h),
                        availableSlots(),
                        SizedBox(height: 16.h),
                        dynamicPricing(),
                        SizedBox(height: 16.h),
                        totalPriceWidget()
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 64.h,
                  left: 16.w,
                  child: iconButton(icon: Icons.arrow_back_ios_new, onTap: () => Get.back())
                ),
                Positioned(
                  top: 64.h,
                  right: 16.w,
                  child: Column(
                    children: [
                      iconButton(icon: Icons.share, onTap: () => shareContent(context)),
                      SizedBox(height: 12.h),
                      Container(
                        height: 40.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                        color: black8.withValues(alpha: 0.5),
                          shape: .circle
                        ),
                        child: IconButton(
                          onPressed: () => setState(() => isFav = !isFav),
                          icon: Icon(
                            Icons.favorite,
                            color: isFav ? primaryColor : white,
                            size: 24.r,
                          )
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget iconButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      height: 40.h,
      width: 40.w,
      decoration: BoxDecoration(
      color: black8.withValues(alpha: 0.5),
        shape: .circle
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: white,
          size: 18.r,
        )
      ),
    );
  }

  Widget futsalInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: containerBgColor,
        borderRadius: BorderRadius.circular(24.r)
      ),
      padding: .symmetric(vertical: 24.h, horizontal: 16.w),
      child: Column(
        children: [
          Text(
            'Prismatic Futsal & Recreation Center',
            style: TextStyle(
              color: whiteTextColor,
              fontSize: 28.sp,
              fontWeight: .bold,
              height: 1.2
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: whiteTextColor, size: 14.sp),
              SizedBox(width: 4.w),
              Text(
                'Sanepa, Lalitpur, Nepal',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 16.sp
                ),
              )
            ],
          ),
          Divider(color: gray01, thickness: 1.sp),
          SizedBox(height: 8.h),
          // SizedBox(
          //   height: 90.h,
          //   child: ListView.separated(
          //     itemCount: amenities.length,
          //     shrinkWrap: true,
          //     scrollDirection: .horizontal,
          //     separatorBuilder: (context, index) => SizedBox(width: 8.sp), 
          //     itemBuilder: (context, index) {
          //       var data = amenities[index];
          //       return Container(
          //         width: 60.w,
          //         alignment: Alignment.center,
          //         child: Column(
          //           crossAxisAlignment: .center,
          //           children: [
          //             Container(
          //               decoration: BoxDecoration(
          //                 color: Color(0xFF222D1E),
          //                 borderRadius: .circular(8.r)
          //               ),
          //               height: 40.h,
          //               width: 40.h,
          //               child: Icon(
          //                 data['icon'],
          //                 color: white,
          //                 size: 18.sp,
          //               ),
          //             ),
          //             SizedBox(height: 8.w),
          //             Text(
          //               data['label'],
          //               style: TextStyle(
          //                 color: white,
          //                 fontSize: 14.sp,
          //                 height: 1.0
          //               ),
          //               textAlign: .center,
          //             ),
          //           ],
          //         ),
          //       );
          //     }, 
          //   ),
          // )
          // 1. Remove the fixed height SizedBox and ListView
          Wrap(
            // Space between items horizontally (replaces separatorBuilder)
            spacing: 8.sp, 
            // Space between lines vertically when it wraps
            runSpacing: 12.h, 
            // Centers the grid overall if it wraps unevenly
            alignment: WrapAlignment.start, 
            children: amenities.map((data) {
              return SizedBox(
                width: 60.w,
                // Removed fixed constraints to let text wrap/grow naturally
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF222D1E),
                        borderRadius: BorderRadius.circular(8.r), // Added missing 'BorderRadius' prefix
                      ),
                      height: 40.h,
                      width: 40.h,
                      child: Icon(
                        data['icon'],
                        color: white,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(height: 8.h), // Changed .w to .h for vertical spacing consistency
                    Text(
                      data['label'],
                      style: TextStyle(
                        color: white,
                        fontSize: 14.sp,
                        height: 1.2, // Slightly increased height so letters like 'g' or 'y' aren't clipped
                      ),
                      textAlign: TextAlign.center, // Added missing 'TextAlign' prefix
                      maxLines: 2, // Prevents a single long word from breaking the UI layout
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget selectDate() {
    List<DateTime> dates = List.generate(14, (index) => DateTime.now().add(Duration(days: index)));
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              'Select Date',
              style: TextStyle(
                color: whiteTextColor,
                fontSize: 20.sp,
                fontWeight: .w600,
              ),
            ),
            Text(
              DateFormat('MMMM yyyy').format(selectedDate),
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 14.sp,
                fontWeight: .bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 85.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              DateTime date = dates[index];
              bool isSelected = DateUtils.isSameDay(date, selectedDate);
              
              String dayName = DateFormat('E').format(date).toUpperCase(); // MON, TUE
              String dayNumber = DateFormat('d').format(date); // 10, 11

              return GestureDetector(
                onTap: () => setState(() => selectedDate = date),
                child: Container(
                  width: 60.w,
                  height: 80.h,
                  margin: .symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          color: isSelected ? black : white,
                          fontSize: 10,
                          fontWeight: .normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayNumber,
                        style: TextStyle(
                          color: isSelected ? black : white,
                          fontSize: 20,
                          fontWeight: .w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget availableSlots() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Available Slots',
          style: TextStyle(
            color: whiteTextColor,
            fontSize: 20.sp,
            fontWeight: .w600,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          padding: .zero,
          physics: const NeverScrollableScrollPhysics(), // Prevents nested scrolling if inside another scroll view
          shrinkWrap: true, // Allows it to take only needed space instead of full screen
          itemCount: slots.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,          // Forces exactly 2 containers per row
            crossAxisSpacing: 12.w,     // Horizontal spacing between columns
            mainAxisSpacing: 12.h,      // Vertical spacing between rows
            mainAxisExtent: 106.h,       // Enforces a strict total height for each container item
          ),
          itemBuilder: (context, index) {
            var data = slots[index];
            bool isSelected = selectedIndex == index;
            return InkWell(
              onTap: () {
                if (data['status'] == 'available') {
                  setState(() {
                    if (selectedIndex == index) {
                      selectedIndex = null;
                    } else {
                      selectedIndex = index;
                    }
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                          ? primaryColor
                          : data['status'] == 'booked' 
                            ? filledBgColor
                            : data['status'] == 'pending'
                              ? brownTextColor.withValues(alpha: 0.2)
                              :lightFilledBgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      data['slot'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: .bold,
                        color: selectedIndex == index ? black : subtitleTextColor
                      ),
                    ),
                    Text(
                      data['status'] == 'available' 
                        ? "Rs. ${data['price']}"
                        : "${data['status'][0].toUpperCase()}${data['status'].substring(1)}",
                      style: TextStyle(
                        color: selectedIndex == index 
                                ? black 
                                : data['status'] == 'available' 
                                  ? primaryTextColor 
                                  : data['status'] == 'pending'
                                    ? brownTextColor
                                    : subtitleTextColor, 
                        fontSize: 20.sp,
                        fontWeight: .w500
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      data['status'] == 'booked' 
                        ? "Booked by ${data['booked_by']}"
                        : data['status'] == 'pending' 
                          ? "Awaiting confirmation"
                          : "",
                      style: TextStyle(
                        color: selectedIndex == index 
                                ? black 
                                : data['status'] == 'available' 
                                  ? primaryTextColor 
                                  : data['status'] == 'pending'
                                    ? brownTextColor
                                    : subtitleTextColor, 
                        fontSize: 11.sp,
                        fontWeight: .w500,
                        height: 1.2
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget dynamicPricing() {
    return Container(
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 40.h,
                width: 6.w,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: .circular(2.r)
                ),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    'Dynamic Pricing',
                    style: TextStyle(
                      fontWeight: .bold,
                      fontSize: 12.sp,
                      color: whiteTextColor
                    ),
                  ),
                  Text(
                    'Rates vary by time of day',
                    style: TextStyle(
                      fontWeight: .normal,
                      fontSize: 12.sp,
                      color: subtitleTextColor
                    ),
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                'Off-Peak (06:00 - 15:00)',
                style: TextStyle(
                  color: subtitleTextColor,
                  fontSize: 14.sp
                ),
              ),
              Text(
                'Rs. 800',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 16.sp
                ),
              )
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                'Peak Hour (16:00 - 21:00)',
                style: TextStyle(
                  color: subtitleTextColor,
                  fontSize: 14.sp
                ),
              ),
              Text(
                'Rs. 1200',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 16.sp
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget totalPriceWidget() {
    return selectedIndex == null 
      ? SizedBox()
      : Container(
        color: filledBgColor,
        padding: .symmetric(vertical: 12.h, horizontal: 12.w),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  'TOTAL PRICE',
                  style: TextStyle(
                    color: subtitleTextColor,
                    fontSize: 10.sp
                  ),
                ),
                Text(
                  "Rs. ${slots[selectedIndex!]['price']}",
                  style: TextStyle(
                    color: whiteTextColor,
                    fontSize: 20.sp,
                    fontWeight: .w600
                  ),
                ),
              ],
            ),
            Spacer(),
            CustomUsualButton(
              text: 'Book Now', 
              width: 200.w,
              height: 56.h,
              style: TextStyle(
                color: black,
                fontWeight: .bold,
                fontSize: 20.sp
              ),
              onPressed: () {
                Get.bottomSheet(
                  PlayerBookingConfirm(),
                  isScrollControlled: true, // Allows sheet to expand if needed
                  ignoreSafeArea: false,
                );
              }
            )
          ],
        ),
      );
  }

}