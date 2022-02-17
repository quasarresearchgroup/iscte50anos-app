import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:logger/logger.dart';

import '../my_bottom_bar.dart';
import 'moving_widget.dart';

class Shaker extends StatefulWidget {
  int rows = 3;
  int cols = 3;

  Shaker({Key? key}) : super(key: key);
  static const pageRoute = "/shake";
  final Logger logger = Logger();
  @override
  _ShakerState createState() => _ShakerState();
  double initialposX = 200, initialposY = 100;
}

class _ShakerState extends State<Shaker> {
  List<Widget> pieces = [];
  late int lastDeltaTime;

  @override
  void initState() {
    super.initState();

    /* late Image _image;
    _image = const Image(
        //image: AssetImage('Resources/Img/Logo/logo_50_anos_main.jpg'));
        image: AssetImage('Resources/Img/campus-iscte-3.jpg'));
    List<Widget> tempPieces = [];

    ImageManipulation.splitImagePuzzlePiece(
            image: _image,
            bringToTop: bringToTop,
            sendToBack: sendToBack,
            rows: widget.rows,
            cols: widget.cols,
            animDuration: const Duration(milliseconds: 10))
        .then((value) {
      setState(() {
        pieces = value;
      });
    });*/
  }

  void bringToTop(Widget widget) {
    setState(() {
      pieces.remove(widget);
      pieces.add(widget);
    });
  }

// when a piece reaches its final position, it will be sent to the back of the stack to not get in the way of other, still movable, pieces
  void sendToBack(Widget widget) {
    setState(() {
      pieces.remove(widget);
      pieces.insert(0, widget);
    });
  }

  List<Widget> getBalls({required double maxWidth, required double maxHeight}) {
    List<Widget> balls = [];
    balls.add(MovingPiece(
        child: const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.red,
        ),
        maxwidth: maxWidth,
        maxHeigth: maxHeight));
    balls.add(MovingPiece(
        child: const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.green,
        ),
        maxwidth: maxWidth,
        maxHeigth: maxHeight));
    return balls;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacementNamed(context, PageRoutes.home);
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
          body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              children: getBalls(
                  maxWidth: constraints.maxWidth,
                  maxHeight: constraints.maxHeight),
            );
          }),
        ));
  }
}
