import 'package:IscteSpots/models/timeline_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text("Details"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Container(
              child: Column(
                children: [
                  Text(
                    widget.data.getDateString(),
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
