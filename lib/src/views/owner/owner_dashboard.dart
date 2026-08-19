import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/owner_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/url_launcher_helper.dart';
import 'package:futsal_dai/src/views/owner/owner_pending_all.dart';
import 'package:futsal_dai/src/views/owner/owner_slot_entry.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:futsal_dai/src/widgets/display_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OwnerDashboard extends StatefulWidget {
  final int venueId;

  const OwnerDashboard({super.key, required this.venueId});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  final OwnerController ownerCon = Get.put(OwnerController());

  // Track selected ground ID and name dynamically
  String? selectedGroundId;
  String selectedGroundName = '';
  
  // Track selected date for timeline filtering
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ownerCon.fetchPendingBookings(widget.venueId);
      
      // Fetch grounds and set default selection to the first ground
      await ownerCon.fetchVenueGrounds(widget.venueId);
      if (ownerCon.venueGrounds.isNotEmpty) {
        setState(() {
          selectedGroundId = ownerCon.venueGrounds[0]['id'].toString();
          selectedGroundName = ownerCon.venueGrounds[0]['ground_name'] ?? 'Ground';
        });
        _loadTimeline();
      }
    });
  }

  void _loadTimeline() {
    if (selectedGroundId != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      ownerCon.fetchGroundTimelineBookings(
        groundId: selectedGroundId!, 
        dateStr: dateStr,
      );
    }
  }

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
                    timeLineSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget todayCardsWidget() {
    return Row(
      children: [
        cardsToday(icon: 'assets/icons/ball.png', title: '24', subtitle: 'BOOKINGS TODAY', color: primaryColor),
        SizedBox(width: 16.w),
        cardsToday(icon: 'assets/icons/money.png', title: '12.4k', subtitle: 'REVENUE TODAY', color: const Color(0xFFFFB95F)),
      ],
    );
  }

  Widget cardsToday({required String icon, required String title, required String subtitle, required Color color}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(color: filledBgColor),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(icon, height: 20.h, width: 20.w),
            Text(title, style: boldStyle(color, 48.sp)),
            Text(subtitle, style: boldStyle(subtitleTextColor, 12.sp)),
          ],
        ),
      ),
    );
  }

  Widget pendingQueueWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Pending Queue', style: semiBoldStyle(whiteTextColor, 20.sp)),
            SizedBox(width: 8.w),
            Obx(() => Container(
              decoration: BoxDecoration(
                color: const Color(0xFF93000A),
                borderRadius: BorderRadius.circular(24.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Text(
                ownerCon.pendingBookings.length > 5 
                  ? '5+ NEW' 
                  : '${ownerCon.pendingBookings.length} NEW',
                style: boldStyle(whiteTextColor, 10.sp),
              ),
            )),
            const Spacer(),
            Obx(() => ownerCon.pendingBookings.isEmpty
                ? const SizedBox()
                : InkWell(
                    onTap: () => Get.to(() => const OwnerPendingAll()),
                    child: Text('SEE ALL', style: boldStyle(primaryColor, 12.sp)),
                  ),
            )
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 210.h,
          child: Obx(() {
            if (ownerCon.isLoadingPending.value) {
              return const Center(child: CircularProgressIndicator(color: primaryColor));
            }
            if (ownerCon.pendingBookings.isEmpty) {
              return Center(
                child: Text('No pending bookings right now.', style: semiBoldStyle(Colors.grey, 14.sp)),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              itemCount: ownerCon.pendingBookings.length > 5 ? 5 : ownerCon.pendingBookings.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (ctx, idx) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                return pendingQueCard(ownerCon.pendingBookings[index]);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget pendingQueCard(Map<String, dynamic> data) {
    final String userName = data['users']?['full_name'] ?? 'Unknown User';
    final String profilePic = data['users']?['profile_pic'] ?? '';
    final String phone = data['users']?['phone_number'] ?? 'N/A';
    final String groundName = data['ground_name'] ?? 'N/A';
    final String date = data['booking_date'] ?? '';
    final String startTime = data['start_time']?.substring(0, 5) ?? '';
    final String endTime = data['end_time']?.substring(0, 5) ?? '';
    final String initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40.h,
                width: 40.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF3F465C),
                ),
                child: profilePic == ''
                    ? Center(child: Text(initial, style: boldStyle(const Color(0xFFADB4CE), 20.sp)))
                    : ClipOval(child: DisplayNetworkImage(imageUrl: profilePic, boxFit: BoxFit.cover)),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: semiBoldStyle(whiteTextColor, 20.sp).copyWith(height: 1.0), maxLines: 1, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 4.h),
                    Text(groundName, style: semiBoldStyle(whiteTextColor, 14.sp)),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              InkWell(
                onTap: () {
                  if (phone != 'N/A') makePhoneCall(phone);
                },
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
          Container(
            height: 32.h,
            decoration: BoxDecoration(
              color: lightFilledBgColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
            child: Row(
              children: [
                Icon(Icons.access_time, color: primaryColor, size: 16.sp),
                SizedBox(width: 8.w),
                Text('$date | $startTime - $endTime', style: boldStyle(whiteTextColor, 12.sp)),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: CustomUsualButton(
                    text: 'APPROVE',
                    onPressed: () {
                      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                      ownerCon.updateBookingStatus(
                        data['id'].toString(), 
                        'booked', 
                        groundId: selectedGroundId, 
                        dateStr: dateStr,
                      );
                    },
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    height: 42.h,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomUsualButton(
                    text: 'REJECT',
                    onPressed: () => ownerCon.updateBookingStatus(data['id'].toString(), 'rejected'),
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

  Widget timeLineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Timeline', style: semiBoldStyle(whiteTextColor, 20.sp)),
            // Dynamic ground selector buttons header
            Obx(() {
              if (ownerCon.isLoadingGrounds.value) {
                return const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2));
              }
              return Row(
                children: ownerCon.venueGrounds.map((ground) {
                  final String groundId = ground['id'].toString();
                  final String groundName = ground['ground_name'] ?? 'Pitch';
                  final bool isSelected = selectedGroundId == groundId;

                  return Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: InkWell(
                      onTap: () {
                        // 1. Update active selection state immediately
                        setState(() {
                          selectedGroundId = groundId;
                          selectedGroundName = groundName;
                        });
                        // 2. Fetch bookings explicitly for this newly selected pitch ID
                        _loadTimeline();
                      },
                      child: _buildHeaderBadge(groundName.toUpperCase(), isSelected: isSelected),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
        SizedBox(height: 20.h),
        Container(
          decoration: BoxDecoration(
            color: filledBgColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Obx(() {
            if (ownerCon.isLoadingTimeline.value) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: primaryColor),
              ));
            }

            // Check if selected date is today
            bool isToday = DateUtils.isSameDay(selectedDate, DateTime.now());
            int currentHour = DateTime.now().hour;

            // Generate full hourly slots (6 AM to 9 PM -> hours 6 through 21)
            List<int> allHours = List.generate(16, (index) => index + 6);

            // Filter: Show current hour and later if today, otherwise show all hours for future dates
            List<int> filteredHours = isToday
                ? allHours.where((hour) => hour >= currentHour).toList()
                : allHours;

            if (filteredHours.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0.h),
                  child: Text(
                    'No remaining time slots for today.',
                    style: boldStyle(subtitleTextColor, 12.sp),
                  ),
                ),
              );
            }

            return Column(
              children: filteredHours.map((hour) {
                final String timeFormatted = '${hour.toString().padLeft(2, '0')}:00';
                
                // Match this hour slot against the fetched bookings for the current active ground
                Map<String, dynamic>? matchingBooking;
                for (var b in ownerCon.groundBookings) {
                  final String startStr = b['start_time'] ?? '';
                  if (startStr.startsWith(hour.toString().padLeft(2, '0'))) {
                    matchingBooking = b;
                    break;
                  }
                }

                String status = 'AVAILABLE';
                String? subtitle;

                if (matchingBooking != null) {
                  final String dbStatus = matchingBooking['status'] ?? 'booked';
                  if (dbStatus == 'booked' || dbStatus == 'confirmed') {
                    status = 'Booked';
                    subtitle = matchingBooking['users']?['full_name'] ?? 'Reserved';
                  } else if (dbStatus == 'completed') {
                    status = 'Completed';
                    subtitle = matchingBooking['users']?['full_name'];
                  } else if (dbStatus == 'in_progress') {
                    status = 'IN PROGRESS';
                    subtitle = matchingBooking['users']?['full_name'];
                  }
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: timeLineTile(time: timeFormatted, status: status, subtitle: subtitle),
                );
              }).toList(),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeaderBadge(String label, {required bool isSelected}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withValues(alpha: 0.3) : whiteTextColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: isSelected ? primaryColor : Colors.transparent),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? primaryColor : whiteTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 11.sp,
        ),
      ),
    );
  }

  Widget timeLineTile({
    required String time,
    required String status,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50.w,
          child: Text(
            time,
            style: boldStyle(status == 'Completed' ? gray02 : subtitleTextColor, 12.sp),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Container(
            height: 80.h,
            decoration: BoxDecoration(
              color: status == 'AVAILABLE'
                  ? Colors.transparent
                  : status == 'Completed'
                      ? lightFilledBgColor
                      : status == 'IN PROGRESS'
                          ? primaryColor.withValues(alpha: 0.2)
                          : filledBgColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: subtitleTextColor.withValues(alpha: 0.5),
              ),
            ),
            child: status == 'AVAILABLE'
                ? InkWell(
                    onTap: () => Get.to(() => const OwnerMaunualSlotEntry()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: subtitleTextColor),
                        SizedBox(width: 4.w),
                        Text(
                          status,
                          style: boldStyle(subtitleTextColor, 12.sp),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: double.infinity,
                        color: status == 'Completed'
                            ? subtitleTextColor
                            : status == 'IN PROGRESS'
                                ? primaryColor
                                : textBlue,
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status,
                            style: boldStyle(status == 'IN PROGRESS' ? primaryColor : whiteTextColor, 12.sp),
                          ),
                          subtitle == null
                              ? const SizedBox()
                              : Text(
                                  subtitle,
                                  style: boldStyle(subtitleTextColor, 10.sp),
                                ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}