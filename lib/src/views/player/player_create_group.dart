import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/group_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/validators.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:get/get.dart';

class PlayerCreateGroup extends StatelessWidget {
  PlayerCreateGroup({super.key});

  final GroupController controller = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(title: 'Create New Group'),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: Padding(
            padding: .symmetric(horizontal: 16.w),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    avatarWidgets(),
                    SizedBox(height: 20.h),
                    groupFormWidgets(),
                    SizedBox(height: 20.h),
                    addMembersSection(),
                    SizedBox(height: 40.h),
                    createGroupButton(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget avatarWidgets() {
    return Column(
      children: [
        Container(
          height: 90.h,
          width: 90.w,
          decoration: BoxDecoration(
            color: lightFilledBgColor,
            shape: .circle,
          ),
          child: Icon(
            Icons.camera_alt_outlined,
            color: primaryColor,
            size: 26.sp,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'ADD GROUP ICON (OPTIONAL)',
          style: boldStyle(subtitleTextColor, 14.sp),
        )
      ],
    );
  }

  Widget groupFormWidgets() {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          CustomTextFormField(
            headingText: "GROUP NAME",
            headingTextStyle: regularStyle(subtitleTextColor, 14.sp),
            textInputAction: .next,
            keyboardType: .text,
            autoValidateMode: .onUserInteraction,
            controller: controller.groupNameCon,
            maxLines: 1,
            hintText: 'Crews Of Nepal',
            hintStyle: regularStyle(disableButton, 14.sp),
            validator: (value) => validateIsEmpty(string: value!),
          ),
          SizedBox(height: 14.h),
          CustomTextFormField(
            headingText: "DESCRIPTION (OPTIONAL)",
            headingTextStyle: regularStyle(subtitleTextColor, 14.sp),
            textInputAction: .next,
            keyboardType: .text,
            controller: controller.descriptionCon,
            maxLines: 3,
            hintText: 'Playing every saturday 6-7 at sera futsal.',
            hintStyle: regularStyle(disableButton, 14.sp),
          ),
        ],
      ),
    );
  }

  Widget addMembersSection() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomTextFormField(
          headingText: "ADD MEMBERS",
          headingTextStyle: regularStyle(subtitleTextColor, 14.sp),
          textInputAction: .search,
          keyboardType: .text,
          controller: controller.searchController,
          maxLines: 1,
          hintText: 'Search by name or username',
          hintStyle: regularStyle(disableButton, 14.sp),
          onChanged: controller.searchUsers,
        ),
        SizedBox(height: 8.h),

        // Search Results Dropdown List
        Obx(() {
          if (controller.searchResults.isEmpty) return const SizedBox.shrink();
          return Container(
            decoration: BoxDecoration(
              color: lightFilledBgColor,
              borderRadius: .circular(8.r),
              border: .all(color: subtitleTextColor.withValues(alpha: 0.2)),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.searchResults.length,
              itemBuilder: (context, index) {
                final user = controller.searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user['profile_pic'] != null
                        ? NetworkImage(user['profile_pic'])
                        : null,
                    child: user['profile_pic'] == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(user['full_name'] ?? 'No Name', style: regularStyle(subtitleTextColor, 14.sp)),
                  subtitle: Text('@${user['username']}', style: regularStyle(subtitleTextColor, 14.sp)),
                  onTap: () => controller.selectUser(user),
                );
              },
            ),
          );
        }),

        SizedBox(height: 12.h),

        // Selected Members Chips Section
        Obx(() {
          if (controller.selectedMembers.isEmpty) return const SizedBox.shrink();
          return Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: controller.selectedMembers.map((member) {
              return Chip(
                backgroundColor: lightFilledBgColor,
                label: Text(
                  member['full_name'] ?? member['username'],
                  style: regularStyle(whiteTextColor, 12.sp),
                ),
                deleteIcon: Icon(Icons.close, size: 16.sp, color: subtitleTextColor),
                onDeleted: () => controller.removeUser(member['id']),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget createGroupButton() {
    return SizedBox(
      width: .infinity,
      height: 50.h,
      child: Obx(() {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          onPressed: controller.isLoading.value ? null : controller.createGroup,
          child: controller.isLoading.value
            ? SizedBox(
              height: 20.h,
              width: 20.w,
              child: const CircularProgressIndicator(color: Colors.black),
            )
            : Text(
              'CREATE GROUP →',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
        );
      }),
    );
  }
}