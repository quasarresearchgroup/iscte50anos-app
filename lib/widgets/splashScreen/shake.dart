import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/helper/helper_methods.dart';
import 'package:iscte_spots/helper/image_manipulation.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:logger/logger.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../my_bottom_bar.dart';

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
  double pitch = 0;
  double roll = 0;
  double yaw = 0;
  late double posX;
  late double posY;
  double accelX = 0;
  double accelY = 0;

  List<Widget> pieces = [];

  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  late int lastDeltaTime;

  void resetPos() {
    posX = widget.initialposX;
    posY = widget.initialposY;
    accelX = 0;
    accelY = 0;
  }

  void moveWAccell({required double x, required double y}) {
    double timedif = HelperMethods.deltaTime(lastDeltaTime);
    accelX += x * timedif;
    accelY += y * timedif;
    moveBall(x: accelX, y: accelY);
  }

  void moveBall({required double x, required double y}) {
    setState(() {
      posX = (posX + x).clamp(
          0, context.size != null ? context.size!.width.toDouble() : 100);
      posY = (posY + y).clamp(
          0, context.size != null ? context.size!.height.toDouble() : 100);
    });
  }

  @override
  void initState() {
    super.initState();
    lastDeltaTime = DateTime.now().millisecondsSinceEpoch;
    posX = widget.initialposX;
    posY = widget.initialposY;
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      moveWAccell(x: roll, y: pitch);
      setState(() {
        pitch = event.x;
        roll = event.y;
        yaw = event.z;
        print(lastDeltaTime);
      });
    }));
    widget.logger.d("added sensor subscription");

    late Image _image;
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
    });
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
      widget.logger.d("canceled sensor subscription");
    }
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
        floatingActionButton: FloatingActionButton(
          onPressed: resetPos,
        ),
        body: Stack(
          children: [
            AnimatedPositioned(
              left: posX,
              top: posY,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onPanUpdate: (dragUpdateDetails) {
                  moveBall(
                    x: dragUpdateDetails.delta.dx,
                    y: dragUpdateDetails.delta.dy,
                  );
                },
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}