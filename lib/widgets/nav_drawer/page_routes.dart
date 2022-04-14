import 'package:iscte_spots/pages/onboarding/onboarding_page.dart';
import 'package:iscte_spots/pages/puzzle_page.dart';
import 'package:iscte_spots/pages/qr_scan_page.dart';
import 'package:iscte_spots/pages/quiz/quiz_page.dart';
import 'package:iscte_spots/pages/scanned_list_page.dart';
import 'package:iscte_spots/pages/splash.dart';
import 'package:iscte_spots/pages/timeline_page.dart';
import 'package:iscte_spots/widgets/splashScreen/shake.dart';

import '../../pages/flickr/flickr_page.dart';

class PageRoutes {
  static const String splash = SplashScreen.pageRoute;
  static const String shake = Shaker.pageRoute;
  static const String home = PuzzlePage.pageRoute;
  static const String timeline = TimelinePage.pageRoute;
  static const String visited = VisitedPagesPage.pageRoute;
  static const String qrscan = QRScanPage.pageRoute;
  static const String quiz = QuizPage.pageRoute;
  static const String flickr = FlickrPage.pageRoute;
  static const String onboard = OnboardingPage.pageRoute;
}
