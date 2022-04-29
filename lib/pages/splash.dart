import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/auth/auth_page.dart';
import 'package:iscte_spots/pages/home/openday_home.dart';
import 'package:iscte_spots/pages/onboarding/onboarding_page.dart';
import 'package:iscte_spots/services/auth/openday_login_service.dart';
import 'package:iscte_spots/services/onboard_service.dart';
import 'package:iscte_spots/widgets/splashScreen/shake.dart';
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
    bool _isLoggedIn = await OpenDayLoginService.isLoggedIn();
    bool _isOnboarded = await OnboadingService.shouldOnboard();

    return _isLoggedIn
        ? HomeOpenDay()
        : _isOnboarded
            ? const AuthPage()
            : OnboardingPage();
  }

  @override
  Widget build(BuildContext context) {
    //return const Home();

    return AnimatedSplashScreen.withScreenFunction(
      splash: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          child: GravityPlane(
              image: Image.asset('Resources/Img/Campus/campus-iscte-3.jpg')),
        ),
      ),
      duration: 5000,
      splashIconSize: 1000,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      screenFunction: initFunc,
    );
  }
}
