import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/auth_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/widgets/display_image.dart';
import 'package:get/get.dart';

class OwnerProfilePage extends StatefulWidget {
  const OwnerProfilePage({super.key});

  @override
  State<OwnerProfilePage> createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  final AuthController _authCon = Get.put(AuthController());

  bool isFacilityOpen = false;
  bool isNotificationOn = true;

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
                    SizedBox(height: 12.h),
                    profileSectionWidget(),
                    SizedBox(height: 24.h),
                    openingStatus(),
                    SizedBox(height: 24.h),
                    textLabel(label: 'VENUE & OPERATIONAL SETUP'),
                    SizedBox(height: 16.h),
                    tileCard(
                      icon: Icons.sports_soccer, 
                      title: 'Manage Venue & Pitches',  
                      subTitle: 'Edit facility info, add pitches, pricing & amenities',
                      isPrimary: true,
                      onTap: () {}
                    ),
                    SizedBox(height: 12.h),
                    tileCard(
                      icon: Icons.access_time, 
                      title: 'Operating Hours & Slots',  
                      subTitle: 'Set opening/closing times and slot durations',
                      onTap: () {}
                    ),
                    SizedBox(height: 12.h),
                    tileCard(
                      icon: Icons.badge_outlined, 
                      title: 'Staff & Operator Access',  
                      subTitle: 'Manage desk staff sub-accounts and permissions',
                      onTap: () {}
                    ),
                    SizedBox(height: 16.h),
                    textLabel(label: 'ACCOUNT & PREFERENCES'),
                    SizedBox(height: 16.h),
                    tileCard(
                      icon: Icons.account_balance, 
                      title: 'Payout Bank Account',  
                      subTitle: 'Connect bank for automated app payouts',
                      onTap: () {}
                    ),
                    SizedBox(height: 16.h),
                    tileCard(
                      icon: Icons.notifications_active_outlined, 
                      title: 'Call & Booking Alerts',  
                      subTitle: 'Stay updated on new requests',
                      onTap: () {},
                      isSwitch: true
                    ),
                    SizedBox(height: 16.h),
                    tileCard(
                      icon: Icons.support_agent, 
                      title: 'Help & Owner Support',  
                      subTitle: 'Get help with your venue portal',
                      onTap: () {}
                    ),
                    SizedBox(height: 32.h),
                    logOutBtn(),
                    SizedBox(height: 24.h),
                  ],
                )
              )
            )
          )
        )
      )
    );
  }

  Widget profileSectionWidget() {
    return Row(
      crossAxisAlignment: .center,
      children: [
        Container(
          height: 96.h,
          width: 96.w,
          decoration: BoxDecoration(
            color: filledBgColor,
            shape: .circle,
            border: .all(
              color: primaryColor,
              width: 2.w,
            ),
          ),
          child: Padding(
            padding: .symmetric(horizontal: 5.w), 
            child: _authCon.profile?.profilePic == null 
              ? const SizedBox()
              : ClipOval(
                child: DisplayNetworkImage(
                  imageUrl: _authCon.profile!.profilePic!,
                  boxFit: .cover,
                ),
              ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                _authCon.profile!.fullName,
                style: boldStyle(whiteTextColor, 28.sp).copyWith(height: 1.0)
              ),
              Text(
                'Sanepa, Lalitpur Nepal',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 16.sp
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: primaryColor,
                  ),
                  borderRadius: .circular(18.r),
                  color: primaryColor.withValues(alpha: 0.1)
                ),
                padding: .symmetric(horizontal: 12.w, vertical: 4.h),
                child: Row(
                  mainAxisSize: .min,
                  children: [
                    Icon(Icons.verified, color: primaryColor, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'VERIFIED OWNER',
                      style: boldStyle(primaryColor, 10.sp)
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget openingStatus() {
    return Container(
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: .circular(12.r)
      ),
      padding: .symmetric(vertical: 16.h, horizontal: 12.w),
      child: Row(
        children: [
          Container(
            height: 12.h,
            width: 12.w,
            decoration: BoxDecoration(
              shape: .circle,
              color: isFacilityOpen == true ? primaryColor : pinkDark,
              border: .all(color: isFacilityOpen == true ? transparent : pinkDark)
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .start,
              children: [
                Text(
                  'Facility Status',
                  style: regularStyle(subtitleTextColor, 14.sp),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Open Today",
                        style: semiBoldStyle(whiteTextColor, 20.sp),
                      ),
                      WidgetSpan(child: SizedBox(width: 8.w)),
                      TextSpan(
                        text: "(6:00 AM - 11:00 PM)",
                        style: semiBoldStyle(subtitleTextColor, 14.sp),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Switch(
            value: isFacilityOpen,
            activeThumbColor: primaryColor,
            activeTrackColor: primaryColor.withValues(alpha: 0.2),
            inactiveThumbColor: subtitleTextColor,
            inactiveTrackColor: lightFilledBgColor,
            onChanged: (value) => setState(() => isFacilityOpen = value )
          )
        ],
      ),
    );
  }

  Widget textLabel({required String label}) {
    return Text(
      label,
      style: boldStyle(subtitleTextColor, 12.sp),
    );
  }

  Widget tileCard({
    required IconData icon, 
    required String title, 
    required String subTitle, 
    required VoidCallback onTap, 
    bool? isPrimary,
    bool? isSwitch
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary == null ? filledBgColor : primaryColor.withValues(alpha: 0.1),
        borderRadius: .circular(12.r),
        border: .all(color: isPrimary == null ? gray01 : primaryColor)
      ),
      padding: .symmetric(vertical: 12.h, horizontal: 12.w),
      child: Row(
        children: [
          Container(
            height: 48.h,
            width: 48.w,
            decoration: BoxDecoration(
              color: isPrimary == null ? lightFilledBgColor : primaryColor,
              borderRadius: .circular(12.r)
            ),
            child: Icon(icon, size: 28.sp, color: isPrimary == null ? whiteTextColor : black)
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  title,
                  style: semiBoldStyle(isPrimary == null ? whiteTextColor : primaryColor, 20.sp).copyWith(height: 1.0),
                ),
                SizedBox(height: 6.h),
                Text(
                  subTitle,
                  style: regularStyle(subtitleTextColor, 14.sp).copyWith(height: 1.0),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: isSwitch == null
              ? Icon(
                Icons.arrow_forward_ios, 
                color: isPrimary == null ? whiteTextColor : primaryColor,
                size: 16.sp,
              )
              : Switch(
                value: isNotificationOn,
                activeThumbColor: primaryColor,
                activeTrackColor: primaryColor.withValues(alpha: 0.2),
                inactiveThumbColor: subtitleTextColor,
                inactiveTrackColor: lightFilledBgColor,
                onChanged: (value) => setState(() => isNotificationOn = value )
              )
          )
        ],
      ),
    );
  }

  Widget logOutBtn() {
    return InkWell(
      onTap: () => _authCon.signOutUser(context),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFB4AB).withValues(alpha: 0.05),
          borderRadius: .circular(12.r),
          border: .all(
            color: Color(0xFFFFB4AB).withValues(alpha: 0.5)
          ),
        ),
        padding: .symmetric(vertical: 12.h),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            Icon(Icons.logout, color: Color(0xFFFFB4AB), size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'Log Out of Owner Portal',
              style: regularStyle(Color(0xFFFFB4AB), 16.sp)
            )
          ],
        )
      ),
    );
  }

}