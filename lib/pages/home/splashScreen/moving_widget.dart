import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/helper/box_size.dart';
import 'package:motion_sensors/motion_sensors.dart';

class MovingPiece extends StatefulWidget {
  const MovingPiece({
    Key? key,
    required this.child,
    required this.weight,
    required this.imageSize,
    required this.constraints,
  }) : super(key: key);

  @override
  MovingPieceState createState() => MovingPieceState();

  static const int standartSpeed = 100;

  final Size imageSize;
  final Widget child;
  final BoxSize constraints;
  final double weight;
  final double maxaccel = 50;
}

class MovingPieceState extends State<MovingPiece> {
  double top = 0;
  double left = 0;
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

  //region Move
  void autoMove({required double x, required double y}) {
    if (isMovable) {
      move(x: x, y: y);
    }
  }

  void fingerMove({required double x, required double y}) {
    move(x: x, y: y);
  }

  void move({required double x, required double y}) {
    setState(() {
      left = (left + x)
          .clamp(widget.constraints.minWidth, widget.constraints.maxWidth);
      top = (top + y)
          .clamp(widget.constraints.minHeight, widget.constraints.maxHeight);
    });
  }

  void moveWAccell({required double x, required double y}) {
    accelX = (accelX + (x * MovingPiece.standartSpeed * widget.weight))
        .clamp(-widget.maxaccel, widget.maxaccel);
    accelY = (accelY + (y * MovingPiece.standartSpeed * widget.weight))
        .clamp(-widget.maxaccel, widget.maxaccel);
    autoMove(x: accelX, y: accelY);
  }
  //endregion

  @override
  void initState() {
    super.initState();
    top =
        Random().nextInt((widget.constraints.maxHeight).floor() + 1).toDouble();
    left =
        Random().nextInt((widget.constraints.maxWidth).floor() + 1).toDouble();

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
    //LoggerService.instance.debug("added sensor subscription");
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
      //LoggerService.instance.debug("canceled sensor subscription");
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
