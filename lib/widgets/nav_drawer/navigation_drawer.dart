import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_page.dart';
import 'package:iscte_spots/pages/timeline_page.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:iscte_spots/widgets/splashScreen/shake.dart';

import '../../pages/flickr/flickr_page.dart';
import '../../pages/quiz/quiz_page.dart';
import '../../pages/scanned_list_page.dart';

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> menuWidgetList = [
      const DrawerHeader(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("Resources/Img/Logo/logo_50_anos_main.jpg"),
              fit: BoxFit.cover),
        ),
        child: null,
      ),
      ListTile(
        leading: const Icon(Icons.timeline),
        title: Text(AppLocalizations.of(context)!.timelineScreen),
        onTap: () {
          animateToPage(context, page: TimelinePage());
        },
      ),
      ListTile(
        leading: const Icon(Icons.web_sharp),
        title: Text(AppLocalizations.of(context)!.visitedPagesScreen),
        onTap: () {
          animateToPage(context, page: const VisitedPagesPage());
        },
      ),
      ListTile(
        leading: const Icon(Icons.help),
        title: Text(AppLocalizations.of(context)!.quizScreen),
        onTap: () {
          animateToPage(context, page: QuizPage());
        },
      ),
      ListTile(
        leading: const Icon(Icons.touch_app_outlined),
        title: Text(AppLocalizations.of(context)!.shakerScreen),
        onTap: () {
          animateToPage(context, page: Shaker());
        },
      ),
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.flickr),
        title: Text(AppLocalizations.of(context)!.flickrScreen),
        onTap: () {
          animateToPage(context, page: FlickrPage());
        },
      ),
      ListTile(
        leading: const Icon(Icons.score),
        title: Text(AppLocalizations.of(context)!.leaderBoardScreen),
        onTap: () {
          animateToPage(context, page: LeaderBoardPage());
        },
      ),
      const Spacer(),
      ListTile(
        leading: const Icon(Icons.settings),
        title: Text(AppLocalizations.of(context)!.settingsScreen),
      ),
      ListTile(
        leading: Icon(Icons.adaptive.arrow_back_outlined),
        title: Text(AppLocalizations.of(context)!.logOutButton),
      ),
    ];

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: menuWidgetList,
      ),
    );
  }

  Future<void> animateToPage(BuildContext context,
      {required Widget page}) async {
    Future<Widget> buildPageAsync({required Widget page}) async {
      return Future.microtask(
        () {
          return page;
        },
      );
    }

    Widget futurePage = await buildPageAsync(page: page);
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRoutes.createRoute(
        widget: futurePage,
      ),
    );
  }
}
