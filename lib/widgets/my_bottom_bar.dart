import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'nav_drawer/page_routes.dart';

class MyBottomBar extends StatefulWidget {
  final int selectedIndex;

  const MyBottomBar({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  _MyBottomBarState createState() => _MyBottomBarState();
}

class _MyBottomBarState extends State<MyBottomBar> {
  @override
  Widget build(BuildContext context) {
    void changePage(int index) {
      if (index != widget.selectedIndex) {
        switch (index) {
          case 0:
            {
              Navigator.pushReplacementNamed(context, PageRoutes.home);
            }
            break;
          case 1:
            {
              Navigator.pushReplacementNamed(context, PageRoutes.qrscan);
            }
            break;
          default:
            {
              Navigator.pushReplacementNamed(context, PageRoutes.home);
            }
        }
      }
    }

    return BottomNavigationBar(
      currentIndex: widget.selectedIndex,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor.withAlpha(0),
      onTap: changePage,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).selectedRowColor,
      unselectedItemColor: Theme.of(context).unselectedWidgetColor,
      selectedFontSize: 13,
      unselectedFontSize: 10,
      iconSize: 30,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: AppLocalizations.of(context)!.mainMenu,
        ),
        BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: AppLocalizations.of(context)!.scanCodeButton),
      ],
    );
  }
}
