import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:iscte_spots/pages/flickr_test_page.dart';
import 'package:iscte_spots/pages/home.dart';
import 'package:iscte_spots/pages/qr_scan_page.dart';
import 'package:iscte_spots/pages/quiz/quiz_page.dart';
import 'package:iscte_spots/pages/scanned_list_page.dart';
import 'package:iscte_spots/pages/splash.dart';
import 'package:iscte_spots/pages/timeline_page.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:iscte_spots/widgets/splashScreen/shake.dart';

const int puzzlePageIndex = 0;
const int qrPageIndex = 1;
const int timelinePageIndex = 2;
const int visitedPageIndex = 3;

void main() {
  //testGsheets();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
      routes: {
        PageRoutes.home: (context) => const Home(),
        PageRoutes.timeline: (context) => TimelinePage(),
        PageRoutes.visited: (context) => const VisitedPagesPage(),
        PageRoutes.qrscan: (context) => QRScanPage(),
        PageRoutes.quiz: (context) => QuizPage(),
        PageRoutes.shake: (context) => Shaker(),
        PageRoutes.flickr: (context) => FlickrTest(),
      },
    );
  }
}
