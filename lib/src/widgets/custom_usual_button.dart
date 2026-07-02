import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:get/get.dart';

//----------Usual button ----------
// ignore: must_be_immutable
class UsualButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? height;
  final double? width;
  final double? elevation;
  final Color? color;
  final double? borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? fontColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  TextStyle? style;
  final bool? isDisabled;
  final bool? isLoading; 
  final Color? bgColor; 
  final Color borderColor; 
  final Key? buttonKey; 
  final int? maxlines;

  UsualButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height,
    this.width,
    this.elevation,
    this.color,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.fontColor = buttonTextColor,
    this.fontSize = 16,
    this.fontWeight, 
    this.style, 
    this.isDisabled = false,
    this.isLoading = false,
    this.bgColor,
    this.borderColor = Colors.transparent, 
    this.buttonKey,
    this.maxlines = 1
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 54.h,
      width: width ?? Get.width * .85,
      child: ElevatedButton(
        key: buttonKey,
        onPressed: isDisabled == true || isLoading == true ? (){} : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled == true ? gray04 : bgColor ?? primaryColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
          ),
          elevation: isDisabled == true ? 0 : elevation ?? 2,
          // textStyle: TextStyle(
          //   color: fontColor,
          //   // fontSize: read('appFont') == "large" ? fontSize! + 3.5 : fontSize,
          //   fontWeight: fontWeight,
          // ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          animationDuration: const Duration(milliseconds: 200),
          side: BorderSide(
            color: borderColor
          )
        ),
        child: isLoading!
          ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fontColor ?? primaryColor),
            ),
          )
          : Text(
            text,
            style: TextStyle(
              color: fontColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
              fontFamily: "NotoSansJP",
            ),
            textAlign: .center,
            maxLines: maxlines,
            overflow: TextOverflow.ellipsis,
          ),
      ),
    );
  }
}