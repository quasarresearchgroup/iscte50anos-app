import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
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

  final FaIcon puzzleIcon = const FaIcon(FontAwesomeIcons.puzzlePiece);
  final Icon scanIcon = const Icon(Icons.search);
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
            unselectedItemColor: Colors.grey,
            //Theme.of(context).selectedRowColor.withOpacity(90),
            onTap: changePage,
            enableFeedback: true,
            iconSize: 30,
            selectedFontSize: 13,
            unselectedFontSize: 10,
            items: [
              BottomNavigationBarItem(
                icon: widget.puzzleIcon,
                label: AppLocalizations.of(context)!.mainMenu,
                //backgroundColor: Theme.of(context).primaryColor,
              ),
              BottomNavigationBarItem(
                  icon: widget.scanIcon,
                  //backgroundColor: Theme.of(context).primaryColor,
                  label: AppLocalizations.of(context)!.scanCodeButton),
            ],
          )),
    );
  }

  Widget buildLandscape(BuildContext context) {
    return NavigationRail(
      onDestinationSelected: (index) {
        if (index == 2) {
          Navigator.of(context).pushNamed(LeaderBoardPage.pageRoute);
        }
        widget.tabController.animateTo(index);
      },
      selectedIndex: widget.tabController.index,
      destinations: <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Center(child: widget.puzzleIcon),
          label: Text(AppLocalizations.of(context)!.mainMenu),
        ),
        NavigationRailDestination(
          icon: widget.scanIcon,
          label: Text(AppLocalizations.of(context)!.scanCodeButton),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.leaderboard_outlined),
          label: Text("leaderboard"),
        ),
      ],
    );
  }
}
