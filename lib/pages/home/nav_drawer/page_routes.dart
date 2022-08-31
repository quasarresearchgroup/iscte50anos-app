import 'package:flutter/widgets.dart';
import 'package:iscte_spots/models/timeline/content.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/auth/auth_page.dart';
import 'package:iscte_spots/pages/flickr/flickr_page.dart';
import 'package:iscte_spots/pages/home/home_page.dart';
import 'package:iscte_spots/pages/home/scanPage/qr_scan_results.dart';
import 'package:iscte_spots/pages/home/scanPage/scanned_list_page.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/pages/onboarding/onboarding_page.dart';
import 'package:iscte_spots/pages/profile/profile_screen.dart';
import 'package:iscte_spots/pages/quiz/quiz_list_menu.dart';
import 'package:iscte_spots/pages/settings/settings_page.dart';
import 'package:iscte_spots/pages/spotChooser/spot_chooser_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_details_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_filter_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_page.dart';

class PageRouter {
  static Widget resolve(String route, Object? argument) {
    switch (route) {
      //case Home.pageRoute:
      //return Home();
      case HomePage.pageRoute:
        return HomePage();
      case AuthPage.pageRoute:
        return AuthPage();
      case TimelinePage.pageRoute:
        return TimelinePage();
      case TimeLineDetailsPage.pageRoute:
        return TimeLineDetailsPage(event: argument as Event);
      case TimelineFilterPage.pageRoute:
        return TimelineFilterPage();
      //case Shaker.pageRoute:
      //  return Shaker();
      case FlickrPage.pageRoute:
        return FlickrPage();
      case LeaderBoardPage.pageRoute:
        return LeaderBoardPage();
      case QuizMenu.pageRoute:
        return QuizMenu();
      case ProfilePage.pageRoute:
        return ProfilePage();
      case VisitedPagesPage.pageRoute:
        return VisitedPagesPage();
      case SettingsPage.pageRoute:
        return SettingsPage();
      case OnboardingPage.pageRoute:
        return OnboardingPage(
          onLaunch: false,
        );
      case QRScanResults.pageRoute:
        return QRScanResults(data: argument as List<Content>);
      case SpotChooserPage.pageRoute:
        return SpotChooserPage();
      default:
        return HomePage();
    }
  }
}

/*
class PageRoutes {
  static Route createRoute({
    required Widget widget,
    Duration transitionDuration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder(
      transitionDuration: transitionDuration,
      maintainState: true,
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.ease));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Future<Widget> _buildPageAsync({required Widget page}) async {
    return Future.microtask(
      () {
        return page;
      },
    );
  }

  static Future<void> animateToPage(BuildContext context,
      {required Widget page}) async {
    Widget futurePage = await _buildPageAsync(page: page);
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRoutes.createRoute(
        widget: futurePage,
      ),
    );
  }

  static Future<void> replacePushanimateToPage(BuildContext context,
      {required Widget page}) async {
    Widget futurePage = await _buildPageAsync(page: page);
    Navigator.pushReplacement(
      context,
      PageRoutes.createRoute(
        widget: futurePage,
      ),
    );
  }
}
*/
