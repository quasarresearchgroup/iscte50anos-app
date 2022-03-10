import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/helper/image_manipulation.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:logger/logger.dart';

import '../my_bottom_bar.dart';
import 'moving_widget.dart';

class Shaker extends StatelessWidget {
  const Shaker({Key? key}) : super(key: key);
  static const pageRoute = "/shake";

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
            body: GravityPlane()));
  }
}

class GravityPlane extends StatefulWidget {
  int rows = 3;
  int cols = 3;

  GravityPlane({Key? key}) : super(key: key);
  final Logger logger = Logger();
  @override
  _GravityPlaneState createState() => _GravityPlaneState();
  double initialposX = 200;
  double initialposY = 100;
}

class _GravityPlaneState extends State<GravityPlane> {
  List<Widget> pieces = [];
  late int lastDeltaTime;

  @override
  void initState() {
    super.initState();

    late Image _image;
    _image = const Image(image: AssetImage('Resources/Img/campus-iscte-3.jpg'));

    ImageManipulation.splitImagePuzzlePieceNotDragable(
      image: _image,
      bringToTop: bringToTop,
      sendToBack: sendToBack,
      rows: widget.rows,
      cols: widget.cols,
    ).then((value) {
      setState(() {
        pieces = value;
      });
    });
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

  List<Widget> getMovableWidgets(
      {required double maxWidth, required double maxHeight}) {
    List<Widget> widgets = [];
    for (int i = 0; i < pieces.length; i++) {
      double radious = (Random().nextInt(10) + 10).toDouble();

      widgets.add(MovingWidget(
        weight: (Random().nextDouble() + 0.5) * 0.5,
        maxHeigth: maxHeight - radious * 2,
        maxwidth: maxWidth - radious * 2,
        child: pieces[i],
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Stack(
        children: getMovableWidgets(
            maxWidth: constraints.maxWidth, maxHeight: constraints.maxHeight),
      );
    });
  }
}
