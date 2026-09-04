import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/auth_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/views/auth/log_in.dart';
import 'package:get/get.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

// 1. Added SingleTickerProviderStateMixin to handle the 5-second animation ticker
class _SplashScreenPageState extends State<SplashScreenPage> with SingleTickerProviderStateMixin {
  final authCon = Get.put(AuthController());
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    final session = authCon.supabase.auth.currentSession;

    // 2. Initialize the 5-second controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // 3. Linearly animate from 0.0 to 1.0 (0% to 100%)
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {}); // Rebuild to update progress bar frames
      });

    // 4. Start the loading animation immediately
    _controller.forward();
    
    // Optional: If you want to navigate automatically to the next screen after 5 seconds:
    _controller.forward().then((_) {
      if(session == null) {
        Get.offAll(() => LogInPage());
      } else {
        authCon.getUserById(session.user.id);
      }
      // Get.offAll(() => session != null ? PlayerBottomsheet() : LogInPage());
    });
    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: bgImg(),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 300.h),
              logoAndText(),
              SizedBox(height: 200.h),
              linearProgress(),
              SizedBox(height: 18.h),
              lastSub(),
              SizedBox(height: 64.h),
            ],
          ),
        ),
      ),
    );
  }

  Column logoAndText() {
    return Column(
      children: [
        Image.asset(
          'assets/icons/ball.png',
          width: 200.w,
          height: 200.h,
        ),
        Text(
          'FUTSAL DAI',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 28.sp,
            fontWeight: FontWeight.bold, // Fixed typo from .bold
          ),
        ),
        Text(
          'READY TO PLAY',
          style: TextStyle(
            color: subtitleTextColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold, // Fixed typo from .bold
          ),
        ),
      ],
    );
  }

  Padding linearProgress() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50.w), // Margins for the bar
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10), // Gives it smooth rounded edges
        child: SizedBox(
          height: 6.h, // Height thickness of the loading bar
          child: LinearProgressIndicator(
            value: _animation.value, // Connects to the 5-second sequence
            backgroundColor: Colors.white.withValues(alpha: 0.15), // Muted track trail
            valueColor: AlwaysStoppedAnimation<Color>(
              primaryTextColor, // Uses your style helper's main text or highlight color
            ),
          ),
        ),
      ),
    );
  }

  Text lastSub() {
    return Text(
      'Urban futsal redefined. Speed, precision,\nand the pulse of the pitch right at your\nfingertips.',
      style: TextStyle(
        color: subtitleTextColor,
        fontSize: 12.sp,
        fontWeight: FontWeight.normal, 
      ),
      textAlign: TextAlign.center,
    );
  }

}