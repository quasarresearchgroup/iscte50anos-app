import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/pages/auth/auth_page.dart';
import 'package:iscte_spots/pages/flickr/flickr_page.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/pages/profile/profile_screen.dart';
import 'package:iscte_spots/pages/quiz/quiz_page.dart';
import 'package:iscte_spots/pages/scanned_list_page.dart';
import 'package:iscte_spots/pages/timeline_page.dart';
import 'package:iscte_spots/services/auth/openday_login_service.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:iscte_spots/widgets/splashScreen/shake.dart';

import '../../pages/quiz/quiz_list_menu.dart';

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> menuWidgetList = [
      /*ListTile(
        leading: const Icon(Icons.timeline),
        title: Text(AppLocalizations.of(context)!.timelineScreen),
        onTap: () {
          PageRoutes.animateToPage(context, page: TimelinePage());
        },
      ),
      ListTile(
        leading: const Icon(Icons.web_sharp),
        title: Text(AppLocalizations.of(context)!.visitedPagesScreen),
        onTap: () {
          PageRoutes.animateToPage(context, page: const VisitedPagesPage());
        },
      ),
      ListTile(
        leading: const Icon(Icons.touch_app_outlined),
        title: Text(AppLocalizations.of(context)!.shakerScreen),
        onTap: () {
          PageRoutes.animateToPage(context, page: Shaker());
        },
      ),
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.flickr),
        title: Text(AppLocalizations.of(context)!.flickrScreen),
        onTap: () {
          PageRoutes.animateToPage(context, page: FlickrPage());
        },
      ),*/
      ListTile(
        leading: const Icon(Icons.help),
        title: Text(AppLocalizations.of(context)!.quizScreen),
        onTap: () {
          PageRoutes.animateToPage(context, page: const QuizMenu());
        },
      ),
      ListTile(
        leading: const Icon(Icons.score),
        title: Text(AppLocalizations.of(context)!.leaderBoardScreen),
        onTap: () {
          PageRoutes.animateToPage(context, page: const LeaderBoardPage());
        },
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: Text(AppLocalizations.of(context)!.profileScreen),
        onTap: () {
          PageRoutes.animateToPage(context, page: ProfilePage());
        },
      ),
      ExpansionTile(
        title: const Text("Account"),
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(AppLocalizations.of(context)!.settingsScreen),
          ),
          ListTile(
            leading: Icon(Icons.adaptive.arrow_back_outlined),
            title: Text(AppLocalizations.of(context)!.logOutButton),
            onTap: () async {
              Navigator.of(context).pop();
              await OpenDayLoginService.logOut(context);
              PageRoutes.animateToPage(context, page: AuthPage());
            },
          ),
        ],
      ),
    ];

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("Resources/Img/Logo/logo_50_anos_main.jpg"),
                  fit: BoxFit.cover),
            ),
            child: null,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: menuWidgetList),
            ),
          ),
        ],
      ),
    );
  }
}
