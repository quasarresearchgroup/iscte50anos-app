import 'package:flutter/material.dart';
import 'package:iscte_spots/models/content.dart';

class TimeLineDetailsPage extends StatelessWidget {
  const TimeLineDetailsPage({
    required this.data,
    Key? key,
  }) : super(key: key);
  final int textweight = 2;
  final Content data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  data.contentIcon,
                  Text(
                    data.getDateString(),
                    textScaleFactor: textweight.toDouble(),
                  ),
                  data.contentIcon
                ],
              ),
              data.scopeIcon,
              Text(
                data.title,
                textScaleFactor: textweight.toDouble(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
