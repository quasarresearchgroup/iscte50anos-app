import 'package:ISCTE_50_Anos/widgets/nav_drawer/page_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      ListTile(
        leading: const Icon(Icons.timeline),
        title: Text(AppLocalizations.of(context)!.timelineScreen),
        onTap: () {
          Navigator.pushReplacementNamed(context, PageRoutes.timeline);

          //Navigator.pushNamed(context, '/timeline');
          //updateIndex(PUZZLE_PAGE_INDEX);
          //Navigator.pop(context);
        },
        //onTap: () => updateIndex(2),
      ),
      ListTile(
        leading: const Icon(Icons.web_sharp),
        title: Text(AppLocalizations.of(context)!.visitedPagesScreen),
        onTap: () {
          Navigator.pushReplacementNamed(context, PageRoutes.visited);
          //Navigator.pushNamed(context, '/pages');
          //Navigator.pop(context);
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
