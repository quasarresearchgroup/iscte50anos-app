import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/helper/box_size.dart';
import 'package:logger/logger.dart';
import 'package:motion_sensors/motion_sensors.dart';

class MovingPiece extends StatefulWidget {
  Size imageSize;
  final Logger _logger = Logger();

  MovingPiece({
    Key? key,
    required this.child,
    required this.weight,
    required this.imageSize,
    required this.constraints,
  }) : super(key: key);
  final Logger logger = Logger();

  @override
  _MovingPieceState createState() => _MovingPieceState();

  Widget child;
  final BoxSize constraints;
  final double weight;
  static const int standartSpeed = 100;
  final double maxaccel = 50;
}

class _MovingPieceState extends State<MovingPiece> {
  double left = 0;
  double top = 0;
  double pitch = 0;
  double roll = 0;
  double yaw = 0;
  double accelX = 0;
  double accelY = 0;
  bool isMovable = true;
  //late DateTime lastDeltaTime;
  //late Duration lastTimedif;

  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  void resetPos() {
    accelX = 0;
    accelY = 0;
    setState(() {
      left = 0;
      top = 0;
    });
  }

/*  void deltaTime() {
    lastDeltaTime = DateTime.now();
    lastTimedif = HelperMethods.deltaTime(lastDeltaTime);
    widget.logger.d("lastDeltaTime" +
        lastDeltaTime.toString() +
        "lastTimedif" +
        lastTimedif.toString());
  }*/

  //region Move
  void autoMove({required double x, required double y}) {
    if (isMovable) {
      move(x: x, y: y);
    }
  }

  void fingerMove({required double x, required double y}) {
    //TODO use variable to stop automatic movement while hand is moving piece
    move(x: x, y: y);
  }

  void move({required double x, required double y}) {
    //TODO use variable to stop automatic movement while hand is moving piece
    setState(() {
      //deltaTime();
      left = (left + x)
          .clamp(widget.constraints.minWidth, widget.constraints.maxWidth);
      top = (top + y)
          .clamp(widget.constraints.minHeight, widget.constraints.maxHeight);
/*      widget._logger.d(
          "left:$left x:$x constraints.minWidth:${widget.constraints.minWidth} constraints.maxWidth:${widget.constraints.maxWidth} \n"
          "top:$top y:$y constraints.minHeight:${widget.constraints.minHeight}  constraints.maxHeight:${widget.constraints.maxHeight}");*/
    });
  }

  void moveWAccell({required double x, required double y}) {
    accelX = (accelX + (x * MovingPiece.standartSpeed * widget.weight))
        .clamp(-widget.maxaccel, widget.maxaccel);
    accelY = (accelY + (y * MovingPiece.standartSpeed * widget.weight))
        .clamp(-widget.maxaccel, widget.maxaccel);
    autoMove(x: accelX, y: accelY);
/*    widget.logger.d("accelX:" +
        accelX.toStringAsFixed(3) +
        "accelY:" +
        accelY.toStringAsFixed(3));*/
  }
  //endregion

  @override
  void initState() {
    super.initState();
    //lastDeltaTime = DateTime.now();
    //deltaTime();
    motionSensors.absoluteOrientationUpdateInterval =
        Duration.microsecondsPerSecond ~/ 10;
    _streamSubscriptions.add(motionSensors.absoluteOrientation
        .listen((AbsoluteOrientationEvent event) {
      setState(() {
        pitch = event.pitch;
        roll = event.roll;
        yaw = event.yaw;
      });
      moveWAccell(x: roll, y: pitch);
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
        left: left,
        top: top,
        duration:
            const Duration(microseconds: Duration.microsecondsPerSecond ~/ 10),
        child: GestureDetector(
          onPanStart: (dragUpdateDetails) {
            setState(() {
              isMovable = false;
            });
          },
          onPanUpdate: (dragUpdateDetails) {
            fingerMove(
              x: dragUpdateDetails.delta.dx,
              y: dragUpdateDetails.delta.dy,
            );
          },
          onPanEnd: (dragUpdateDetails) {
            setState(() {
              isMovable = true;
            });
          },
          child: widget.child,
        ));
  }
}
