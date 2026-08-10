import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/auth_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/validators.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:get/get.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final formKey  = GlobalKey<FormState>();
  final authCon  = Get.put(AuthController());
  final emailCon = TextEditingController();

  @override
  void dispose() {
    emailCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(title: ''),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          child: SafeArea(
            child: Padding(
              padding: .all(16.sp),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  headerTextWidget(),
                  SizedBox(height: 24.h),
                  emailWidget(),
                  Spacer(),
                  submitButton()
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  Widget headerTextWidget() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Forgot Password?',
          style: boldStyle(whiteTextColor, 28.sp),
        ),
        SizedBox(height: 12.h),
        Text(
          'Enter your registered email address below. An OTP verification code will be sent to your email.',
          style: regularStyle(subtitleTextColor, 16.sp),
        )
      ],
    );
  }

  Widget emailWidget() {
    return Form(
      key: formKey,
      child: CustomTextFormField(
        headingText: "EMAIL",
        headingTextStyle: TextStyle(fontSize: 14.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        autoValidateMode: AutovalidateMode.onUserInteraction,
        controller: emailCon,
        maxLines: 1,
        hintText: 'futsal_pro@example.com',
        hintStyle: TextStyle(fontSize: 14.sp, color: disableButton, fontWeight: .normal),
        validator: (value) => validateEmail(string: value!),
        onChanged: (value){
          setState(() {});
        },
      ),
    );
  }

  Widget submitButton() {
    return InkWell(
      onTap: () {
        final isValid = formKey.currentState!.validate();
        if (!isValid) return;
        authCon.resetPassword(context, emailCon.text.trim());
      },
      child: Center(
        child: Container(
          width: Get.width * .75,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: .circular(8.r)
          ),
          padding: .symmetric(vertical: 12.h, horizontal: 16.w),
          child: Center(
            child: Text(
              'Send Verification Code',
              style: semiBoldStyle(Color(0xFF022100), 16.sp),
            ),
          ),
        ),
      ),
    );
  }

}