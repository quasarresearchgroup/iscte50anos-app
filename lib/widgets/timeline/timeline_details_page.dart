
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_reader/models/timeline_item.dart';

class TimeLineDetailsPage extends StatefulWidget {
  TimeLineData data;

  TimeLineDetailsPage({
    required this.data,
    Key? key,
  }) : super(key: key);

  @override
  State<TimeLineDetailsPage> createState() => _TimeLineDetailsPageState();
}

class _TimeLineDetailsPageState extends State<TimeLineDetailsPage> {
  @override
  Widget build(BuildContext context) {
    int textweight = 2;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Container(
              child: Column(
                children: [
                  Text(
                    widget.data.day.toString(),
                    textScaleFactor: textweight.toDouble(),
                  ),
                  Text(
                    widget.data.month.toString(),
                    textScaleFactor: textweight.toDouble(),
                  ),
                  Text(
                    widget.data.year.toString(),
                    textScaleFactor: textweight.toDouble(),
                  ),
                  Flexible(
                    child: Text(
                      widget.data.data,
                      textScaleFactor: textweight.toDouble(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
