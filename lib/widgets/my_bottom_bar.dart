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
  @override
  void initState() {
    super.initState();
  }

  void changePage(int index) {
    if (index != widget.tabController.index) {
      setState(() {
        widget.tabController.animateTo(index);
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
      child: BottomAppBar(
          shape:
              const CircularNotchedRectangle(), // ← carves notch for FAB in BottomAppBar
          color: Theme.of(context).primaryColor,
          // ↑ use .withAlpha(0) to debug/peek underneath ↑ BottomAppBar
          elevation: 0, // ← removes slight shadow under FAB, hardly noticeable
          // ↑ default elevation is 8. Peek it by setting color ↑ alpha to 0
          child: BottomNavigationBar(
            currentIndex: widget.tabController.index,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0),
            selectedItemColor: Theme.of(context).selectedRowColor,
            unselectedItemColor: Theme.of(context).unselectedWidgetColor,
            onTap: changePage,
            enableFeedback: true,
            iconSize: 30,
            selectedFontSize: 13,
            unselectedFontSize: 10,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: AppLocalizations.of(context)!.mainMenu,
                //backgroundColor: Theme.of(context).primaryColor,
              ),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.search),
                  //backgroundColor: Theme.of(context).primaryColor,
                  label: AppLocalizations.of(context)!.scanCodeButton),
            ],
          )),
    );
  }
}
