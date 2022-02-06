import 'package:ISCTE_50_Anos/nav_drawer/page_routes.dart';
import 'package:ISCTE_50_Anos/pages/home.dart';
import 'package:ISCTE_50_Anos/pages/pages.dart';
import 'package:ISCTE_50_Anos/pages/qr_scan_page.dart';
import 'package:ISCTE_50_Anos/pages/timeline_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const int PUZZLE_PAGE_INDEX = 0;
const int QR_PAGE_INDEX = 1;
const int TIMELINE_PAGE_INDEX = 2;
const int VISITED_PAGE_INDEX = 3;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: PageRoutes.home,
      routes: {
        PageRoutes.home: (context) => Home(),
        PageRoutes.timeline: (context) => TimelinePage(),
        PageRoutes.visited: (context) => const VisitedPagesPage(),
        PageRoutes.qrscan: (context) => QRScanPage(),
      },
    );
  }
}
