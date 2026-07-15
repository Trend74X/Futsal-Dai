import 'package:flutter/material.dart';

const primaryColor       = Color(0xFF39FF14);
const primaryTextColor   = Color(0xFF79FF5B);
const subtitleTextColor  = Color(0xFFBACCB0);
const whiteTextColor     = Color(0xFFDAE6D0);
const buttonTextColor    = Color(0xFF022100);
const brownTextColor     = Color(0xFFFFB95F);
const filledBgColor      = Color(0xFF141E11);
const lightFilledBgColor = Color(0xFF222D1E);
const containerBgColor   = Color(0xFF0E171D);
const error              = Color(0xFFE00000);
const red                = Color(0xFFE00000);
const redCompulsory      = Color(0xFFC13939);
const errorBg            = Color(0xFFFFECEC);
const white              = Color(0xFFFFFFFF);
const black              = Color(0xFF2C2C2C);
const black1             = Color(0xFF171717);
const black2             = Color(0xFF575757);
const black3             = Color(0xFF595959);
const black4             = Color(0xFF3D3D3D);
const black5             = Color(0xFF565656);
const black6             = Color(0xFF676767);
const black7             = Color(0xFF3A3A3A);
const black8             = Color(0xFF333333);
const gray01             = Color(0xFF4B4B4B);
const darkGrey           = Color(0xff2E2D2D);
const gray02             = Color(0xFF838383);
const gray03             = Color(0xFFB6B6B6);
const gray04             = Color(0xFFD3D3D3);
const gray05             = Color(0xFFEEEEEE);
const gray06             = Color(0xFFF8F8F8);
const grey07             = Color(0xFFD9D9D9);
const grey09             = Color(0xFF939393);
const grey10             = Color(0xFFF1F1F1);
const grey11             = Color(0xFFA7A7A7);
const grey12             = Color(0xFF5B5B5B);
const pinkDark           = Color(0xFFE76F7E);
const pinkLight          = Color(0xFFF1B9B9);
const blueDark           = Color(0xFF509DD6);
const blueLight          = Color(0xFFABD2FF);
const waterBlue          = Color(0xFFEEFEFF);
const puepleDark         = Color(0xFF9789ED);
const puepleLight        = Color(0xFFCCC0FD);
const grayDark           = Color(0xFF727272);
const grayLight          = Color(0xFFBFBFBF);
const beigeDark          = Color(0xFFA9958A);
const beigeLight         = Color(0xFFDACCBC);
const toggleGreen        = Color(0xFF3cac35);
const toggleBlue         = Color(0xFF3735ac);
const textBlue           = Color(0xFF1358ce);
const lightGreen         = Color(0xFFD5F1E1);
const disabledSwitch     = Color(0xffABABAB);
const searchText         = Color(0xffB1B1B1);
const disableButton      = Color(0xFFB7B7B7);
const transparent        = Colors.transparent;

TextStyle notoReg({required double size, Color? color = const Color(0x00707070),double? charSpacing = 0.0,double? lineSpacing = 0.0}) => 
  TextStyle(
    fontFamily   : 'Inter-Regular',
    fontSize     : size,
    color        : color,
    letterSpacing: charSpacing,       // character spacing
    height       : lineSpacing        // line spacing
  );

TextStyle notoMed({required double size,Color? color = const Color(0x00707070),double? charSpacing = 0.0,double? lineSpacing = 0.0}) => 
  TextStyle(
    fontFamily   : 'Inter-Medium',
    fontSize     : size,
    color        : color,
    letterSpacing: charSpacing,      // character spacing
    height       : lineSpacing       // line spacing
  );


BoxDecoration bgImg() {
  return const BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/bg_img.png'),
      fit: BoxFit.cover,
    ),
  );
}