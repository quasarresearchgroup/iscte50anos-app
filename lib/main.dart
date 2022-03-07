import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
/*
void testGsheets() async {
  const _credentials = r'''
{
  "type": "service_account",
  "project_id": "",
  "private_key_id": "",
  "private_key": "",
  "client_email": "",
  "client_id": "",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": ""
}
''';

  // init GSheets
  final gsheets = GSheets(_credentials);
  // fetch spreadsheet by its id
  //final ss = await gsheets.spreadsheet(_spreadsheetId);
  // get worksheet by its title
  final sheet = await ss.worksheetByTitle('products');
}*/

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
        PageRoutes.shake: (context) => const Shaker(),
      },
    );
  }
}
