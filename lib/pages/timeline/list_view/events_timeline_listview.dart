import 'package:flutter/material.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/timeline_tile.dart';
import 'package:timeline_tile/timeline_tile.dart';

class EventTimelineListView extends StatefulWidget {
  const EventTimelineListView({
    Key? key,
    required this.timeLineMap,
    required this.timelineYear,
  }) : super(key: key);
  final List<Event> timeLineMap;
  final int timelineYear;

  @override
  State<EventTimelineListView> createState() => _EventTimelineListViewState();
}

class _EventTimelineListViewState extends State<EventTimelineListView> {
  List<Event> chosenTimelineList = <Event>[];
  List<Event> originalTimelineList = <Event>[];
  final double tileOffset = 0.4;

  @override
  void didUpdateWidget(covariant EventTimelineListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timelineYear != widget.timelineYear) {
      chosenTimelineList.clear();
      for (final entry in originalTimelineList) {
        if (entry.year == widget.timelineYear) {
          chosenTimelineList.add(entry);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    for (final Event entry in widget.timeLineMap) {
      originalTimelineList.add(entry);
      if (entry.year == widget.timelineYear) {
        chosenTimelineList.add(entry);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final LineStyle lineStyle =
        LineStyle(color: Theme.of(context).focusColor, thickness: 6);
    List<Widget> timelineTiles = [];

    for (int index = 0; index < chosenTimelineList.length; index++) {
      timelineTiles.add(
        EventTimelineTile(
          index: index,
          isEven: index % 2 == 0,
          data: chosenTimelineList[index],
          isFirst: index == 0,
          isLast: index == chosenTimelineList.length - 1,
          lineStyle: lineStyle,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        //addAutomaticKeepAlives: true,
        children: timelineTiles,
      ),
    );
  }
}
