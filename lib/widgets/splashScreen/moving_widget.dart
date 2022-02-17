import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/helper/helper_methods.dart';
import 'package:logger/logger.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MovingPiece extends StatefulWidget {
  MovingPiece(
      {Key? key,
      required this.child,
      required this.maxwidth,
      required this.maxHeigth})
      : super(key: key);
  final Logger logger = Logger();

  @override
  _MovingPieceState createState() => _MovingPieceState();

  Widget child;

  final double maxaccel = 100;
  final double initialposX = 200;
  final double initialposY = 100;
  final double maxwidth;
  final double maxHeigth;
}

class _MovingPieceState extends State<MovingPiece> {
  double posX = 0;
  double posY = 0;
  double pitch = 0;
  double roll = 0;
  double yaw = 0;
  double accelX = 0;
  double accelY = 0;
  late int lastDeltaTime;

  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  void resetPos() {
    accelX = 0;
    accelY = 0;
    setState(() {
      posX = widget.initialposX;
      posY = widget.initialposY;
    });
  }

  void moveWAccell({required double x, required double y}) {
    double timedif = HelperMethods.deltaTime(lastDeltaTime);
    accelX = (accelX + (x * timedif)).clamp(-widget.maxaccel, widget.maxaccel);
    accelY = (accelY + (y * timedif)).clamp(-widget.maxaccel, widget.maxaccel);
    //accelX = (accelX + (x * timedif));
    //accelY = (accelY + (y * timedif));
    move(x: accelX, y: accelY);
  }

  void move({required double x, required double y}) {
    setState(() {
      posX = (posX + x).clamp(0, widget.maxwidth - 40);
      posY = (posY + y).clamp(0, widget.maxHeigth - 40);
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
      });
    }));
    widget.logger.d("added sensor subscription");
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
      widget.logger.d("canceled sensor subscription");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      left: posX,
      top: posY,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onPanUpdate: (dragUpdateDetails) {
          move(
            x: dragUpdateDetails.delta.dx,
            y: dragUpdateDetails.delta.dy,
          );
        },
        child: widget.child,
      ),
    );
  }
}
