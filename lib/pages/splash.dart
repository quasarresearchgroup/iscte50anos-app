import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/auth/auth_page.dart';
import 'package:iscte_spots/pages/home/openday_home.dart';
import 'package:iscte_spots/services/auth/openday_login_service.dart';
import 'package:iscte_spots/widgets/splashScreen/shake.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const pageRoute = "/splash";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    initFunc();
  }

  Future<void> initFunc() async {
    bool _loggedIn = await OpenDayLoginService.isLoggedIn();
    setState(() {
      _isLoggedIn = _loggedIn;
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    //return const Home();

    return AnimatedSplashScreen(
      splash: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          child: GravityPlane(
              image: Image.asset('Resources/Img/Campus/campus-iscte-3.jpg')),
        ),
      ),
      nextScreen: _isLoggedIn ? HomeOpenDay() : const AuthPage(),
      function: initFunc,
      duration: 5000,
      splashIconSize: 1000,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}
