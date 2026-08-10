import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/controller/auth_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/validators.dart';
import 'package:futsal_dai/src/widgets/custom_appbar_widget.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:get/get.dart';

class VerifyPasswordPage extends StatefulWidget {
  final String email;
  const VerifyPasswordPage({super.key, required this.email});

  @override
  State<VerifyPasswordPage> createState() => _VerifyPasswordPageState();
}

class _VerifyPasswordPageState extends State<VerifyPasswordPage> {
  final formKey  = GlobalKey<FormState>();
  final authCon  = Get.put(AuthController());

  final emailCon       = TextEditingController();
  final securityCon    = TextEditingController();
  final passCon        = TextEditingController();
  final confirmPassCon = TextEditingController();

  bool isnewPassObscure     = true;
  bool isConfirmPassObscure = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(title: 'Reset Password'),
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
                  formWidget(),
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
    return Text(
      'Enter the code sent to your email to securely reset your password.',
      style: regularStyle(subtitleTextColor, 14.sp),
    );
  }

  Widget formWidget() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextFormField(
            headingText: "Email",
            headingTextStyle: TextStyle(fontSize: 14.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
            textInputAction: .next,
            keyboardType: .emailAddress,
            autoValidateMode: .onUserInteraction,
            controller: emailCon,
            maxLines: 1,
            hintText: 'futsal_pro@example.com',
            hintStyle: TextStyle(fontSize: 14.sp, color: disableButton, fontWeight: .normal),
            validator: (value) => validateEmail(string: value!),
          ),
          SizedBox(height: 12.h),
          CustomTextFormField(
            headingText: "Security Code",
            headingTextStyle: TextStyle(fontSize: 14.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
            textInputAction: .next,
            keyboardType: .number,
            autoValidateMode: .onUserInteraction,
            controller: securityCon,
            maxLines: 1,
            hintText: '123456',
            hintStyle: TextStyle(fontSize: 14.sp, color: disableButton, fontWeight: .normal),
            validator: (value) => validateEmail(string: value!),
          ),
          SizedBox(height: 12.h),
          CustomTextFormField(
            headingText: "New Password",
            headingTextStyle: TextStyle(fontSize: 14.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
            textInputAction: .next,
            keyboardType: .text,
            autoValidateMode: .onUserInteraction,
            controller: passCon,
            obscureText: isnewPassObscure,
            maxLines: 1,
            hintText: '********',
            hintStyle: TextStyle(fontSize: 14.sp, color: disableButton, fontWeight: .normal),
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
            ],
            validator: (value) => validateMinMaxLength(string: value!, minLegth: 8, maxLength: 20),
            onChanged: (value) { setState(() {}); },
            suffixIcon: IconButton(
              onPressed: () => setState(() => isnewPassObscure = !isnewPassObscure),
              icon: Icon(
                isnewPassObscure ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
              )
            ),
          ),
          SizedBox(height: 12.h),
          CustomTextFormField(
            headingText: "Confirm Password",
            headingTextStyle: TextStyle(fontSize: 14.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
            textInputAction: .next,
            keyboardType: .text,
            autoValidateMode: .onUserInteraction,
            controller: confirmPassCon,
            obscureText: isConfirmPassObscure,
            maxLines: 1,
            hintText: '********',
            hintStyle: TextStyle(fontSize: 14.sp, color: disableButton, fontWeight: .normal),
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
            ],
            validator: (value) => passCon.text == confirmPassCon.text ? null : "Password do not match.",
            onChanged: (value){ setState(() {});},
            suffixIcon: IconButton(
              onPressed: () => setState(() => isConfirmPassObscure = !isConfirmPassObscure),
              icon: Icon(
                isConfirmPassObscure ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget submitButton() {
    return InkWell(
      onTap: () {
        final isValid = formKey.currentState!.validate();
        if (!isValid) return;
        authCon.verifyAndResetPassword(context, emailCon.text.trim(), securityCon.text.trim(), passCon.text.trim());
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
              'Reset Password',
              style: semiBoldStyle(Color(0xFF022100), 16.sp),
            ),
          ),
        ),
      ),
    );
  }

}