import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:logger/logger.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../my_bottom_bar.dart';

class Shaker extends StatefulWidget {
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
  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  static const double moveMultiplier = 1;
  late int lastDeltaTime;

  double deltaTime() {
    int currTime = DateTime.now().millisecondsSinceEpoch;
    double timeDif = (currTime - lastDeltaTime) / 10;
    lastDeltaTime = currTime;
    return timeDif;
  }

  void resetPos() {
    posX = widget.initialposX;
    posY = widget.initialposY;
    accelX = 0;
    accelY = 0;
  }

  void movePos({required double x, required double y}) {
    double timedif = deltaTime();
    setState(() {
      accelX += x * timedif;
      accelY += y * timedif;

      posX = (posX + accelX).clamp(0, 100);
      posY = (posY + accelY).clamp(0, 100);
    });
  }

  void moveFinger({required double x, required double y}) {
    setState(() {
      posX = (posX + x).clamp(0, 100);
      posY = (posY + y).clamp(0, 100);
    });
  }

  @override
  void initState() {
    super.initState();
    lastDeltaTime = DateTime.now().millisecondsSinceEpoch;
    posX = widget.initialposX;
    posY = widget.initialposY;
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      movePos(x: roll, y: pitch);
      setState(() {
        pitch = event.x;
        roll = event.y;
        yaw = event.z;
        print(lastDeltaTime);
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
        body: Column(
          children: [
            Flexible(
              flex: 2,
              child: SensorsDisplay(
                gyroX: pitch,
                gyroY: roll,
                gyroZ: yaw,
                posX: posX,
                posY: posY,
                posZ: 0,
              ),
            ),
            Flexible(
              flex: 2,
              child: Stack(
                children: [
                  Positioned(
                    left: posX,
                    top: posY,
                    child: GestureDetector(
                      onPanUpdate: (dragUpdateDetails) {
                        moveFinger(
                          x: dragUpdateDetails.delta.dx,
                          y: dragUpdateDetails.delta.dy,
                        );
                      },
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SensorsDisplay extends StatelessWidget {
  const SensorsDisplay({
    Key? key,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.posX,
    required this.posY,
    required this.posZ,
  }) : super(key: key);

  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final double posX;
  final double posY;
  final double posZ;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Text(
            'Name',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        DataColumn(
          label: Text(
            'X',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        DataColumn(
          label: Text(
            'Y',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        DataColumn(
          label: Text(
            'Z',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
      rows: <DataRow>[
        DataRow(
          cells: <DataCell>[
            const DataCell(Text('Gyro')),
            DataCell(Text(gyroX.toStringAsFixed(3))),
            DataCell(Text(gyroY.toStringAsFixed(3))),
            DataCell(Text(gyroZ.toStringAsFixed(3))),
          ],
        ),
        DataRow(
          cells: <DataCell>[
            const DataCell(Text('Pos')),
            DataCell(Text(posX.toStringAsFixed(3))),
            DataCell(Text(posY.toStringAsFixed(3))),
            DataCell(Text(posZ.toStringAsFixed(3))),
          ],
        ),
/*        DataRow(
          cells: <DataCell>[
            const DataCell(Text('Accell')),
            DataCell(Text(accelX.ceil().toString())),
            DataCell(Text(accelY.ceil().toString())),
            DataCell(Text(accelZ.ceil().toString())),
          ],
        )*/
      ],
    );
  }
}
