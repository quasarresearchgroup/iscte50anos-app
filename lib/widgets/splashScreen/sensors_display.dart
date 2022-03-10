import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:motion_sensors/motion_sensors.dart';

class SensorsDisplay extends StatefulWidget {
  SensorsDisplay({
    Key? key,
  }) : super(key: key);
  final Logger logger = Logger();

  @override
  State<SensorsDisplay> createState() => _SensorsDisplayState();
}

class _SensorsDisplayState extends State<SensorsDisplay> {
  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  double pitch = 0;
  double roll = 0;
  double yaw = 0;

  @override
  void initState() {
    _streamSubscriptions.add(motionSensors.absoluteOrientation
        .listen((AbsoluteOrientationEvent event) {
      setState(() {
        pitch = event.pitch;
        roll = event.roll;
        yaw = event.yaw;
      });
    }));
    widget.logger.d("added sensor subscription");

    super.initState();
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
            DataCell(Text(pitch.toStringAsFixed(3))),
            DataCell(Text(roll.toStringAsFixed(3))),
            DataCell(Text(yaw.toStringAsFixed(3))),
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
