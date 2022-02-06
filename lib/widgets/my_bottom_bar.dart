import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyBottomBar extends StatefulWidget {
  late Function(int) updateIndex;

  MyBottomBar({
    Key? key,
    /*required this.updateIndex*/
  }) : super(key: key);

  @override
  _MyBottomBarState createState() => _MyBottomBarState();
}

class _MyBottomBarState extends State<MyBottomBar> {
  //int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      //currentIndex: _currentIndex,
      //onTap: widget.updateIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue[700],
      selectedFontSize: 13,
      unselectedFontSize: 13,
      iconSize: 30,
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.mainMenu),
        BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: AppLocalizations.of(context)!.scanCodeButton),
      ],
    );
  }
}
