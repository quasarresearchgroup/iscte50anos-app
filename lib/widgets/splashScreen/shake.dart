import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:logger/logger.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../my_bottom_bar.dart';

class Shaker extends StatefulWidget {
  Shaker({Key? key}) : super(key: key);
  static const pageRoute = "/shake";
  final Logger logger = Logger();
  @override
  _ShakerState createState() => _ShakerState();
}

class _ShakerState extends State<Shaker> {
  double gyro_x = 0;
  double gyro_y = 0;
  double gyro_z = 0;
  double accel_x = 0;
  double accel_y = 0;
  double accel_z = 0;
  double posX = 200, posY = 100;

  @override
  void initState() {
    super.initState();
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        gyro_x = event.x;
        gyro_y = event.y;
        gyro_z = event.z;
        posX = posX + (gyro_y * 20);
        posY = posY + (gyro_x * 20);
        widget.logger.d('posX:' + posX.toString() + 'posY:' + posY.toString());
      });
    });
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        accel_x = event.x;
        accel_y = event.y;
        accel_z = event.z;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavigationDrawer(),
      appBar: AppBar(
        title: Title(
            color: Colors.black,
            child: Text(AppLocalizations.of(context)!.appName)),
      ),
      bottomNavigationBar: const MyBottomBar(selectedIndex: 0),
      body: Column(
        children: [
          Flexible(
            flex: 2,
            child: sensorsDisplays(
                gyro_x: gyro_x,
                gyro_y: gyro_y,
                gyro_z: gyro_z,
                accel_x: accel_x,
                accel_y: accel_y,
                accel_z: accel_z),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              child: Stack(
                children: [
                  Positioned(
                    left: posX,
                    top: posY,
                    child: GestureDetector(
                      onPanUpdate: (dragUpdateDetails) {
                        setState(() {
                          posY = posY + dragUpdateDetails.delta.dy;
                          posX = posX + dragUpdateDetails.delta.dx;
                          widget.logger.d('posX:' +
                              posX.toString() +
                              'posY:' +
                              posY.toString());
                        });
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
          ),
        ],
      ),
    );
  }
}

class sensorsDisplays extends StatelessWidget {
  const sensorsDisplays({
    Key? key,
    required this.gyro_x,
    required this.gyro_y,
    required this.gyro_z,
    required this.accel_x,
    required this.accel_y,
    required this.accel_z,
  }) : super(key: key);

  final double gyro_x;
  final double gyro_y;
  final double gyro_z;
  final double accel_x;
  final double accel_y;
  final double accel_z;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text(gyro_x.ceil().toString()),
          leading: Text('gyro_x'),
        ),
        ListTile(
          title: Text(gyro_y.ceil().toString()),
          leading: Text('gyro_y'),
        ),
        ListTile(
          title: Text(gyro_z.ceil().toString()),
          leading: Text('gyro_z'),
        ),
        ListTile(
          title: Text(accel_x.ceil().toString()),
          leading: Text('accel_x'),
        ),
        ListTile(
          title: Text(accel_y.ceil().toString()),
          leading: Text('accel_y'),
        ),
        ListTile(
          title: Text(accel_z.ceil().toString()),
          leading: Text('accel_z'),
        ),
      ],
    );
  }
}
