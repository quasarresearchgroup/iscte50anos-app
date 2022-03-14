import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/home.dart';
import 'package:page_transition/page_transition.dart';

import '../widgets/splashScreen/shake.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const pageRoute = "/splash";

  @override
  Widget build(BuildContext context) {
    //return const Home();

    return AnimatedSplashScreen(
      splash: Scaffold(
          body: GravityPlane(
              image: Image.asset('Resources/Img/Campus/campus-iscte-3.jpg')))
      /* Column(
        children: [
          Image.asset('Resources/Img/Logo/logo_50anos_iscte_branco_rgb.png'),
          const Text(
            'IscteSpots',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          )
        ],
      )*/
      ,
      nextScreen: const Home(),
      duration: 5000,
      splashIconSize: 1000,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}
