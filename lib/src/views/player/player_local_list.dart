import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/group_controller.dart';
import 'package:futsal_dai/src/helper/cache_manager.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/views/player/player_local_detail.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerLocalList extends StatefulWidget {
  const PlayerLocalList({super.key});

  @override
  State<PlayerLocalList> createState() => _PlayerLocalListState();
}

class _PlayerLocalListState extends State<PlayerLocalList> {
  final controller = Get.put(GroupController());

  final List<String> filterItems = ['All', 'Tonight', 'Tomorrow', 'Later', 'My Requests'];

  @override
  void initState() {
    super.initState();
    getRecuitmentDatas();
  }

  Future<void> getRecuitmentDatas() async {
    await controller.fetchRecruitmentPosts();
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: .all(16.sp),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    searchBarField(),
                    SizedBox(height: 8.h),
                    filterWidgets(),
                    SizedBox(height: 16.h),
                    mercenaryListWidget()
                  ]
                )
              )
            )
          )
        )
      )
    );
  }

  Widget searchBarField() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back_ios_new, color: subtitleTextColor),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          flex: 7,
          child: CustomTextFormField(
            headingText: "",
            headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
            textInputAction: TextInputAction.search,
            keyboardType: TextInputType.text,
            controller: controller.searchController,
            maxLines: 1,
            hintText: 'Search By Name',
            hintStyle: TextStyle(fontSize: 16.sp, color: disableButton, fontWeight: .normal),
            onChanged: (value)  {
              controller.onSearchChanged(value);
              setState(() { });
            },
            onFieldSubmitted: (value) {
              controller.onSearchChanged(value);
              setState(() { });
            },
            prefixIcon: Icon(Icons.search, color: disableButton),
            suffixIcon: IconButton(
              onPressed: () {
                controller.searchController.clear();
                controller.onSearchChanged('');
                setState(() { });
              }, 
              icon: Visibility(
                visible: controller.searchController.text != '',
                child: Icon(Icons.close, color: disableButton)
              )
            ),
            height: 56.h,
          ),
        )
      ],
    );
  }

  Widget filterWidgets() {
    return SizedBox(
      height: 35.h,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: filterItems.length,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: .horizontal,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder:(context, index) {
          return filterTileWidget(filterItems[index]);
        },
      ),
    );
  }

  Widget filterTileWidget(dynamic data) {
    return InkWell(
      onTap: () => setState(() => controller.selectedFilter = data),
      child: Container(
        decoration: BoxDecoration(
          color: controller.selectedFilter == data ? primaryColor : lightFilledBgColor,
          borderRadius: .circular(12.r)
        ),
        padding: .symmetric(vertical: 4.h, horizontal: 12.w),
        child: Center(
          child: Text(
            data,
            style: boldStyle(controller.selectedFilter == data ? black : whiteTextColor, 14.sp),
          ),
        ),
      ),
    );
  }

  Widget mercenaryListWidget() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: controller.filteredRecruitmentPosts.length,
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder:(context, index) {
        var data = controller.filteredRecruitmentPosts[index];
        return postTileWidget(data);
      },
    );
  }

  Widget postTileWidget(dynamic data) {
    final playerId = read('userId') ?? Supabase.instance.client.auth.currentUser?.id;
    final List<dynamic> requesters = data['requester_ids'] ?? [];
    final List<dynamic> acceptedPlayers = data['accepted_ids'] ?? [];
    
    final bool hasRequested = playerId != null && requesters.contains(playerId);
    final bool isAccepted = playerId != null && acceptedPlayers.contains(playerId);

    // Determine button text, styling, and interactivity based on status
    String buttonText = 'REQUEST TO JOIN';
    Color borderColor = primaryColor;
    Color textColor = primaryColor;
    bool isInteractive = true;

    if (hasRequested) {
      buttonText = 'CANCEL REQUEST TO JOIN';
      borderColor = Colors.red;
      textColor = Colors.red;
    } else if (isAccepted) {
      buttonText = 'REQUEST ACCEPTED';
      borderColor = Colors.green;
      textColor = Colors.green;
      isInteractive = false; // Non-clickable once accepted
    }

    return InkWell(
      onTap: () => Get.to(() => PlayerLocalDetail(postId: data['id'], details: data)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: .circular(24.r),
          color: filledBlueColor
        ),
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 192.h,
                  width: .infinity,
                  child: ClipRRect(
                    borderRadius: .circular(12.r),
                    child: SizedBox(
                      height: 64.h,
                      width: 64.w,
                      child: Image.asset(
                        'assets/images/court.png',
                        fit: .cover,
                      )
                    )
                  )
                ),
                SizedBox(
                  height: 192.h,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.h, left: 8.w, bottom: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                          child: Text(
                            '${data["slots_needed"]} Slots Open',
                            style: boldStyle(black, 12.sp),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          data['venue_name'],
                          style: semiBoldStyle(whiteTextColor, 20.sp).copyWith(height: 1.0),
                          maxLines: 2
                        ),
                        SizedBox(height: 4.h),
                        Visibility(
                          visible: data['address'] != null,
                          child: Row(
                            crossAxisAlignment: .start,
                            children: [
                              Icon(Icons.location_on_outlined, color: primaryColor, size: 15.sp),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  data['address'] ?? '',
                                  style: semiBoldStyle(subtitleTextColor, 14.sp),
                                  maxLines: 2,
                                ),
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: subtitleTextColor, size: 13.sp),
                            SizedBox(width: 4.w),
                            Text(
                              '${data['start_time'].toString().substring(0, 5)} - ${data['end_time'].toString().substring(0, 5)}',
                              style: regularStyle(subtitleTextColor, 14.sp),
                            ),
                            Text(
                              " • ${formatBookingDate(data['booking_date'])}",
                              style: regularStyle(subtitleTextColor, 14.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.h),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 40.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: lightFilledBgColor,
                          shape: .circle
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: .start,
                        mainAxisSize: .min,
                        children: [
                          Text(
                            data['group_name'],
                            style: semiBoldStyle(whiteTextColor, 16.sp).copyWith(height: 1.2)
                          ),
                          Text(
                            'Host: ${data["host_name"]}',
                            style: boldStyle(disableButton, 12.sp)
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 12.h),
                  InkWell(
                    onTap: isInteractive ? () async {
                      await controller.toggleJoinRequest(data['id'], hasRequested);
                      getRecuitmentDatas();
                    } : null,
                    child: Container(
                      width: Get.width * 0.85,
                      decoration: BoxDecoration(
                        border: .all(color: borderColor, width: 1.5.w),
                        borderRadius: .circular(12.r),
                        color: hasRequested 
                            ? red.withValues(alpha: 0.05) 
                            : isAccepted 
                                ? Colors.green.withValues(alpha: 0.05) 
                                : Colors.transparent,
                      ),
                      padding: .symmetric(vertical: 4.h),
                      child: Center(
                        child: Text(
                          buttonText,
                          style: semiBoldStyle(textColor, 16.sp)
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        )
      ),
    );
  }

  String formatBookingDate(String dateStr) {
    try {
      final DateTime bookingDate = DateTime.parse(dateStr);
      final DateTime now = DateTime.now();
      
      // Normalize dates to midnight to compare just the day
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime target = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);

      final int difference = target.difference(today).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Tomorrow';
      } else {
        // Returns the date as-is (e.g., "2026-09-05") or you can format it nicely
        return dateStr; 
      }
    } catch (e) {
      return dateStr;
    }
  }

}