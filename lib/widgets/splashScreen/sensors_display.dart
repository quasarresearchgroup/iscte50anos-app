import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sensors_plus/sensors_plus.dart';

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

  double gyroX = 0;
  double gyroY = 0;
  double gyroZ = 0;

  @override
  void initState() {
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        gyroX = event.x;
        gyroY = event.y;
        gyroZ = event.z;
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
            DataCell(Text(gyroX.toStringAsFixed(3))),
            DataCell(Text(gyroY.toStringAsFixed(3))),
            DataCell(Text(gyroZ.toStringAsFixed(3))),
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
