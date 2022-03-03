import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:motion_sensors/motion_sensors.dart';

class MovingWidget extends StatefulWidget {
  MovingWidget({
    Key? key,
    required this.child,
    required this.maxwidth,
    required this.maxHeigth,
    required this.weight,
  }) : super(key: key);
  final Logger logger = Logger();

  @override
  _MovingWidgetState createState() => _MovingWidgetState();

  Widget child;
  final double weight;
  static const int standartSpeed = 100;
  final double maxaccel = 50;
  final double initialposX = 200;
  final double initialposY = 100;
  final double maxwidth;
  final double maxHeigth;
}

class _MovingWidgetState extends State<MovingWidget> {
  double posX = 0;
  double posY = 0;
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
      posX = widget.initialposX;
      posY = widget.initialposY;
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
      posX = (posX + x).clamp(0, widget.maxwidth);
      posY = (posY + y).clamp(0, widget.maxHeigth);
    });
  }

  void moveWAccell({required double x, required double y}) {
    accelX = (accelX + (x * MovingWidget.standartSpeed * widget.weight))
        .clamp(-widget.maxaccel, widget.maxaccel);
    accelY = (accelY + (y * MovingWidget.standartSpeed * widget.weight))
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
    posX = widget.initialposX;
    posY = widget.initialposY;
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
      left: posX,
      top: posY,
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
      ),
    );
  }
}
