import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/constant.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/views/player/futsal_detail.dart';
import 'package:futsal_dai/src/views/player/player_booking_confirmation.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';

class PlayerHomePage extends StatefulWidget {
  const PlayerHomePage({super.key});

  @override
  State<PlayerHomePage> createState() => _PlayerHomePageState();
}

class _PlayerHomePageState extends State<PlayerHomePage> {

  final searchCon    = TextEditingController();
  
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
                  crossAxisAlignment: .start,
                  children: [
                    searchBarField(),
                    SizedBox(height: 16.h),
                    amenitiesWidget(),
                    SizedBox(height: 24.h),
                    nearMeWidgtes(),
                    SizedBox(height: 24.h),
                    featuredPitches(),
                    SizedBox(height: 24.h),
                    offersAndPass(),
                    SizedBox(height: 24.h),
                    findLocalTeam(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget searchBarField() {
    return CustomTextFormField(
      headingText: "",
      headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
      controller: searchCon,
      maxLines: 1,
      hintText: 'Search By Name',
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
    );
  }

  Widget amenitiesWidget() {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        itemCount: amenities.length,
        shrinkWrap: true,
        scrollDirection: .horizontal,
        separatorBuilder: (context, index) => SizedBox(width: 8.sp), 
        itemBuilder: (context, index) {
          var data = amenities[index];
          return InkWell(
            onTap: () => setState(() {
              data['isSelected'] = !data['isSelected'];
            }),
            child: Container(
              height: 34.h,
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              decoration: BoxDecoration(
                color: data['isSelected'] ? primaryColor : const Color(0xFF222D1E),
                borderRadius: BorderRadius.circular(20.r),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Icon(
                    data['icon'],
                    color: data['isSelected'] ? black : white,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    data['label'],
                    style: TextStyle(
                      color: data['isSelected'] ? black : white,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          );
        }, 
      ),
    );
  }

  Widget nearMeWidgtes() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Near Me',
          style: TextStyle(
            color: whiteTextColor,
            fontWeight: .bold,
            fontSize: 28.sp
          ),
        ),
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: whiteTextColor, size: 14.sp),
            SizedBox(width: 4.w),
            Text(
              'Lalitpur, Nepal',
              style: TextStyle(
                color: whiteTextColor,
                fontSize: 14.sp
              ),
            ),
            Spacer(),
            Text(
              'SEE MAP',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 12.sp,
                fontWeight: .bold
              ),
            )
          ],
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 240.h,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: 5,
            scrollDirection: .horizontal,
            separatorBuilder: (cntxt, idx) => SizedBox(width: 16.w), 
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => Get.to(() => FutsalDetail()),
                child: SizedBox(
                  width: 290.w,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Container(
                        height: 176.h,
                        width: 280.w,
                        decoration: BoxDecoration(
                          color: primaryTextColor,
                          borderRadius: .circular(12.r)
                        ),
                        child: Image.asset(
                          'assets/images/court.png',
                          fit: .cover,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Prismatic Futsal & Recreation Center',
                        style: TextStyle(
                          color: whiteTextColor,
                          fontSize: 20.sp,
                          fontWeight: .w600
                        ),
                        overflow: .ellipsis,
                      ),
                      Text(
                        '2.4 km - Sanepa, Lalitpur',
                        style: TextStyle(
                          color: whiteTextColor,
                          fontSize: 14.sp,
                          fontWeight: .normal
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

  Widget featuredPitches() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            'Featured Pitches',
            style: TextStyle(
              color: whiteTextColor,
              fontWeight: .bold,
              fontSize: 28.sp
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: containerBgColor,
            border: Border.all(
              color: Color(0xFF3C4B35),
              width: 1.w
            ),
            borderRadius: BorderRadius.circular(24.r)
          ),
          width: 360.w,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              ClipRRect(
                borderRadius: .only(
                  topLeft: .circular(24.r),
                  topRight: .circular(24.r)
                ),
                child: Container(
                  height: 192.h,
                  width: 360.w,
                  decoration: BoxDecoration(
                    borderRadius: .only(
                      topLeft: .circular(28.r),
                      topRight: .circular(28.r),
                    )
                  ),
                  child: Image.asset(
                    'assets/images/court.png',
                    fit: .cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'X-Arena Pro',
                      style: TextStyle(
                        fontWeight: .bold,
                        fontSize: 28.sp,
                        color: primaryTextColor
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "The city's most booked professional-grade pitch with FIFA standard turf.",
                      style: TextStyle(
                        fontWeight: .normal,
                        fontSize: 14.sp,
                        color: subtitleTextColor
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          "NPR 1,200/hr",
                          style: TextStyle(
                            fontWeight: .w600,
                            fontSize: 20.sp,
                            color: white
                          ),
                        ),
                        Spacer(),
                        CustomUsualButton(
                          text: 'Book Now', 
                          onPressed: () => Get.bottomSheet(
                            PlayerBookingConfirm(),
                            isScrollControlled: true,
                            ignoreSafeArea: false,
                          ),
                          height: 32.h,
                          width: 111.w,
                          padding: .zero,
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget offersAndPass() {
    return Container(
      decoration: BoxDecoration(
        color: containerBgColor,
        border: Border.all(
          color: Color(0xFF3C4B35),
          width: 1.w
        ),
        borderRadius: BorderRadius.circular(24.r)
      ),
      width: double.infinity,
      child: Padding(
        padding: .symmetric(horizontal: 16.sp, vertical: 24.sp),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/icons/award.png',
                  height: 32.h,
                ),
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFD6A8),
                    borderRadius: .circular(8.r)
                  ),
                  padding: .symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Text(
                    'HOT DEAL',
                    style: TextStyle(
                      color: Color(0xFF895600),
                      fontSize: 12.sp,
                      fontWeight: .bold
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              'Weekend Warrior Pass',
              style: TextStyle(
                fontWeight: .w600,
                fontSize: 20.sp,
                color: whiteTextColor
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Get 20% off on all morning slots this Sunday at Lalitpur Field.',
              style: TextStyle(
                fontWeight: .normal,
                fontSize: 14.sp,
                color: whiteTextColor,
                height: 1.3
              ),
            ),
            SizedBox(height: 16.h),
            CustomUsualButton(
              text: 'Claim Now', 
              onPressed: () {},
              height: 36.h,
              padding: .zero,
              bgColor: transparent,
              borderColor: primaryColor,
              fontColor: primaryTextColor,
            )
          ],
        ),
      ),
    );
  }
  
  Widget findLocalTeam() {
    return Container(
      decoration: BoxDecoration(
        color: containerBgColor,
        border: Border.all(
          color: Color(0xFF3C4B35),
          width: 1.w
        ),
        borderRadius: BorderRadius.circular(24.r)
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          ClipRRect(
            borderRadius: .only(
              topLeft: .circular(24.r),
              topRight: .circular(24.r)
            ),
            child: SizedBox(
              height: 130.h,
              width: double.infinity,
              child: Image.asset(
                'assets/images/court.png',
                fit: .fill,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 16.sp),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  "Find a Team",
                  style: TextStyle(
                    fontWeight: .w600,
                    fontSize: 20.sp,
                    color: whiteTextColor
                  ),
                ),
                Text(
                  "Join local squads looking for an extra player.",
                  style: TextStyle(
                    fontWeight: .normal,
                    fontSize: 14.sp,
                    color: whiteTextColor
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}