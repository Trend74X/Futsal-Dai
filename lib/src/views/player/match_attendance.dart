import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/group_controller.dart';
import 'package:futsal_dai/src/helper/cache_manager.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';
import 'package:get/get.dart';

class MatchAttendance extends StatefulWidget {
  final String bookingId, groupId;
  const MatchAttendance({super.key, required this.bookingId, required this.groupId});

  @override
  State<MatchAttendance> createState() => _MatchAttendanceState();
}

class _MatchAttendanceState extends State<MatchAttendance> {
  final controller = Get.put(GroupController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.getMatchAttendanceData(widget.groupId, widget.bookingId);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        title: 'Match Attendance',
        action: IconButton(
          onPressed: () {
            // Calculate inCount or pass a default value if data is still loading
            int currentInCount = 0;
            if (controller.attendanceDetail.isNotEmpty && controller.attendanceDetail[0]['group_members'] != null) {
              final members = List.from(controller.attendanceDetail[0]['group_members']);
              for (var member in members) {
                if (controller.matchAttendanceMap[member['user_id']?.toString()] == 'IN') {
                  currentInCount++;
                }
              }
            }
            _showRecruitmentDialog(context, currentInCount);
          },
          icon: Icon(Icons.person_add_alt_1, color: primaryColor)
        )
      ),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            child: Padding(
              padding: .symmetric(horizontal: 16.sp, vertical: 8.h),
              child: SingleChildScrollView(
                child: Obx(() {
                  if (controller.isLoading.isTrue) {
                    return SizedBox(
                      height: Get.height * 0.8,
                      child: Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    );
                  }

                  // Extract group members list safely
                  final membersList = (controller.attendanceDetail.isNotEmpty &&
                          controller.attendanceDetail[0]['group_members'] != null)
                      ? List.from(controller.attendanceDetail[0]['group_members'])
                      : [];

                  // Calculate Counts dynamically
                  int inCount = 0;
                  int outCount = 0;
                  int nACount = 0;

                  for (var member in membersList) {
                    final userId = member['user_id']?.toString();
                    final status = controller.matchAttendanceMap[userId] ?? 'N/A';
                    
                    if (status == 'IN') {
                      inCount++;
                    } else if (status == 'OUT') {
                      outCount++;
                    } else {
                      nACount++;
                    }
                  }

                  return Column(
                    crossAxisAlignment: .start,
                    children: [
                      SizedBox(height: 16.h),
                      attendanceCount(inCount, outCount, nACount),
                      SizedBox(height: 16.h),
                      userChoice(),
                      SizedBox(height: 16.h),
                      squadStatus(membersList),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget attendanceCount(int inCount, int outCount, int nACount) {
    return Container(
      margin: .symmetric(horizontal: 4.sp),
      padding: .symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: .circular(24.r),
      ),
      child: Row(
        mainAxisAlignment: .center,
        children: [
          countCircleWidget(count: inCount, color: primaryColor, label: 'IN'),
          SizedBox(width: 16.w),
          countCircleWidget(count: outCount, color: const Color(0xFFFFB4AB), label: 'OUT'),
          SizedBox(width: 16.w),
          countCircleWidget(count: nACount, color: grayDark, label: 'N/A')
        ],
      ),
    );
  }

  Widget countCircleWidget({required int count, required Color color, required String label}) {
    return Column(
      children: [
        Container(
          height: 70.h,
          width: 70.w,
          decoration: BoxDecoration(
            shape: .circle,
            border: .all(color: color, width: 4.w),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: regularStyle(color, 20.sp),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: regularStyle(color, 16.sp),
        ),
      ],
    );
  }

  Widget userChoice() {
    final currentUserId = read('userId');
    
    // Check if the current user has already chosen 'IN' or 'OUT'
    final userStatus = currentUserId != null ? controller.matchAttendanceMap[currentUserId] : null;
    final hasChosen = userStatus == 'IN' || userStatus == 'OUT';

    // If user has already made a choice, hide the widget completely
    if (hasChosen) {
      return const SizedBox.shrink();
    }

    return Container(
      width: .infinity,
      margin: .all(4.sp),
      padding: .symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: .circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            'Are you showing up for this game?',
            style: regularStyle(whiteTextColor, 16.sp),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              userChoiceTile(
                title: "I'm In",
                subtitle: "I'll be there",
                color: primaryColor,
                icon: Icons.check,
                statusValue: 'IN',
              ),
              SizedBox(width: 12.w),
              userChoiceTile(
                title: "I'm Out",
                subtitle: "Can't make it",
                color: const Color(0xFFFFB4AB),
                icon: Icons.close,
                statusValue: 'OUT',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget userChoiceTile({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required String statusValue,
  }) {
    final currentUserId = read('userId');
    // Check if the current user has explicitly selected this option
    final isSelected = controller.matchAttendanceMap[currentUserId] == statusValue;

    return Expanded(
      child: InkWell(
        onTap: () => controller.updateAttendance(widget.bookingId, statusValue),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.4) : color.withValues(alpha: 0.1),
            borderRadius: .circular(12.r),
            border: .all(color: color, width: isSelected ? 3.w : 1.5.w),
          ),
          padding: .symmetric(vertical: 10.h, horizontal: 12.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: .center,
                children: [
                  Text(
                    title,
                    style: regularStyle(color, 16.sp),
                  ),
                  SizedBox(width: 6.w),
                  Icon(icon, color: color, size: 18.sp),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: regularStyle(subtitleTextColor, 12.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget squadStatus(List membersList) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Squad Status Feed',
          style: regularStyle(whiteTextColor, 16.sp),
        ),
        SizedBox(height: 8.h),
        ListView.builder(
          itemCount: membersList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            var member = membersList[index];
            var user = member['Users'] ?? {};
            var userId = member['user_id']?.toString();
            
            // If user ID is missing from attendance_data map, default status is 'N/A'
            String status = controller.matchAttendanceMap[userId] ?? 'N/A';

            Color color = status == 'IN'
                ? primaryColor
                : status == 'OUT'
                    ? const Color(0xFFFFB4AB)
                    : grayDark;

            return Container(
              width: .infinity,
              margin: .all(4.sp),
              padding: .all(16.w),
              decoration: BoxDecoration(
                color: filledBlueColor,
                borderRadius: .circular(24.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: lightFilledBgColor,
                    backgroundImage: user['profile_pic'] != null
                        ? NetworkImage(user['profile_pic'])
                        : null,
                    child: user['profile_pic'] == null
                        ? Icon(Icons.person, color: subtitleTextColor)
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          user['full_name'] ?? 'Unknown User',
                          style: boldStyle(whiteTextColor, 16.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "Role: ${member['role'] ?? 'Member'}",
                          style: semiBoldStyle(subtitleTextColor, 12.sp),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: Get.width * 0.22,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: .circular(8.r),
                    ),
                    padding: .symmetric(vertical: 6.h, horizontal: 4.w),
                    child: Row(
                      mainAxisAlignment: .center,
                      children: [
                        Icon(
                          status == 'IN'
                              ? Icons.check
                              : status == 'OUT'
                                  ? Icons.close
                                  : Icons.question_mark,
                          size: 14.sp,
                          color: color,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          status,
                          style: regularStyle(color, 14.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showRecruitmentDialog(BuildContext context, int currentInCount) {
    // Default the needed slots to a sensible number (e.g., assuming a standard 10-player or 7-player game, or remaining slots)
    final TextEditingController slotsController = TextEditingController(text: '2');
    final TextEditingController notesController = TextEditingController(text: 'Need backup players for our match!');

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
          side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.campaign, color: primaryColor, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'Recruit Local Players',
              style: boldStyle(whiteTextColor, 18.sp),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Publish an open post to the Recruitment Board so local players can request to join your match.',
                style: regularStyle(subtitleTextColor, 13.sp),
              ),
              SizedBox(height: 16.h),
              
              // Match info snippet container
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: filledBlueColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: primaryColor, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Currently $currentInCount players confirmed IN for this match.',
                        style: semiBoldStyle(whiteTextColor, 12.sp),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // How many players input field
              Text(
                'Players Needed',
                style: semiBoldStyle(whiteTextColor, 14.sp),
              ),
              SizedBox(height: 6.h),
              TextField(
                controller: slotsController,
                keyboardType: TextInputType.number,
                style: regularStyle(whiteTextColor, 14.sp),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: filledBlueColor,
                  hintText: 'Enter number of slots',
                  hintStyle: regularStyle(subtitleTextColor, 12.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Note / Description input field
              Text(
                'Additional Notes (Optional)',
                style: semiBoldStyle(whiteTextColor, 14.sp),
              ),
              SizedBox(height: 6.h),
              TextField(
                controller: notesController,
                maxLines: 2,
                style: regularStyle(whiteTextColor, 14.sp),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: filledBlueColor,
                  hintText: 'e.g., Need a defender urgently',
                  hintStyle: regularStyle(subtitleTextColor, 12.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: regularStyle(subtitleTextColor, 14.sp),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () async {
              final int? slots = int.tryParse(slotsController.text.trim());
              if (slots == null || slots <= 0) {
                Get.snackbar('Error', 'Please enter a valid number of players', colorText: Colors.white);
                return;
              }

              // Call the controller method with your widget IDs and input values
              await controller.postToMercenaryBoard(
                bookingId: widget.bookingId,
                groupId: widget.groupId,
                slotsNeeded: slots,
                notes: notesController.text.trim(),
              );
              
              Get.back(); // Close dialog on success
            },
            child: Text(
              'Post to Board',
              style: boldStyle(Colors.black, 14.sp),
            ),
          ),
        ],
      ),
    );
  }

}