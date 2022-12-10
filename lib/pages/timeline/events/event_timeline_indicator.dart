import 'package:flutter/material.dart';
import 'package:iscte_spots/helper/datetime_extension.dart';

class EventTimelineIndicator extends StatelessWidget {
  EventTimelineIndicator({
    Key? key,
    required this.isEven,
    required this.time,
    required this.isLast,
    required this.isFirst,
    this.textColor,
  }) : super(key: key);

  final bool isEven;
  final bool isLast;
  final bool isFirst;
  final DateTime time;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            time.monthName(),
            style: MediaQuery.of(context).size.width > 500
                ? Theme.of(context).textTheme.titleSmall
                : Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
          ),
          Text(
            time.day.toString(),
            style: MediaQuery.of(context).size.width > 500
                ? Theme.of(context).textTheme.titleSmall
                : Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
          ),
        ],
      ),
    ));
  }
}
