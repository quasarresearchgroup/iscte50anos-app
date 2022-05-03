import 'package:flutter/widgets.dart';
import 'package:iscte_spots/models/content.dart';
import 'package:iscte_spots/pages/auth/auth_page.dart';
import 'package:iscte_spots/pages/flickr/flickr_page.dart';
import 'package:iscte_spots/pages/home/home.dart';
import 'package:iscte_spots/pages/home/openday_home.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/pages/onboarding/onboarding_page.dart';
import 'package:iscte_spots/pages/profile/profile_screen.dart';
import 'package:iscte_spots/pages/scanned_list_page.dart';
import 'package:iscte_spots/pages/settings/settings_page.dart';
import 'package:iscte_spots/pages/timeline_page.dart';
import 'package:iscte_spots/widgets/splashScreen/shake.dart';
import 'package:iscte_spots/widgets/timeline/timeline_details_page.dart';

enum PageRoute {
  HOME, //Home.pageRoute
  HOMEOPENDAY, //HomeOpenDay.pageRoute
  AUTH, //AuthPage.pageRoute
  TIMELINE, //TimelinePage.pageRoute
  TIMELINEDETAIL, //TimeLineDetailsPage.pageRoute
  SHAKER, //Shaker.pageRoute
  FLICKR, //FlickrPage.pageRoute
  LEADERBOARD, //LeaderBoardPage.pageRoute
  PROFILE, //ProfilePage.pageRoute
  VISITED, //VisitedPagesPage.pageRoute
  SETTINGS, //SettingsPage.pageRoute
  ONBOARD, //OnboardingPage.pageRoute
}

extension PageRouteExtension on PageRoute {
  static PageRoute factory(String route) {
    switch (route) {
      case Home.pageRoute:
        return PageRoute.HOME;
      case HomeOpenDay.pageRoute:
        return PageRoute.HOMEOPENDAY;
      case AuthPage.pageRoute:
        return PageRoute.AUTH;
      case TimelinePage.pageRoute:
        return PageRoute.TIMELINE;
      case TimeLineDetailsPage.pageRoute:
        return PageRoute.TIMELINEDETAIL;
      case Shaker.pageRoute:
        return PageRoute.SHAKER;
      case FlickrPage.pageRoute:
        return PageRoute.FLICKR;
      case LeaderBoardPage.pageRoute:
        return PageRoute.LEADERBOARD;
      case ProfilePage.pageRoute:
        return PageRoute.PROFILE;
      case VisitedPagesPage.pageRoute:
        return PageRoute.VISITED;
      case SettingsPage.pageRoute:
        return PageRoute.SETTINGS;
      case OnboardingPage.pageRoute:
        return PageRoute.ONBOARD;
      default:
        return PageRoute.HOMEOPENDAY;
    }
  }

  Widget widget(Object? argument) {
    switch (this) {
      case PageRoute.HOME:
        return Home();
      case PageRoute.HOMEOPENDAY:
        return HomeOpenDay();
      case PageRoute.AUTH:
        return AuthPage();
      case PageRoute.TIMELINE:
        return TimelinePage();
      case PageRoute.SHAKER:
        return Shaker();
      case PageRoute.LEADERBOARD:
        return LeaderBoardPage();
      case PageRoute.PROFILE:
        return ProfilePage();
      case PageRoute.VISITED:
        return VisitedPagesPage();
      case PageRoute.FLICKR:
        return FlickrPage();
      case PageRoute.TIMELINEDETAIL:
        return TimeLineDetailsPage(data: argument as Content);
      case PageRoute.SETTINGS:
        return SettingsPage();
      case PageRoute.ONBOARD:
        return OnboardingPage();
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
