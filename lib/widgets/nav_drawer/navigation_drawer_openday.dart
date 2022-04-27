import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/pages/auth/login/login_openday_page.dart';
import 'package:iscte_spots/pages/auth/register/register_page.dart';
import 'package:iscte_spots/pages/flickr/flickr_page.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/pages/timeline_page.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:iscte_spots/widgets/splashScreen/shake.dart';

class NavigationDrawerOpenDay extends StatelessWidget {
  const NavigationDrawerOpenDay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> menuWidgetList = [
      ListTile(
        leading: const Icon(Icons.timeline),
        title: Text(AppLocalizations.of(context)!.timelineScreen),
        onTap: () {
          PageRoutes.animateToPage(context, page: TimelinePage());
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
      ),
      ListTile(
        leading: const Icon(Icons.score),
        title: Text(AppLocalizations.of(context)!.leaderBoardScreen),
        onTap: () {
          PageRoutes.animateToPage(context, page: const LeaderBoardPage());
        },
      ),
      ExpansionTile(
        title: const Text("Account"),
        children: [
          ListTile(
            leading: const Icon(Icons.login),
            title: Text(AppLocalizations.of(context)!.registerScreen),
            onTap: () {
              PageRoutes.animateToPage(context, page: RegisterPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: Text(AppLocalizations.of(context)!.loginScreen),
            onTap: () {
              PageRoutes.animateToPage(context, page: LoginOpendayPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(AppLocalizations.of(context)!.settingsScreen),
          ),
          ListTile(
            leading: Icon(Icons.adaptive.arrow_back_outlined),
            title: Text(AppLocalizations.of(context)!.logOutButton),
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
