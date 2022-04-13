import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:iscte_spots/pages/flickr/flickr_page.dart';
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

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: "Resources/keys.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AppBarTheme appBarTheme = const AppBarTheme(
      //backgroundColor: Color.fromRGBO(14, 41, 194, 1),
      elevation: 0, // This removes the shadow from all App Bars.
      centerTitle: true,
      toolbarHeight: 55,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    );

    var darkTheme = ThemeData.dark();

    const primaryColor2 = Color.fromRGBO(14, 41, 194, 1);
    return MaterialApp(
      title: '',
      theme: ThemeData.light().copyWith(
        primaryColor: primaryColor2,
        errorColor: Colors.deepOrangeAccent,
        appBarTheme: appBarTheme.copyWith(
          backgroundColor: primaryColor2,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: primaryColor2,
            statusBarIconBrightness:
                Brightness.light, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
          primaryColor: primaryColor2,
          errorColor: Colors.deepOrangeAccent,
          appBarTheme: appBarTheme.copyWith(
            backgroundColor: primaryColor2,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: darkTheme.bottomAppBarColor,
              statusBarIconBrightness:
                  Brightness.light, // For Android (dark icons)
              statusBarBrightness: Brightness.light, // For iOS (dark icons)
            ),
          )),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
      routes: {
        PageRoutes.home: (context) => Home(),
        PageRoutes.timeline: (context) => TimelinePage(),
        PageRoutes.visited: (context) => const VisitedPagesPage(),
        PageRoutes.qrscan: (context) => QRScanPage(),
        PageRoutes.quiz: (context) => QuizPage(),
        PageRoutes.shake: (context) => Shaker(),
        PageRoutes.flickr: (context) => FlickrPage(),
      },
    );
  }
}
