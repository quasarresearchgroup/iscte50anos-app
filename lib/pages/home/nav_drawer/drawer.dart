import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/pages/flickr/flickr_page.dart';
import 'package:iscte_spots/pages/onboarding/onboarding_page.dart';
import 'package:iscte_spots/pages/profile/profile_screen.dart';
import 'package:iscte_spots/pages/quiz/quiz_list_menu.dart';
import 'package:iscte_spots/pages/settings/settings_page.dart';
import 'package:iscte_spots/pages/spotChooser/spot_chooser_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_page.dart';
import 'package:iscte_spots/services/auth/openday_login_service.dart';

class NavigationDrawerOpenDay extends StatelessWidget {
  const NavigationDrawerOpenDay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> menuWidgetList = [
      ListTile(
        leading: const Icon(Icons.directions_run),
        title: Text(AppLocalizations.of(context)!.spotChooserScreen),
        onTap: () {
//          PageRoutes.animateToPage(context, page: TimelinePage());
          Navigator.of(context).popAndPushNamed(SpotChooserPage.pageRoute);
        },
      ),
      ListTile(
        leading: const Icon(Icons.timeline),
        title: Text(AppLocalizations.of(context)!.timelineScreen),
        onTap: () {
//          PageRoutes.animateToPage(context, page: TimelinePage());
          Navigator.of(context).popAndPushNamed(TimelinePage.pageRoute);
        },
      ),
/*
      ListTile(
        leading: const Icon(Icons.touch_app_outlined),
        title: Text(AppLocalizations.of(context)!.shakerScreen),
        onTap: () {
//          PageRoutes.animateToPage(context, page: Shaker());
          Navigator.of(context).popAndPushNamed(Shaker.pageRoute);
        },
      ),*/
      ListTile(
        leading: const Icon(Icons.help),
        title: Text(AppLocalizations.of(context)!.quizScreen),
        onTap: () {
          //PageRoutes.animateToPage(context, page: QuizPage());
          Navigator.of(context).popAndPushNamed(QuizMenu.pageRoute);
        },
      ),
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.flickr),
        title: Text(AppLocalizations.of(context)!.flickrScreen),
        onTap: () {
//          PageRoutes.animateToPage(context, page: FlickrPage());
          Navigator.of(context).popAndPushNamed(FlickrPage.pageRoute);
        },
      ),
/*      ListTile(
        leading: const Icon(Icons.leaderboard),
        title: Text(AppLocalizations.of(context)!.leaderBoardScreen),
        onTap: () {
          //PageRoutes.animateToPage(context, page: const LeaderBoardPage());
          Navigator.of(context).popAndPushNamed(LeaderBoardPage.pageRoute);
        },
      ),*/
      ExpansionTile(
        title: const Text("Account"),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(AppLocalizations.of(context)!.profileScreen),
            onTap: () async {
              //PageRoutes.animateToPage(context, page: ProfilePage());
              Navigator.of(context).popAndPushNamed(ProfilePage.pageRoute);
            },
          ),
          ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.settingsScreen),
              onTap: () async {
                //PageRoutes.animateToPage(context, page: ProfilePage());
                Navigator.of(context).popAndPushNamed(SettingsPage.pageRoute);
              }),
          ListTile(
            leading: const Icon(Icons.departure_board),
            title: const Text('Onboarding'),
            onTap: () {
              //PageRoutes.animateToPage(context, page: OnboardingPage());

              Navigator.of(context).popAndPushNamed(OnboardingPage.pageRoute);
            },
          ),
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
      key: key,
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
