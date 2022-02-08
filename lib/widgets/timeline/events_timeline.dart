import 'package:IscteSpots/models/timeline_item.dart';
import 'package:IscteSpots/widgets/timeline/timeline_details_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:timeline_tile/timeline_tile.dart';

class EventsTimeline extends StatefulWidget {
  EventsTimeline(
      {Key? key,
      required this.timeLineMap,
      required this.timelineYear,
      required this.lineStyle})
      : super(key: key);
  List<TimeLineData> timeLineMap;
  int timelineYear;
  final LineStyle lineStyle;

  @override
  State<EventsTimeline> createState() => _EventsTimelineState();
}

class _EventsTimelineState extends State<EventsTimeline> {
  List<TimeLineData> chosenTimelineList = <TimeLineData>[];
  List<TimeLineData> originalTimelineList = <TimeLineData>[];

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
    for (final TimeLineData entry in widget.timeLineMap) {
      originalTimelineList.add(entry);
      if (entry.year == widget.timelineYear) {
        chosenTimelineList.add(entry);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: chosenTimelineList.length,
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemBuilder: (BuildContext context, int index) {
          return EventTimelineTile(
              data: chosenTimelineList[index],
              isFirst: index == 0,
              isLast: index == chosenTimelineList.length - 1,
              lineStyle: widget.lineStyle);
        });
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
  final TimeLineData data;
  final LineStyle lineStyle;
  Color color2 = Colors.white.withOpacity(0.3);

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
        lineXY: 0.15,
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
                Text(data.data),
              ],
            ),
          ),
        ),
        startChild: Center(child: data.scopeIcon),
      ),
    );
  }
}
