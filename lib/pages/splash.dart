import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/home.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const pageRoute = "/splash";

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Expanded(
        child: Column(
          children: [
            Image.asset('Resources/logo_50anos_iscte_branco_rgb.png'),
            const Text(
              'IscteSpots',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      backgroundColor: Colors.blue,
      nextScreen: const Home(),
      splashIconSize: 1,
      duration: 3000,
      pageTransitionType: PageTransitionType.rightToLeftWithFade,
      animationDuration: const Duration(seconds: 1),
    );
  }
}
