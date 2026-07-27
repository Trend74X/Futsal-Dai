import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:get/get.dart';

class PlayerGroupDetail extends StatefulWidget {
  const PlayerGroupDetail({super.key});

  @override
  State<PlayerGroupDetail> createState() => _PlayerGroupDetailState();
}

class _PlayerGroupDetailState extends State<PlayerGroupDetail> {

  final searchCon    = TextEditingController();
  
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
                    headerWidget(),
                    SizedBox(height: 12.h),
                    searchWidget(),
                    SizedBox(height: 16.h),
                    labelWidget(label: 'Pending Invites (2)'),
                    SizedBox(height: 8.h),
                    pendingListWidget(),
                    SizedBox(height: 16.h),
                    labelWidget(label: 'Group Members'),
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

  Widget appbarWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, color: subtitleTextColor),
        ),
        Text('Manage Group', style: boldStyle(whiteTextColor, 24.sp)),
        Icon(Icons.edit, color: subtitleTextColor)
      ],
    );
  }

  Widget headerWidget() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Weekend Warriors',
          style: boldStyle(primaryTextColor, 32.sp),
        ),
        Text(
          '12 MEMBERS JOINED • 2 PENDING INVITES',
          style: semiBoldStyle(whiteTextColor, 14.sp),
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
          controller: searchCon,
          maxLines: 1,
          hintText: 'Search Player By Name or Email',
          hintStyle: TextStyle(fontSize: 16.sp, color: disableButton, fontWeight: .normal),
          onChanged: (value) => setState(() { }),
          onFieldSubmitted: (value) {
            if(value != '') log('searched $value');
          },
          prefixIcon: Icon(Icons.search, color: disableButton),
          suffixIcon: IconButton(
            onPressed: () {
              searchCon.clear();
              setState(() { });
            }, 
            icon: Visibility(
              visible: searchCon.text != '',
              child: Icon(Icons.close, color: disableButton)
            )
          ),
          height: 56.h,
        ),
        SizedBox(height: 18.h),
        addWidget(name: 'Anish Shakya', email: 'shk_anic01@gmail.com'),
        SizedBox(height: 8.h),
        addWidget(name: 'Amrit Shakya', email: 'amrit.shk00@gmail.com'),
      ]
    );
  }

  Widget addWidget({required String name, required String email}) {
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
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                name,
                style: semiBoldStyle(whiteTextColor, 20.sp)
              ),
              Text(
                email,
                style: regularStyle(whiteTextColor, 14.sp)
              )
            ],
          ),
          Spacer(),
          Container(
            padding: .symmetric(vertical: 4.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: transparent,
              borderRadius: .circular(18.r),
              border: .all(color: primaryColor)
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
          )
        ],
      ),
    );
  }

  Widget labelWidget({required String label}) {
    return Text(
      label,
      style: semiBoldStyle(white, 20.sp),
    );
  }

  Widget pendingListWidget() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        pendingWidget(name: 'Pradip'),
        SizedBox(height: 8.h),
        pendingWidget(name: 'Sandip Shakya'),
      ],
    );
  }

  Widget pendingWidget({required String name}) {
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
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                name,
                style: semiBoldStyle(whiteTextColor, 20.sp)
              ),
              Text(
                'PENDING',
                style: boldStyle(Color(0xFFFFB95F), 10.sp)
              )
            ],
          ),
          Spacer(),
          Container(
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
          )
        ],
      ),
    );
  }

  Widget membersListWidget() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        membersWidget(name: 'Ashok Shakya', count: '24'),
        SizedBox(height: 8.h),
        membersWidget(name: 'Pradip', count: '12'),
        SizedBox(height: 8.h),
        membersWidget(name: 'Sajit Shakya', count: '8'),
        SizedBox(height: 8.h),
        membersWidget(name: 'Sandip Shakya', count: '8'),
      ],
    );
  }

  Widget membersWidget({required String name, required String count}) {
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
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                name,
                style: semiBoldStyle(whiteTextColor, 20.sp)
              ),
              Text(
                'Matches Played : $count',
                style: boldStyle(subtitleTextColor, 14.sp)
              )
            ],
          ),
          Spacer(),
          Icon(Icons.more_vert, color: whiteTextColor)
        ],
      ),
    );
  }

}