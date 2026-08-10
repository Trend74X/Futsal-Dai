import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/group_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/views/player/player_create_group.dart';
import 'package:futsal_dai/src/views/player/player_group_details.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';
import 'package:get/get.dart';

class PlayerGroupList extends StatefulWidget {
  const PlayerGroupList({super.key});

  @override
  State<PlayerGroupList> createState() => _PlayerGroupListState();
}

class _PlayerGroupListState extends State<PlayerGroupList> {
  final GroupController _con = Get.put(GroupController());

  @override
  void initState() {
    super.initState();
    _con.fetchMyGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(title: 'My Groups'),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Obx(() =>
                  _con.isLoading.isTrue
                    ? SizedBox(
                      height: Get.height * 0.85,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF39FF14)),
                        ),
                      ),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        newGroupButton(),
                        SizedBox(height: 24.h),
                        listOfGroupWidgets()
                      ],
                    )
                )
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget newGroupButton() {
    return InkWell(
      onTap: () => Get.to(() => PlayerCreateGroup()),
      child: Container(
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
      ),
    );
  }

  Widget listOfGroupWidgets() {
    return _con.groupsList.isEmpty
      ? SizedBox(
        height: Get.height * 0.5,
        child: Center(
          child: Text(
            'There are not groups created yet',
            style: boldStyle(subtitleTextColor, 14.sp),
          ),
        ),
      )
      : ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _con.groupsList.length,
        separatorBuilder:(context, index) => SizedBox(height: 8.h), 
        itemBuilder:(context, index) {
          var data = _con.groupsList[index];
          int joinedCount = data.groupMembers.where((member) => member.status == 'active').length;
          return groupListTile(data: data, count: joinedCount);
        }, 
      );
  }

  Widget groupListTile({required dynamic data, required int count}) {
    return InkWell(
      onTap: () => Get.to(() => PlayerGroupDetail(data: data)),
      child: Container(
        decoration: BoxDecoration(
          color: filledBgColor,
          borderRadius: .circular(16.r)
        ),
        padding: .all(12.sp),
        child: Row(
          children: [
            Container(
              height: 52.h,
              width: 52.w,
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
                  data.name,
                  style: semiBoldStyle(whiteTextColor, 18.sp)
                ),
                Text(
                  '$count Members',
                  style: regularStyle(subtitleTextColor, 14.sp)
                )
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: subtitleTextColor, size: 18.sp)
          ],
        ),
      ),
    );
  }

}