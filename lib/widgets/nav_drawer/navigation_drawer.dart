import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';

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
      /*ListTile(
        leading: const Icon(Icons.home),
        title: Text(AppLocalizations.of(context)!.mainMenu),
        onTap: () {
          Navigator.pushReplacementNamed(context, PageRoutes.home);
        },
      ),
      ListTile(
        leading: const Icon(Icons.qr_code),
        title: Text(AppLocalizations.of(context)!.scanCodeButton),
        onTap: () {
          Navigator.pushReplacementNamed(context, PageRoutes.qrscan);
        },
      ),
      */
      ListTile(
        leading: const Icon(Icons.timeline),
        title: Text(AppLocalizations.of(context)!.timelineScreen),
        onTap: () {
          Navigator.pushNamed(context, PageRoutes.timeline);
        },
      ),
      ListTile(
        leading: const Icon(Icons.web_sharp),
        title: Text(AppLocalizations.of(context)!.visitedPagesScreen),
        onTap: () {
          Navigator.pushNamed(context, PageRoutes.visited);
        },
      ),
      ListTile(
        leading: const Icon(Icons.help),
        title: Text(AppLocalizations.of(context)!.quizScreen),
        onTap: () {
          Navigator.pushNamed(context, PageRoutes.quiz);
        },
      ),
      ListTile(
        leading: const Icon(Icons.touch_app_outlined),
        title: const Text('Shaker'),
        onTap: () {
          Navigator.pushNamed(context, PageRoutes.shake);
        },
      ),
      ListTile(
        leading: const FaIcon(FontAwesomeIcons.flickr),
        title: Text("Flickr"),
        onTap: () {
          Navigator.pushNamed(context, PageRoutes.flickr);
        },
      ),
      ListTile(
        leading: const Icon(Icons.score),
        title: Text(AppLocalizations.of(context)!.pointsScreen),
        onTap: () {},
      ),
    ];

    return Drawer(
      child: ListView(
        children: menuWidgetList,
      ),
    );
  }
}
