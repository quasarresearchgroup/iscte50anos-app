import 'dart:io';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/auth/auth_page.dart';
import 'package:iscte_spots/pages/home/home_page.dart';
import 'package:iscte_spots/pages/home/splashScreen/shake.dart';
import 'package:iscte_spots/pages/onboarding/onboarding_page.dart';
import 'package:iscte_spots/services/auth/login_service.dart';
import 'package:iscte_spots/services/onboard_service.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<Widget> initFunc() async {
    bool isLoggedIn;
    bool isOnboarded;
    try {
      isLoggedIn = await LoginService.isLoggedIn();
      isOnboarded = await OnboadingService.isOnboarded();
    } on SocketException {
      isLoggedIn = false;
      isOnboarded = false;
    }

    return isLoggedIn
        ? HomePage()
        : isOnboarded
            ? const AuthPage()
            : OnboardingPage(
                onLaunch: true,
              );
  }

  @override
  Widget build(BuildContext context) {
    //return HomePage();

    return AnimatedSplashScreen.withScreenFunction(
      backgroundColor: IscteTheme.iscteColor,
      splash: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          child: GravityPlane(
              //image: Image.asset('Resources/Img/Campus/campus-iscte-3.jpg')),
              image: Image.asset(
                  'Resources/Img/Logo/logo_50anos_iscte_cores_rgb.png')),
        ),
      ),
      centered: true,
      duration: 0,
      splashIconSize: 1000,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      screenFunction: initFunc,
    );
  }
}
