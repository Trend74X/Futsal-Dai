import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:get/get.dart';

class CustomTextFormField extends StatelessWidget {
  final String headingText;
  final TextStyle? headingTextStyle;
  final String? infoText;
  final String? impText;
  final String? initialValue;
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool? isRequired ;
  final bool? isOptional ;
  final bool? isDropdown;
  final bool? isSuffixLoading;
  final bool readOnly;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final OutlineInputBorder? errorBorder;
  final InputBorder? disabledBorder;
  final Color? cursorColor;
  final Color? filledColor;
  final bool? filled;
  final int? maxLines;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final ValueChanged<String>? onFieldSubmitted;
  final AutovalidateMode? autoValidateMode;
  final bool? isDisabled;
  final FocusNode? focusNode;
  final bool? autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? infoTextStyle;
  final int? maxLength;
  final String? reqText; 

  const CustomTextFormField({
    super.key,
    this.initialValue,
    this.controller,
    this.labelText,
    this.hintText,
    this.labelStyle,
    this.hintStyle,
    this.textStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.textInputAction = TextInputAction.done,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.disabledBorder,
    this.cursorColor,
    this.maxLines,
    this.width,
    this.height, 
    this.filledColor, 
    this.filled, 
    this.autofocus = false, 
    this.readOnly = false, 
    this.onTap, 
    this.autoValidateMode, 
    this.isDisabled, 
    this.inputFormatters, 
    this.onFieldSubmitted,
    this.focusNode,
    required this.headingText, 
    this.isRequired, 
    this.isDropdown, this.isOptional, this.infoText, this.infoTextStyle, this.maxLength, this.isSuffixLoading, this.reqText, this.impText, this.headingTextStyle
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading Text and Required
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                headingText, 
                style: headingTextStyle ?? notoReg(size: 15.sp, color: black),
                maxLines: 3,
                // softWrap: false,
              )
            ),
            SizedBox(width: 8.w,),
            //Reauired Indicator
            Visibility(
              visible: isRequired == true,
              child: Container(
                height: 20.h,
                padding: EdgeInsets.fromLTRB(5.0.w, 0.0.h, 5.0.w, 1.6.h),
                margin: EdgeInsets.only(top: 1.0.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: redCompulsory
                ),
                child: Center(
                  child: Text(
                    reqText ?? "requiredTag".tr, 
                    style: notoReg(size: 11.sp, color: white),
                    textAlign: TextAlign.center,
                  ),
                )
              ),
            ),
            // Optional Indicator
            Visibility(
              visible: isOptional == true,
              child: Container(
                height: 20.h,
                padding: EdgeInsets.fromLTRB(5.0.w, 0.0.h, 5.0.w, 1.6.h),
                margin: EdgeInsets.only(top: 3.0.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: black2
                ),
                child: Center(
                  child: Text(
                    "任意",
                    style: notoReg(size: 12.sp, color: white),
                    textAlign: TextAlign.center,
                  ),
                )
              ),
            ),
            SizedBox(width: 4.w,),
            Visibility(
              visible: infoText != null,
              child: Text(infoText?? "", style: infoTextStyle ?? notoReg(size: 11.sp, color: black2))
            ),
          ],
        ),
        SizedBox(height: 6.0.h,),
        Visibility(
          visible: impText  != null,
          child: Padding(
            padding:  EdgeInsets.only(bottom: 6.0.sp),
            child: Text(impText ?? "", style: infoTextStyle ?? notoMed(size: 12.sp, color: redCompulsory)),
          )
        ),
        // TextField
        SizedBox(
          width: width,
          height: height,
          child: TextFormField(
            style: textStyle ?? TextStyle(fontSize: 16.sp, color: white, fontFamily: 'NotoSansJP-Regular',height: 1.5.sp),
            focusNode: focusNode,
            inputFormatters: inputFormatters ?? [],
            onTap: isSuffixLoading == true ? (){} : onTap,
            autofocus: autofocus!,
            autovalidateMode: autoValidateMode ?? AutovalidateMode.onUserInteraction,
            initialValue: initialValue,
            controller: controller,
            obscureText: obscureText,
            readOnly: isDropdown == true ? true : readOnly,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            cursorColor: cursorColor ?? primaryColor,
            maxLines: maxLines ?? 1,
            maxLength: maxLength,
            decoration: InputDecoration(
              errorMaxLines: 3,
              labelText: labelText,
              hintText: hintText,
              labelStyle: labelStyle,
              hintStyle: hintStyle ?? notoReg(size: 16.sp, color: const Color(0xff949494)),
              prefixIcon: prefixIcon,
              suffixIcon: isSuffixLoading == true 
                ? Container(
                    height: 48.h,
                    width: 48.h,
                    padding: EdgeInsets.all(14.sp),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xff949494),
                        strokeWidth: 1.8.sp,
                      ),
                    ),
                  )
                : isDropdown == true 
                  ?  const Icon(Icons.arrow_drop_down, color: Color(0xff575757),)
                  : suffixIcon,
              border: border ??  OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0.r),
                borderSide: BorderSide(
                  color: black2,
                  width: 1.sp
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0.r),
                borderSide: BorderSide(
                  color: black2,
                  width: 1.sp
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0.r),
                borderSide: BorderSide(
                  color: black2,
                  width: 1.sp
                ),
              ),
              fillColor: filledColor ?? filledBgColor,
              filled: true,
              errorBorder: errorBorder ?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0.r),
                borderSide: BorderSide(
                  color: redCompulsory, 
                  width: 1.sp
                ),
              ),
              focusedErrorBorder: errorBorder ?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0.r),
                borderSide: BorderSide(
                  color: redCompulsory, 
                  width: 1.sp
                ),
              ),
              disabledBorder: disabledBorder,
              contentPadding: EdgeInsets.symmetric(horizontal:12.sp,vertical: 8.0.sp),
              errorStyle: notoReg(size: 11.5.sp, color: redCompulsory),
            ),
          ),
        ),
      ],
    );
  }
}