import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class MyBottomBar extends StatefulWidget {
  final TabController tabController;
  final int initialIndex;
  final Orientation orientation;

  const MyBottomBar({
    Key? key,
    required this.initialIndex,
    required this.tabController,
    this.orientation = Orientation.portrait,
  }) : super(key: key);

  @override
  _MyBottomBarState createState() => _MyBottomBarState();

  static const FaIcon puzzleIcon = FaIcon(FontAwesomeIcons.puzzlePiece);
  static const Icon scanIcon = Icon(Icons.search);
  static const Icon leaderboardIcon = Icon(Icons.leaderboard);

  static List<BottomNavigationBarItem> buildnavbaritems(BuildContext context) {
    return [
      BottomNavigationBarItem(
        icon: puzzleIcon,
        label: AppLocalizations.of(context)!.mainMenu,
        //backgroundColor: Theme.of(context).primaryColor,
      ),
      const BottomNavigationBarItem(
          icon: leaderboardIcon,
          //backgroundColor: Theme.of(context).primaryColor,
          label: "Rankings"),
      BottomNavigationBarItem(
          icon: scanIcon,
          //backgroundColor: Theme.of(context).primaryColor,
          label: AppLocalizations.of(context)!.scanCodeButton),
    ];
  }
}

class _MyBottomBarState extends State<MyBottomBar> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;

    widget.tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
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
    return widget.orientation == Orientation.portrait
        ? buildPortrait(context)
        : buildLandscape(context);
  }

  Widget buildPortrait(BuildContext context) {
    if (PlatformService.instance.isIos) {
      return buildcupertino(context);
    } else {
      return buildmaterial(context);
    }
  }

  Widget buildLandscape(BuildContext context) {
    return NavigationRail(
      onDestinationSelected: (index) {
        widget.tabController.animateTo(index);
      },
      selectedIndex: widget.tabController.index,
      destinations: <NavigationRailDestination>[
        NavigationRailDestination(
          icon: const Center(child: MyBottomBar.puzzleIcon),
          label: Text(AppLocalizations.of(context)!.mainMenu),
        ),
        const NavigationRailDestination(
          icon: MyBottomBar.leaderboardIcon,
          label: Text("Rankings"),
        ),
        NavigationRailDestination(
          icon: MyBottomBar.scanIcon,
          label: Text(AppLocalizations.of(context)!.scanCodeButton),
        ),
      ],
    );
  }

  Widget buildcupertino(BuildContext context) {
    return CupertinoTabBar(
      items: MyBottomBar.buildnavbaritems(context),
      backgroundColor: Theme.of(context).primaryColor,
      currentIndex: widget.tabController.index,
      activeColor: Theme.of(context).selectedRowColor,
      inactiveColor: Theme.of(context).unselectedWidgetColor,
      height: kToolbarHeight * 1.05,
      onTap: changePage,
    );
  }

  ClipRRect buildmaterial(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: IscteTheme.appbarRadius,
        topRight: IscteTheme.appbarRadius,
      ),
      child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          // ← carves notch for FAB in BottomAppBar
          color: Theme.of(context).primaryColor,
          // ↑ use .withAlpha(0) to debug/peek underneath ↑ BottomAppBar
          elevation: 0,
          // ← removes slight shadow under FAB, hardly noticeable
          // ↑ default elevation is 8. Peek it by setting color ↑ alpha to 0
          child: BottomNavigationBar(
            currentIndex: widget.tabController.index,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0),
            selectedItemColor: Theme.of(context).selectedRowColor,
            unselectedItemColor: Theme.of(context).unselectedWidgetColor,
            //Theme.of(context).selectedRowColor.withOpacity(90),
            onTap: changePage,
            enableFeedback: true,
            iconSize: 30,
            selectedFontSize: 13,
            unselectedFontSize: 10,
            items: MyBottomBar.buildnavbaritems(context),
          )),
    );
  }
}
