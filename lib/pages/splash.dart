import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/pages/home.dart';

import '../widgets/splashScreen/shake.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const pageRoute = "/splash";

  @override
  Widget build(BuildContext context) {
    //return const Home();

    return AnimatedSplashScreen(
      splash: Scaffold(
          backgroundColor: Theme.of(context).primaryColor, body: GravityPlane())
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
      duration: 3000,
      splashIconSize: 1000,
    );
  }
}
