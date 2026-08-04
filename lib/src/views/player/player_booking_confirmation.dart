import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/player_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PlayerBookingConfirm extends StatefulWidget {
  final dynamic venueData; // Using your FutsalVenueModel
  final DateTime selectedDate;
  final Map<String, dynamic> selectedSlot;
  final Map<String, dynamic> selectedGround;

  const PlayerBookingConfirm({
    super.key,
    required this.venueData,
    required this.selectedDate,
    required this.selectedSlot,
    required this.selectedGround,
  });

  @override
  State<PlayerBookingConfirm> createState() => _PlayerBookingConfirmState();
}

class _PlayerBookingConfirmState extends State<PlayerBookingConfirm> {
  final PlayerController _con = Get.put(PlayerController());
  
  bool isBooking = false;

  Future<void> confirmBookingRequest() async {
    setState(() => isBooking = true);
    
    try {
      _con.requestBooking(
        venueId: widget.venueData.id,
        groundId: widget.selectedGround['id'],
        bookingDate: widget.selectedDate,
        startTime: widget.selectedSlot['slot_start'],
        endTime: widget.selectedSlot['slot_end'],
        totalPrice: widget.selectedSlot['price'],
        groundName: widget.selectedGround['ground_name']
      );
      Get.back(); // Close bottom sheet
    } catch (e) {
      Get.snackbar('Error', 'Failed to request booking.', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      width: double.infinity,
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Booking Confirmation',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: whiteTextColor),
              ),
              const Spacer(),
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
      alignment: Alignment.bottomLeft,
      children: [
        // Make the image dynamic. Use a fallback if the venue has no image.
        Container(
          height: 120.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            image: DecorationImage(
              // Assuming your venueData model has a mainImageUrl property
              image: widget.venueData.mainImageUrl != null 
                  ? NetworkImage(widget.venueData.mainImageUrl) as ImageProvider
                  : const AssetImage('assets/images/court.png'),
              fit: BoxFit.cover,
            )
          ),
        ),
        Container(
          height: 120.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
            )
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4.r)
                ),
                child: Text(
                  widget.selectedGround['ground_name']?.toUpperCase() ?? 'VENUE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.venueData.name,
                style: TextStyle(
                  color: whiteTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.sp,
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
              borderRadius: BorderRadius.circular(12.r)
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.date_range, color: whiteTextColor, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'DATE',
                        style: TextStyle(
                          color: whiteTextColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ]
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    DateFormat('EEE, MMM d').format(widget.selectedDate), // e.g., "Sat, Dec 14"
                    style: TextStyle(
                      color: whiteTextColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: lightFilledBgColor,
              borderRadius: BorderRadius.circular(12.r)
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: whiteTextColor, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'TIME',
                        style: TextStyle(
                          color: whiteTextColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ]
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.selectedSlot['slot'], // e.g., "17:00 - 18:00"
                    style: TextStyle(
                      color: whiteTextColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600
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
    // Check if the current slot price is higher than the venue's base price to show "Peak Rate"
    bool isPeakRate = widget.selectedSlot['price'] > widget.venueData.basePrice;
    
    // Calculate duration
    DateTime start = widget.selectedSlot['slot_start'];
    DateTime end = widget.selectedSlot['slot_end'];
    int durationMins = end.difference(start).inMinutes;

    return Container(
      decoration: BoxDecoration(
        color: lightFilledBgColor,
        borderRadius: BorderRadius.circular(12.r)
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPeakRate ? 'Peak Rate Applied' : 'Standard Rate',
                  style: TextStyle(
                    color: isPeakRate ? const Color(0xFFFFD6A8) : const Color(0xFFADB4CE),
                    fontWeight: FontWeight.bold, 
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  '$durationMins minutes slot',
                  style: TextStyle(
                    color: whiteTextColor,
                    fontSize: 14.sp,
                  ),
                )
              ],
            ),
            const Spacer(),
            Text(
              'Rs. ${widget.selectedSlot['price'].toInt()}',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold
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
        color: const Color(0xFFFFD6A8).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r)
      ),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, color: brownTextColor),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Required',
                  style: TextStyle(
                    color: const Color(0xFFFFDDB8),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold
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
      child: isBooking 
        ? const CircularProgressIndicator(color: primaryColor)
        : CustomUsualButton(
            text: 'REQUEST BOOKING SLOT', 
            onPressed: confirmBookingRequest,
            fontColor: const Color(0xFF053900),
            fontSize: 18.sp,
            color: primaryTextColor,
          ),
    );
  }

  Widget cancellationTextWidget() {
    return Center(
      child: Text(
        'Cancellation policy applies. 15m grace period.',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
          color: subtitleTextColor.withValues(alpha: 0.5)
        ),
      ),
    );
  }
}