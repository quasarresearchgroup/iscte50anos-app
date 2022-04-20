import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TimelineDial extends StatelessWidget {
  TimelineDial({
    Key? key,
    required this.isDialOpen,
    required this.deleteTimelineData,
    required this.refreshTImelineData,
  }) : super(key: key);

  var isDialOpen;
  var deleteTimelineData;
  var refreshTImelineData;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).primaryColor,
      openCloseDial: isDialOpen,
      elevation: 8.0,
      children: [
        SpeedDialChild(
            child: const FaIcon(FontAwesomeIcons.trash),
            backgroundColor: Colors.red,
            label: 'Delete',
            onTap: () {
              deleteTimelineData(context);
            }),
        SpeedDialChild(
            child: const Icon(Icons.refresh),
            backgroundColor: Colors.green,
            label: 'Refresh',
            onTap: () {
              refreshTImelineData(context);
            }),
      ],
    );
  }
}
