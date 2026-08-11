import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/group_controller.dart';
import 'package:futsal_dai/src/helper/cache_manager.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/model/group_model.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:get/get.dart';

class PlayerGroupDetail extends StatefulWidget {
  final dynamic data;
  const PlayerGroupDetail({super.key, required this.data});

  @override
  State<PlayerGroupDetail> createState() => _PlayerGroupDetailState();
}

class _PlayerGroupDetailState extends State<PlayerGroupDetail> {
  final GroupController controller = Get.put(GroupController());

  List pendingList = [];
  List joinedList = [];
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      joinedList = widget.data.groupMembers.where((member) => member.status == 'active').toList();
      pendingList = widget.data.groupMembers.where((member) => member.status == 'pending').toList();
      String? adminUserId = joinedList.where((member) => member.role == 'admin').firstOrNull?.userId;
      isAdmin = read('userId') == adminUserId;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        title: 'Manage Group', 
        // action: Icon(Icons.edit, color: subtitleTextColor)
      ),
      extendBodyBehindAppBar: true,
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
                    SizedBox(height: 12.h),
                    headerWidget(),
                    SizedBox(height: isAdmin ? 12.h : 24.h),
                    if(isAdmin) searchWidget(),
                    if(isAdmin) SizedBox(height: 16.h),
                    labelWidget(label: 'Pending Invites (${pendingList.length})'),
                    SizedBox(height: 8.h),
                    pendingListWidget(),
                    SizedBox(height: 16.h),
                    labelWidget(label: 'Group Members (${joinedList.length})'),
                    SizedBox(height: 8.h),
                    membersListWidget(),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget headerWidget() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          widget.data.name,
          style: boldStyle(primaryTextColor, 28.sp),
        ),
        Text(
          '${joinedList.length} MEMBERS JOINED • ${pendingList.length} PENDING INVITES',
          style: semiBoldStyle(whiteTextColor, 12.sp),
        )
      ],
    );
  }

  Widget searchWidget() {
    return Column(
      children: [
        CustomTextFormField(
          headingText: "",
          headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
          textInputAction: TextInputAction.search,
          keyboardType: TextInputType.text,
          controller: controller.searchController,
          maxLines: 1,
          hintText: 'Search Player By Name or Email',
          hintStyle: TextStyle(fontSize: 14.sp, color: disableButton, fontWeight: .normal),
          onChanged: (value) {
            controller.searchUsers(value);
            setState(() { });
          },
          onFieldSubmitted: (value) => controller.searchUsers,
          prefixIcon: Icon(Icons.search, color: disableButton),
          suffixIcon: IconButton(
            onPressed: () {
              controller.searchController.clear();
              controller.searchResults.clear();
              setState(() { });
            }, 
            icon: Visibility(
              visible: controller.searchController.text != '',
              child: Icon(Icons.close, color: disableButton)
            )
          ),
          height: 56.h,
        ),
        SizedBox(height: 18.h),
        Obx(() {
          if (controller.searchResults.isEmpty) return const SizedBox.shrink();
          return ListView.separated(
            shrinkWrap: true,
            itemCount: controller.searchResults.length,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder:(context, index) {
              var data = controller.searchResults[index];
              return addWidget(data: data);
            },
          );
        })
      ]
    );
  }

  Widget addWidget({required dynamic data}) {
    return Container(
      padding: .symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: .circular(12.r)
      ),
      child: Row(
        children: [
          Container(
            height: 48.h,
            width: 48.w,
            decoration: BoxDecoration(
              color: lightFilledBgColor,
              shape: .circle
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  data['full_name'],
                  style: semiBoldStyle(whiteTextColor, 18.sp),
                  maxLines: 1,
                  overflow: .ellipsis
                ),
                Text(
                  "@${data['username']}",
                  style: regularStyle(subtitleTextColor, 14.sp),
                  maxLines: 1,
                  overflow: .ellipsis
                )
              ],
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () async {
              await controller.addMemberToGroup(widget.data.id, data['id']);
              await controller.fetchMyGroups();
              final newMember = GroupMemberModel(
                userId: data['id'],
                status: 'pending',
                role  : 'member',
                user  : UserModel.fromJson(data),   // Adjust this if your nested user model constructor differs
              );
              setState(() {
                pendingList.add(newMember);
                controller.searchController.clear();
                controller.searchResults.clear();
              });
            },
            child: Container(
              padding: .symmetric(vertical: 4.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color       : transparent,
                borderRadius: .circular(18.r),
                border      : .all(color: primaryColor)
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: primaryColor),
                  SizedBox(width: 4.w),
                  Text(
                    'Add',
                    style: boldStyle(primaryColor, 12.sp),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget labelWidget({required String label}) {
    return Text(
      label,
      style: semiBoldStyle(white, 18.sp),
    );
  }

  Widget pendingListWidget() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: pendingList.length,
      separatorBuilder:(context, index) => SizedBox(height: 8.h), 
      itemBuilder:(context, index) {
        var data = pendingList[index];
        return pendingTileWidget(data: data, index: index);        
      }, 
    );
  }

  Widget pendingTileWidget({required dynamic data, required int index}) {
    return Container(
      padding: .symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: .circular(12.r)
      ),
      child: Row(
        children: [
          Container(
            height: 48.h,
            width: 48.w,
            decoration: BoxDecoration(
              color: lightFilledBgColor,
              shape: .circle
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  data.user!.fullName,
                  style: semiBoldStyle(whiteTextColor, 18.sp),
                  maxLines: 1,
                  overflow: .ellipsis
                ),
                Text(
                  '@${data.user!.username}',
                  style: boldStyle(subtitleTextColor, 14.sp),
                  maxLines: 1,
                  overflow: .ellipsis
                )
              ],
            ),
          ),
          if(isAdmin) Spacer(),
          if(isAdmin)
            InkWell(
              onTap: () async {
                await controller.updateGroupInvite(widget.data.id, data.userId, 'remove');
                await controller.fetchMyGroups();
                setState(() => pendingList.removeAt(index));
              },
              child: Container(
                padding: .symmetric(vertical: 4.h, horizontal: 8.w),
                decoration: BoxDecoration(
                  color: transparent,
                  borderRadius: .circular(18.r),
                  border: .all(color: Color(0xFFFFB4AB))
                ),
                child: Text(
                  'Cancel',
                  style: boldStyle(Color(0xFFFFB4AB), 12.sp),
                ),
              ),
            ),
          if(data.user!.id == read('userId')) Spacer(),
          if(data.user!.id == read('userId'))
            InkWell(
              onTap: () async {
                await controller.updateGroupInvite(widget.data.id, data.userId, 'active');
                await controller.fetchMyGroups();

                final newMember = GroupMemberModel(
                  userId: data.userId,
                  status: 'active',
                  role  : 'member',
                  user  : data.user
                );
                setState(() {
                  pendingList.removeAt(index);
                  joinedList.add(newMember);
                });
              },
              child: Container(
                padding: .symmetric(vertical: 4.h, horizontal: 8.w),
                decoration: BoxDecoration(
                  color: transparent,
                  borderRadius: .circular(18.r),
                  border: .all(color: primaryTextColor)
                ),
                child: Text(
                  'Accept',
                  style: boldStyle(primaryTextColor, 12.sp),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget membersListWidget() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: joinedList.length,
      separatorBuilder:(context, index) => SizedBox(height: 8.h), 
      itemBuilder:(context, index) {
        var data = joinedList[index];
        return membersWidget(data: data, index: index);
      }, 
    );
  }

  Widget membersWidget({required dynamic data, required int index}) {
    return Container(
      padding: .symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: .circular(12.r)
      ),
      child: Row(
        children: [
          Container(
            height: 48.h,
            width: 48.w,
            decoration: BoxDecoration(
              color: lightFilledBgColor,
              shape: .circle
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  data.user!.fullName,
                  style: semiBoldStyle(whiteTextColor, 18.sp),
                  maxLines: 1,
                  overflow: .ellipsis
                ),
                Text(
                  '@${data.user!.username}',
                  style: boldStyle(subtitleTextColor, 14.sp),
                  maxLines: 1,
                  overflow: .ellipsis
                )
              ],
            ),
          ),
          if(data.user!.id == read('userId')) Spacer(),
          if(data.user!.id == read('userId')) 
            IconButton(
              onPressed: () async {
                await controller.updateGroupInvite(widget.data.id, data.userId, 'remove');
                await controller.fetchMyGroups();
                setState(() => joinedList.removeAt(index));
              }, 
              icon: Icon(Icons.exit_to_app_outlined, color: primaryTextColor)
            )
        ],
      ),
    );
  }

}