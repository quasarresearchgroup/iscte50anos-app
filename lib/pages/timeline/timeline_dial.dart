import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TimelineDial extends StatelessWidget {
  const TimelineDial({
    Key? key,
    required this.isDialOpen,
    required this.deleteTimelineData,
    required this.refreshTimelineData,
  }) : super(key: key);

  final ValueNotifier<bool>? isDialOpen;
  final Function deleteTimelineData;
  final Function refreshTimelineData;

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
              deleteTimelineData();
            }),
        SpeedDialChild(
            child: const Icon(Icons.refresh),
            backgroundColor: Colors.green,
            label: 'Refresh',
            onTap: () {
              refreshTimelineData();
            }),
      ],
    );
  }
}
