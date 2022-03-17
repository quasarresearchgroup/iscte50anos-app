import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/pages/puzzle_page.dart';
import 'package:iscte_spots/widgets/my_bottom_bar.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:logger/logger.dart';

class Home extends StatefulWidget {
  Home({
    Key? key,
  }) : super(key: key);
  static const pageRoute = "/";
  final Logger _logger = Logger();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> urls = [];
  Image currentPuzzleImage =
      Image.asset('Resources/Img/Campus/campus-iscte-3.jpg');

  @override
  Widget build(BuildContext context) {
    PuzzlePage puzzlePage = PuzzlePage(image: currentPuzzleImage);
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
          bottomNavigationBar: const MyBottomBar(selectedIndex: 0),
          floatingActionButton: FloatingActionButton(
            child: const Icon(FontAwesomeIcons.redoAlt),
            onPressed: () {
              widget._logger.d("Pressed refresh");
              if (urls.isEmpty) {
                puzzlePage.fetchAndRandomizeImage();
              } else {
                puzzlePage.randomizeImage();
              }
            },
          ),
          body: puzzlePage,
        ));
  }
}
