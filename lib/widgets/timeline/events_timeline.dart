import 'package:flutter/material.dart';
import 'package:iscte_spots/models/content.dart';
import 'package:iscte_spots/widgets/timeline/timeline_details_page.dart';
import 'package:timeline_tile/timeline_tile.dart';

class EventsTimeline extends StatefulWidget {
  const EventsTimeline(
      {Key? key,
      required this.timeLineMap,
      required this.timelineYear,
      required this.lineStyle})
      : super(key: key);
  final List<Content> timeLineMap;
  final int timelineYear;
  final LineStyle lineStyle;

  @override
  State<EventsTimeline> createState() => _EventsTimelineState();
}

class _EventsTimelineState extends State<EventsTimeline> {
  List<Content> chosenTimelineList = <Content>[];
  List<Content> originalTimelineList = <Content>[];

  @override
  void didUpdateWidget(covariant EventsTimeline oldWidget) {
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
    for (final Content entry in widget.timeLineMap) {
      originalTimelineList.add(entry);
      if (entry.year == widget.timelineYear) {
        chosenTimelineList.add(entry);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> timelineTiles = [
/*
      ListTile(
          title: Center(
              child: Text(
        widget.timelineYear.toString(),
        style: TextStyle(fontSize: 30),
      )))
*/
    ];

    for (int index = 0; index < chosenTimelineList.length; index++) {
      timelineTiles.add(EventTimelineTile(
          data: chosenTimelineList[index],
          isFirst: index == 0,
          isLast: index == chosenTimelineList.length - 1,
          lineStyle: widget.lineStyle));
    }

    return ListView(
      children: timelineTiles,
    );
  }
}

class EventTimelineTile extends StatelessWidget {
  EventTimelineTile({
    Key? key,
    required this.lineStyle,
    required this.isFirst,
    required this.isLast,
    required this.data,
  }) : super(key: key);

  final bool isFirst;
  final bool isLast;
  final Content data;
  final LineStyle lineStyle;
  final Color color2 = Colors.white.withOpacity(0.3);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: color2,
      highlightColor: color2,
      enableFeedback: true,
      customBorder: const StadiumBorder(),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TimeLineDetailsPage(data: data))),
      child: TimelineTile(
        beforeLineStyle: lineStyle,
        afterLineStyle: lineStyle,
        axis: TimelineAxis.vertical,
        alignment: TimelineAlign.manual,
        lineXY: 0.20,
        isFirst: isFirst,
        isLast: isLast,
        indicatorStyle: IndicatorStyle(
          width: 25,
          height: 25,
          padding: const EdgeInsets.symmetric(vertical: 8),
          drawGap: true,
          indicator: Center(
            child: data.contentIcon,
          ),
        ),
        endChild: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(data.getDateString()),
                  ],
                ),
                Text(data.description),
              ],
            ),
          ),
        ),
        startChild: Center(child: data.scopeIcon),
      ),
    );
  }
}
