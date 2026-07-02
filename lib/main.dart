import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/splash.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   systemNavigationBarColor: Colors.transparent,
  //   systemNavigationBarDividerColor: Colors.transparent,
  //   systemNavigationBarIconBrightness: Brightness.light,
  //   statusBarIconBrightness: Brightness.light, 
  //   statusBarBrightness: Brightness.dark
  // ));
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 956),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return GetMaterialApp(
          title: 'Futsal Dai',
          debugShowCheckedModeBanner: false,
          transitionDuration: const Duration(milliseconds: 500),
          defaultTransition: Transition.rightToLeft,
          home: SplashScreenPage(),
          builder: (context, child) {
            return SafeArea(
              top: false,
              bottom: Platform.isIOS ? false : true,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!
              ),
            );
          },
        );
      }
    );
  }
}
