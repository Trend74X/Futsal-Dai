import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:futsal_dai/src/controller/auth_controller.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/validators.dart';
import 'package:futsal_dai/src/views/auth/log_in.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:futsal_dai/src/widgets/custom_usual_button.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final AuthController authCon = Get.find();

  String selectedRole = 'player';

  final fullNameCon = TextEditingController();
  final phoneNoCon  = TextEditingController();
  final emailCon    = TextEditingController();
  final passwordCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      body: SizedBox.expand(
        child: Container(
          decoration: bgImg(),
          // Move horizontal padding here so it applies to the whole view, 
          // but keep vertical padding managed by slivers so it doesn't clip badly.
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w), 
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 80.h),
                  appbarWidget(),
                  SizedBox(height: 24.h),
                  titles(),
                  SizedBox(height: 24.h),
                  selectingRole(),
                  SizedBox(height: 24.h),
                  registerForm(),
                  SizedBox(height: 64.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row appbarWidget() {
    return Row(
      children: [
        Text(
          'Futsal Dai',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        Spacer(),
        InkWell(
          onTap: () => Get.back(),
          child: Text(
            'LOGIN',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: subtitleTextColor,
            ),
          ),
        )
      ],
    );
    
    
    // SliverAppBar(
    //   title: Text(
    //     'Futsal Dai',
    //     style: TextStyle(
    //       fontSize: 28.sp,
    //       fontWeight: FontWeight.bold,
    //       color: primaryTextColor,
    //     ),
    //   ),
    //   automaticallyImplyLeading: false,
    //   backgroundColor: Colors.transparent,
    //   centerTitle: false,
    //   titleSpacing: 20.w,
      
    //   actions: [
    //     Center(
    //       child: InkWell(
    //         onTap: () => Get.back(),
    //         child: Text(
    //           'LOGIN',
    //           style: TextStyle(
    //             fontSize: 16.sp,
    //             fontWeight: FontWeight.bold,
    //             color: subtitleTextColor,
    //           ),
    //         ),
    //       ),
    //     ),
    //     SizedBox(width: 24.w),
    //   ],
      
    //   // --- SCROLL CONFIGURATION ---
    //   floating: true,  
    //   snap: true,      
    //   pinned: false,   
    // );
  }

  Column titles() {
    return Column(
      crossAxisAlignment: .center,
      children: [
        Text(
          'Unleash the Power.',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: .bold,
            color: primaryTextColor
          )
        ),
        SizedBox(height: 18.h),
        Center(
          child: Text(
            "Join the ultimate futsal ecosystem. Whether\nyou're dominating the pitch or running the\nstadium, your journey starts here.",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: .normal,
              color: subtitleTextColor
            ),
            textAlign: .center
          ),
        )
      ]
    );
  }

  Column selectingRole() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'SELECT YOUR ROLE',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: .bold,
            color: subtitleTextColor
          )
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() => selectedRole = 'player');
                },
                child: Container(
                  height: 173.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: Color(0xFF0E171D)
                  ),
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/player.svg',
                        width: 52.w,
                        height: 52.h,
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(selectedRole == 'player' ? primaryColor : white, BlendMode.srcIn),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'I am a \nPlayer',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: .bold,
                          color: selectedRole == 'player' ? primaryColor : white,
                          height: 1.1
                        ),
                        textAlign: .center
                      )
                    ],
                  ),
                ),
              )
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() => selectedRole = 'owner');
                },
                child: Container(
                  height: 173.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: Color(0xFF0E171D)
                  ),
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/owner.svg',
                        width: 52.w,
                        height: 52.h,
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(selectedRole == 'owner' ? primaryColor : white, BlendMode.srcIn),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'I am an \nOwner',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: .bold,
                          color: selectedRole == 'owner' ? primaryColor : white,
                          height: 1.1
                        ),
                        textAlign: .center
                      )
                    ],
                  ),
                ),
              )
            ),
          ],
        )
      ],
    ); 
  }

  ClipRRect registerForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Color(0xFF0E171D),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08), 
            width: 1.0,
          ),
        ),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              CustomTextFormField(
                headingText: "Full Name",
                headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                controller: fullNameCon,
                maxLines: 1,
                hintText: 'Cristiano Ronaldo',
                hintStyle: TextStyle(fontSize: 16.sp, color: disableButton, fontWeight: .normal),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                ],
                validator: (value) => validateIsEmpty(string: value!),
                onChanged: (value){
                  setState(() {});
                },
              ),
              SizedBox(height: 8.h),
              CustomTextFormField(
                headingText: "Phone Number",
                headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                controller: phoneNoCon,
                maxLines: 1,
                hintText: '9801234567',
                hintStyle: TextStyle(fontSize: 16.sp, color: disableButton, fontWeight: .normal),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (value) => validateMinMaxLength(string: value!, minLegth: 10, maxLength: 11),
                onChanged: (value){
                  setState(() {});
                },
              ),
              SizedBox(height: 8.h),
              CustomTextFormField(
                headingText: "Email Address",
                headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                controller: emailCon,
                maxLines: 1,
                hintText: 'futsal_pro@example.com',
                hintStyle: TextStyle(fontSize: 16.sp, color: disableButton, fontWeight: .normal),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(35),
                ],
                validator: (value) => validateEmail(string: value!),
                onChanged: (value){
                  setState(() {});
                },
              ),
              SizedBox(height: 8.h),
              CustomTextFormField(
                headingText: "Password",
                headingTextStyle: TextStyle(fontSize: 16.sp, color: subtitleTextColor, fontWeight: FontWeight.normal),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                obscureText: true,
                controller: passwordCon,
                maxLines: 1,
                hintText: '••••••••',
                hintStyle: TextStyle(fontSize: 16.sp, color: disableButton, fontWeight: .normal),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                ],
                validator: (value) => validateMinMaxLength(string: value!, minLegth: 8, maxLength: 20),
                onChanged: (value){
                  setState(() {});
                },
              ),
              SizedBox(height: 24.h),
              UsualButton(
                text: 'Create Account',
                fontSize: 16.sp,
                fontWeight: .bold,
                onPressed: () async {
                  final isValid = formKey.currentState!.validate();
                  if (!isValid) return;
                  var data = {
                    "full_name": fullNameCon.text.trim(),
                    "phone_number": phoneNoCon.text.trim(),
                    "email": emailCon.text.trim(),
                    "password": passwordCon.text.trim(),
                    "role": selectedRole,
                  };
                  bool isSignedUp = await authCon.signUp(data);
                  if(isSignedUp) Get.offAll(() => LogInPage());
                },
                height: 56.h,
              ),
              SizedBox(height: 24.h),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  // 1. This base style is inherited by all sub-spans unless they override it
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    height: 1.5, // Improves line-height spacing
                  ),
                  children: [
                    const TextSpan(text: 'By registering, you agree to our '),
                    
                    // 2. A bold, colored segment
                    const TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: primaryTextColor, 
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline
                      ),
                    ),
                    
                    const TextSpan(text: ' and '),
                    
                    // 3. An interactive, clickable link segment
                    TextSpan(
                      text: 'Privacy Policy.',
                      style: const TextStyle(
                        color: primaryTextColor, // Neon Green
                        decoration: TextDecoration.underline, // Underlines the link
                        fontWeight: FontWeight.bold,
                      ),
                      // Recognizer captures tap gestures specifically on these words
                      // recognizer: TapGestureRecognizer()
                      //   ..onTap = () {
                      //     print('Privacy Policy Tapped!');
                      //     // Handle your navigation or URL launcher here
                      //   },
                    ),
                  ]
                )
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

}