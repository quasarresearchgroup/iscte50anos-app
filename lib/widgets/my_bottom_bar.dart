import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class MyBottomBar extends StatefulWidget {
  final TabController tabController;
  final int initialIndex;

  const MyBottomBar(
      {Key? key, required this.initialIndex, required this.tabController})
      : super(key: key);

  @override
  _MyBottomBarState createState() => _MyBottomBarState();
}

class _MyBottomBarState extends State<MyBottomBar> {
  late int selectedIndex;
  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  void changePage(int index) {
    if (index != selectedIndex) {
      setState(() {
        widget.tabController.animateTo(index);
        selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: IscteTheme.appbarRadius,
        topRight: IscteTheme.appbarRadius,
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Theme.of(context).selectedRowColor,
        unselectedItemColor: Theme.of(context).unselectedWidgetColor,
        elevation: 8,
        onTap: changePage,
        enableFeedback: true,
        iconSize: 30,
        selectedFontSize: 13,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.mainMenu,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              backgroundColor: Theme.of(context).primaryColor,
              label: AppLocalizations.of(context)!.scanCodeButton),
        ],
      ),
    );
  }
}
