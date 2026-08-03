import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/app_controller.dart';
import 'package:futsal_dai/src/controller/player_controller.dart';
import 'package:futsal_dai/src/helper/share_url.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/model/amenities_model.dart';
import 'package:futsal_dai/src/views/player/player_booking_confirmation.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FutsalDetail extends StatefulWidget {
  final dynamic data;
  const FutsalDetail({super.key, required this.data});

  @override
  State<FutsalDetail> createState() => _FutsalDetailState();
}

class _FutsalDetailState extends State<FutsalDetail> {
  final appCon = Get.put(AppController());
  final playerCon = Get.put(PlayerController());

  DateTime selectedDate = DateTime.now();
  bool isFav = false;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      playerCon.fetchDailyVenueData(widget.data.id, selectedDate, widget.data);
    });
  }

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
                        selectGround(),
                        SizedBox(height: 16.h),
                        selectDate(),
                        SizedBox(height: 16.h),
                        availableSlots(),
                        SizedBox(height: 16.h),
                        if(widget.data.isPeakEnabled) dynamicPricing(),
                        if(widget.data.isPeakEnabled) SizedBox(height: 16.h),
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
    List<AmenityModel> venueAmenities = appCon.amenitiesList.where((model) {
      return widget.data.amenities.contains(model.label);
    }).toList();
    return Container(
      decoration: BoxDecoration(
        color: containerBgColor,
        borderRadius: BorderRadius.circular(24.r)
      ),
      padding: .symmetric(vertical: 24.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          //futsal name
          Text(
            widget.data.name,
            style: TextStyle(
              color: whiteTextColor,
              fontSize: 28.sp,
              fontWeight: .bold,
              height: 1.1
            ),
          ),
          SizedBox(height: 8.h),
          // futsal address
          Row(
            crossAxisAlignment: .start,
            children: [
              Icon(Icons.location_on_outlined, color: whiteTextColor, size: 14.sp),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  widget.data.address,
                  style: TextStyle(
                    color: whiteTextColor,
                    fontSize: 16.sp,
                    height: 1.1
                  ),
                  maxLines: 2,
                ),
              )
            ],
          ),
          Divider(color: gray01, thickness: 1.sp),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.sp, 
            runSpacing: 12.h, 
            alignment: WrapAlignment.start, 
            children: venueAmenities.map((data) {
              return SizedBox(
                width: 60.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF222D1E),
                        borderRadius: BorderRadius.circular(8.r), 
                      ),
                      height: 40.h,
                      width: 40.h,
                      child: Icon(
                        getAmenityIcon(data.iconName),
                        color: white,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(height: 8.h), 
                    Text(
                      data.label,
                      style: TextStyle(
                        color: white,
                        fontSize: 14.sp,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
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
                onTap: () {
                  setState(() {
                    selectedDate = date;
                    selectedIndex = null;
                  });
                  playerCon.fetchDailyVenueData(widget.data.id, selectedDate, widget.data);
                },
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Slots',
          style: TextStyle(
            color: whiteTextColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() {
          // 1. Show Loading State
          if (playerCon.isLoadingDetails.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: CircularProgressIndicator(color: primaryColor),
              )
            );
          }

          // 2. Check if Closed
          if (playerCon.todayHours.value != null && playerCon.todayHours.value!['is_closed'] == true) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.h),
              decoration: BoxDecoration(
                color: filledBgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  "Venue is closed on this day.",
                  style: TextStyle(color: Colors.redAccent, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          // 3. Handle Empty Slots
          if (playerCon.availableSlots.isEmpty) {
            return Center(
              child: Text("No slots available.", style: TextStyle(color: subtitleTextColor, fontSize: 14.sp))
            );
          }

          // 4. Show the Grid
          return GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: playerCon.availableSlots.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              mainAxisExtent: 106.h,
            ),
            itemBuilder: (context, index) {
              var data = playerCon.availableSlots[index]; // Use the controller's reactive list
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
                                ? Colors.brown.withValues(alpha: 0.2) // Replace with your brown color
                                : const Color(0xFF222D1E), // Your lightFilledBgColor
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['slot'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: selectedIndex == index ? Colors.black : subtitleTextColor
                        ),
                      ),
                      Text(
                        data['status'] == 'available' 
                          ? "Rs. ${data['price'].toInt()}"
                          : "${data['status'][0].toUpperCase()}${data['status'].substring(1)}",
                        style: TextStyle(
                          color: selectedIndex == index 
                                  ? Colors.black 
                                  : data['status'] == 'available' 
                                    ? primaryColor // primaryTextColor
                                    : data['status'] == 'pending'
                                      ? Colors.brown
                                      : subtitleTextColor, 
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500
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
                                  ? Colors.black 
                                  : subtitleTextColor, 
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
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
          );
        })
      ],
    );
  }

  Widget selectGround() {
    return Obx(() {
      if (playerCon.grounds.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Ground',
            style: TextStyle(
              color: whiteTextColor, // Assuming this is defined in your styles
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: playerCon.grounds.map((ground) {
                bool isSelected = playerCon.selectedGroundId.value == ground['id'];
                
                return GestureDetector(
                  onTap: () {
                    // Update the selected ground ID
                    playerCon.selectedGroundId.value = ground['id'];
                    // Regenerate the slots specifically for this ground
                    playerCon.generateSlotsForSelectedGround(selectedDate, widget.data);
                    // Clear user selection
                    setState(() => selectedIndex = null); 
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12.w),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : filledBgColor, // Assuming filledBgColor is defined
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? primaryColor : subtitleTextColor.withValues(alpha: 0.3),
                      )
                    ),
                    child: Column(
                      children: [
                        Text(
                          ground['ground_name'] ?? 'Ground',
                          style: TextStyle(
                            color: isSelected ? Colors.black : whiteTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        if (ground['format'] != null)
                          Text(
                            ground['format'], // e.g. '5-A-Side'
                            style: TextStyle(
                              color: isSelected ? Colors.black87 : subtitleTextColor,
                              fontSize: 12.sp,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
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
                'Off-Peak Hour',
                // 'Off-Peak (06:00 - 15:00)',
                style: TextStyle(
                  color: subtitleTextColor,
                  fontSize: 14.sp
                ),
              ),
              Text(
                'Rs. ${widget.data.basePrice.toInt()}',
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
                'Peak Hour (${widget.data.peakStartTime.substring(0, 5)} - ${widget.data.peakEndTime.substring(0, 5)})',
                style: TextStyle(
                  color: subtitleTextColor,
                  fontSize: 14.sp
                ),
              ),
              Text(
                'Rs. ${widget.data.peakRate.toInt()}',
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
      ? const SizedBox()
      : Container(
        color: filledBgColor,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL PRICE',
                  style: TextStyle(
                    color: subtitleTextColor,
                    fontSize: 10.sp
                  ),
                ),
                Text(
                  // Grab the price from the controller based on selected index
                  "Rs. ${playerCon.availableSlots[selectedIndex!]['price'].toInt()}",
                  style: TextStyle(
                    color: whiteTextColor,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ],
            ),
            const Spacer(),
            CustomUsualButton(
              text: 'Book Now', 
              width: 200.w,
              height: 56.h,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp
              ),
              onPressed: () {
                // 1. Get the selected slot data from the controller
                var slotData = playerCon.availableSlots[selectedIndex!];
                
                // 2. Find the selected ground from the controller's ground list
                var groundData = playerCon.grounds.firstWhere(
                  (g) => g['id'] == playerCon.selectedGroundId.value,
                  orElse: () => {'id': '', 'ground_name': 'Unknown Ground'} 
                );

                // 3. Open the sheet with the dynamic data
                Get.bottomSheet(
                  PlayerBookingConfirm(
                    venueData: widget.data,
                    selectedDate: selectedDate,
                    selectedSlot: slotData,
                    selectedGround: groundData,
                  ),
                  isScrollControlled: true, 
                  ignoreSafeArea: false,
                );
              }
            )
          ],
        ),
      );
  }

}