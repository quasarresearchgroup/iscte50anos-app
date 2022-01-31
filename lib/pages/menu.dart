import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyMenu extends StatelessWidget {
  MyMenu({Key? key, required this.updateIndex, required this.changeScreen})
      : super(key: key);
  Function(int) updateIndex;
  Function(Widget, Scaffold) changeScreen;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          ListTile(
            autofocus: true,
            leading: const Icon(Icons.home),
            title: Text(AppLocalizations.of(context)!.mainMenu),
            onTap: () => updateIndex(0),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: Text(AppLocalizations.of(context)!.scanCodeButton),
            onTap: () => updateIndex(1),
          ),
          ListTile(
            leading: const Icon(Icons.timeline),
            title: Text(AppLocalizations.of(context)!.timelineScreen),
            onTap: () => Navigator.pushNamed(context, '/timeline'),
            //onTap: () => updateIndex(2),
          ),
          ListTile(
            leading: const Icon(Icons.web_sharp),
            title: Text(AppLocalizations.of(context)!.visitedPagesScreen),
            onTap: () => Navigator.pushNamed(context, '/pages'),
          ),
          ListTile(
            leading: const Icon(Icons.assignment_turned_in),
            title: Text(AppLocalizations.of(context)!.puzzleScreen),
            onTap: () => Navigator.pushNamed(context, '/puzzle'),
          ),
          ListTile(
            leading: const Icon(Icons.score),
            title: Text(AppLocalizations.of(context)!.pointsScreen),
            onTap: () => updateIndex(1),
          ),
        ],
      ),
    );
  }
}
