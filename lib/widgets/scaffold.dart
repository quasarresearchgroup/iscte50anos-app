/*import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyScaffold extends StatelessWidget {
  MyScaffold({Key? key, required this.appTitle}) : super(key: key);

  final String appTitle;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
      ),
      body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: updateIndex,
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
      ),
    );
  }
}
*/
