import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/views/player/player_group_details.dart';
import 'package:get/get.dart';

class PlayerGroupList extends StatefulWidget {
  const PlayerGroupList({super.key});

  @override
  State<PlayerGroupList> createState() => _PlayerGroupListState();
}

class _PlayerGroupListState extends State<PlayerGroupList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appbarWidget(),
                    SizedBox(height: 12.h),
                    newGroupButton(),
                    SizedBox(height: 24.h),
                    listOfGroupWidgets()
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, color: subtitleTextColor),
        ),
        Text('My Groups', style: boldStyle(whiteTextColor, 24.sp)),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget newGroupButton() {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: .circular(24.r)
      ),
      padding: .all(12.sp),
      child: Row(
        mainAxisAlignment: .center,
        children: [
          Icon(Icons.person_add_alt, color: black),
          SizedBox(width: 8.w),
          Text(
            'Create New Group',
            style: semiBoldStyle(black, 16.sp)
          )
        ],
      )
    );
  }

  Widget listOfGroupWidgets() {
    return Column(
      children: [
        groupListTile(title: 'Saturday Strikers', subtitle: '12 Members'),
        SizedBox(height: 8.h),
        groupListTile(title: 'Weekend Warriros', subtitle: '10 Members'),
        SizedBox(height: 8.h),
        groupListTile(title: 'Office Tutsal Squad', subtitle: '15 Members'),
        SizedBox(height: 8.h)
      ],
    );
  }

  Widget groupListTile({required String title, required String subtitle}) {
    return InkWell(
      onTap: () => Get.to(() => PlayerGroupDetail()),
      child: Container(
        decoration: BoxDecoration(
          color: filledBgColor,
          borderRadius: .circular(16.r)
        ),
        padding: .all(12.sp),
        child: Row(
          children: [
            Container(
              height: 56.h,
              width: 56.w,
              decoration: BoxDecoration(
                color: lightFilledBgColor,
                shape: .circle
              ),
            ),
            SizedBox(width: 6.w),
            Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  title,
                  style: semiBoldStyle(whiteTextColor, 20.sp)
                ),
                Text(
                  subtitle,
                  style: regularStyle(whiteTextColor, 14.sp)
                )
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: subtitleTextColor)
          ],
        ),
      ),
    );
  }

}