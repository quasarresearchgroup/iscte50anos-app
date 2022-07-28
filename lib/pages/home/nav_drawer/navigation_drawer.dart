import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/pages/flickr/flickr_page.dart';
import 'package:iscte_spots/pages/home/splashScreen/shake.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/pages/profile/profile_screen.dart';
import 'package:iscte_spots/pages/quiz/quiz_list_menu.dart';
import 'package:iscte_spots/pages/quiz/quiz_page.dart';
import 'package:iscte_spots/pages/scanned_list_page.dart';
import 'package:iscte_spots/pages/settings/settings_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_page.dart';
import 'package:iscte_spots/services/auth/openday_login_service.dart';

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> menuWidgetList = [
      ListTile(
        leading: const Icon(Icons.timeline),
        title: Text(AppLocalizations.of(context)!.timelineScreen),
        onTap: () {
          //PageRoutes.animateToPage(context, page: TimelinePage());
          Navigator.popAndPushNamed(context, TimelinePage.pageRoute);
        },
      ),
      ListTile(
        leading: const Icon(Icons.web_sharp),
        title: Text(AppLocalizations.of(context)!.visitedPagesScreen),
        onTap: () {
          //PageRoutes.animateToPage(context, page: const VisitedPagesPage());
          Navigator.popAndPushNamed(context, VisitedPagesPage.pageRoute);
        },
      ),
      ListTile(
        leading: const Icon(Icons.help),
        title: Text(AppLocalizations.of(context)!.quizScreen),
        onTap: () {
          //PageRoutes.animateToPage(context, page: QuizPage());
          Navigator.popAndPushNamed(context, QuizPage.pageRoute);
        },
      ),
      ListTile(
        leading: const Icon(Icons.touch_app_outlined),
        title: Text(AppLocalizations.of(context)!.shakerScreen),
        onTap: () {
          //PageRoutes.animateToPage(context, page: Shaker());
          Navigator.popAndPushNamed(context, Shaker.pageRoute);
        },
      ),
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.flickr),
        title: Text(AppLocalizations.of(context)!.flickrScreen),
        onTap: () {
          //PageRoutes.animateToPage(context, page: FlickrPage());
          Navigator.popAndPushNamed(context, FlickrPage.pageRoute);
        },
      ),
      ListTile(
        leading: const Icon(Icons.help),
        title: Text(AppLocalizations.of(context)!.quizScreen),
        onTap: () {
          Navigator.popAndPushNamed(context, QuizMenu.pageRoute);
        },
      ),
      ListTile(
        leading: const Icon(Icons.score),
        title: Text(AppLocalizations.of(context)!.leaderBoardScreen),
        onTap: () {
          //PageRoutes.animateToPage(context, page: const LeaderBoardPage());
          Navigator.popAndPushNamed(context, LeaderBoardPage.pageRoute);
        },
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: Text(AppLocalizations.of(context)!.profileScreen),
        onTap: () {
          //PageRoutes.animateToPage(context, page: ProfilePage());
          Navigator.popAndPushNamed(context, ProfilePage.pageRoute);
        },
      ),
      ExpansionTile(
        title: const Text("Account"),
        children: [
          ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.settingsScreen),
              onTap: () async {
                //PageRoutes.animateToPage(context, page: ProfilePage());
                Navigator.of(context).popAndPushNamed(SettingsPage.pageRoute);
              }),
          ListTile(
            leading: Icon(Icons.adaptive.arrow_back_outlined),
            title: Text(AppLocalizations.of(context)!.logOutButton),
            onTap: () async {
              await OpenDayLoginService.logOut(context);
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
