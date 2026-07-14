import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/auth_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';

class PlayerProfilePage extends StatefulWidget {
  const PlayerProfilePage({super.key});

  @override
  State<PlayerProfilePage> createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage> {
  final AuthController _con = Get.put(AuthController());

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
                    profileSectionWidget(),
                    SizedBox(height: 24.h),
                    gameCountAndFavPitch(),
                    SizedBox(height: 24.h),
                    historyAndStuff(),
                    SizedBox(height: 24.h),
                    logOutBtn(),
                    SizedBox(height: 24.h),
                    appVersion()
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
    return Column(
      children: [
        Container(
          height: 96.h,
          width: 96.w,
          decoration: BoxDecoration(
            color: filledBgColor,
            border: Border.all(
              color: primaryColor,
              width: 1.5
            ),
            shape: .circle
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Ashok Shakya',
          style: TextStyle(
            color: whiteTextColor,
            fontWeight: .bold,
            fontSize: 28.sp
          ),
        ),
        Text(
          '+977 ******7215',
          style: TextStyle(
            color: whiteTextColor,
            fontSize: 16.sp
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: primaryColor
            ),
            borderRadius: .circular(18.r),
            color: primaryColor.withValues(alpha: 0.1)
          ),
          padding: .symmetric(horizontal: 12.w, vertical: 8.h),
          child: Text(
            'Ellite Booker (99% Show-up Rate)',
            style: TextStyle(
              color: primaryColor,
              fontSize: 12.sp,
              fontWeight: .bold
            ),
          ),
        )
      ]
    );
  }

  Widget gameCountAndFavPitch() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 110.h,
            decoration: BoxDecoration(
              color: filledBgColor,
              borderRadius: .circular(12.r)
            ),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Image.asset('assets/icons/ball.png', height: 25.h, width: 25.w),
                SizedBox(height: 4.h),
                Text(
                  '42',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 16.sp
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'GAMES',
                  style: TextStyle(
                    color: whiteTextColor,
                    fontSize: 10.sp
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Container(
            height: 110.h,
            decoration: BoxDecoration(
              color: filledBgColor,
              borderRadius: .circular(12.r)
            ),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Image.asset('assets/icons/fav.png', height: 25.h, width: 25.w),
                SizedBox(height: 4.h),
                Text(
                  'X-Arena',
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 16.sp
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'FAV PITCH',
                  style: TextStyle(
                    color: whiteTextColor,
                    fontSize: 10.sp
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget historyAndStuff() {
    return Container(
      // height: 120.h,
      decoration: BoxDecoration(
        color: filledBgColor,
        borderRadius: .circular(12.r)
      ),
      child: Padding(
        padding: .symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            historyTile(icon: Icons.star_border, label: 'Saved / Favorite Futsals', onTap: () {}),
            Divider(color: gray01),
            historyTile(icon: Icons.history, label: 'Transaction & Payment History', onTap: () {}),
            Divider(color: grayDark),
            historyTile(icon: Icons.question_mark, label: 'Support & Anti-Spam Guidelines', onTap: () {})
          ]
        ),
      )
    );
  }

  Widget historyTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: .symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              height: 41.h,
              width: 36.w,
              decoration: BoxDecoration(
                color: lightFilledBgColor,
                borderRadius: .circular(8.r)
              ),
              child: Icon(icon, color: whiteTextColor, size: 20.sp,)
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                color: whiteTextColor,
                fontSize: 16.sp
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: whiteTextColor, size: 16.h)
          ],
        ),
      ),
    );
  }

  Widget logOutBtn() {
    return CustomUsualButton(
      text: 'Log Out', 
      onPressed: () => _con.signOutUser(context),
      fontColor: Color(0xFFFFB4AB),
      borderColor: Color(0xFFFFB4AB),
      bgColor: Color(0xFFFFB4AB).withValues(alpha: 0.05),
    );
  }

  Widget appVersion() {
    return Text(
      'App Version 2.4.0 (Build 102)',
      style: TextStyle(
        color: subtitleTextColor.withValues(alpha: 0.4),
        fontSize: 16.sp
      ),
    );
  }

}