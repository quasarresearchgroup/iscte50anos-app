import 'package:IscteSpots/pages/home.dart';
import 'package:IscteSpots/pages/qr_scan_page.dart';
import 'package:IscteSpots/pages/scanned_list_page.dart';
import 'package:IscteSpots/pages/timeline_page.dart';
import 'package:IscteSpots/widgets/nav_drawer/page_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const int puzzlePageIndex = 0;
const int qrPageIndex = 1;
const int timelinePageIndex = 2;
const int visitedPageIndex = 3;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: PageRoutes.home,
      routes: {
        PageRoutes.home: (context) => const Home(),
        PageRoutes.timeline: (context) => TimelinePage(),
        PageRoutes.visited: (context) => const VisitedPagesPage(),
        PageRoutes.qrscan: (context) => QRScanPage(),
      },
    );
  }
}
