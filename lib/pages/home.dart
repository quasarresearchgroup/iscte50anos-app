import 'package:iscteSpots/pages/puzzle_page.dart';
import 'package:iscteSpots/widgets/my_bottom_bar.dart';
import 'package:iscteSpots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  static const pageRoute = "/";

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: Scaffold(
          drawer: const NavigationDrawer(),
          appBar: AppBar(
            title: Title(
                color: Colors.black,
                child: Text(AppLocalizations.of(context)!.appName)),
          ),
          body: PuzzlePage(),
          bottomNavigationBar: const MyBottomBar(selectedIndex: 0),
        ));
  }
}
