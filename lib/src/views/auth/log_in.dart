import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/auth_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/validators.dart';
import 'package:futsal_dai/src/views/auth/register.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final AuthController authCon = Get.put(AuthController());
  final formKey = GlobalKey<FormState>();

  // bools
  bool isObscure = true;

  //Text Controllers
  final emailCon    = TextEditingController();
  final passwordCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: Column(
            mainAxisAlignment: .center,
            children: [
              header(),
              SizedBox(height: 24.h),
              logInForm(),
              SizedBox(height: 24.h),
              registerText()
            ],
          ),
        ),
      )
    );
  }

  Column header() {
    return Column(
      children: [
        Text(
          'FUTSAL DAI',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold, // Fixed typo from .bold
          ),
        ),
        Text(
          'The Futsal Revolution Starts Here',
          style: TextStyle(
            color: subtitleTextColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.normal, // Fixed typo from .bold
          ),
        ),
      ],
    );
  }
  
  ClipRRect logInForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black.withValues(alpha: 0.01), 
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08), 
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              CustomTextFormField(
                headingText: "EMAIL OR PHONE",
                headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                controller: emailCon,
                maxLines: 1,
                hintText: 'futsal_pro@example.com',
                hintStyle: TextStyle(fontSize: 16.sp, color: disableButton, fontWeight: .normal),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                ],
                validator: (value) => validateEmail(string: value!),
                onChanged: (value){
                  setState(() {});
                },
              ),
              SizedBox(height: 16.h),
              CustomTextFormField(
                headingText: "PASSWORD",
                headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
                keyboardType: TextInputType.text,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                controller: passwordCon,
                maxLines: 1,
                hintText: '********',
                hintStyle: TextStyle(fontSize: 16.sp, color: disableButton, fontWeight: .normal),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                ],
                validator: (value) => validateMinMaxLength(string: value!, minLegth: 8, maxLength: 15),
                onChanged: (value){
                  setState(() {});
                },
                // suffixIcon: IconButton(
                //   onPressed: (){
                //     setState(() {
                //       isObscure = !isObscure;
                //     });
                //   },
                //   icon: DisplayNetworkImage(
                //     imageUrl: isObscure ? 'assets/icons/eye_outlined.svg' : 'assets/icons/hide_post_icon.svg',
                //   )
                // ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: .end,
                children: [
                  Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 16.sp, color: primaryTextColor, fontWeight: .bold),
                  )
                ]
              ),
              SizedBox(height: 24.h),
              UsualButton(
                text: 'LOGIN',
                fontSize: 16.sp,
                fontWeight: .bold,
                onPressed: () {},
                height: 56.h,
              ),
              SizedBox(height: 24.h),
              // Text(
              //   '----- OR CONTINUE WITH -----',
              //   style: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: .normal),
              // ),
              // SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Row registerText() {
    return Row(
      mainAxisAlignment: .center,
      children: [
        Text(
          'New to Futsal Dai?',
          style: TextStyle(
            color: subtitleTextColor,
            fontWeight: .normal,
            fontSize: 16.sp
          )
        ),
        SizedBox(width: 8.w),
        InkWell(
          onTap: () => Get.to(() => RegisterPage()),
          child: Text(
            'Register here.',
            style: TextStyle(
              color: primaryTextColor,
              fontWeight: .bold,
              fontSize: 16.sp
            )
          ),
        ),
      ],
    );
  }

}