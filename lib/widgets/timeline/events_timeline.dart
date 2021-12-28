import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_reader/models/timeline_item.dart';
import 'package:qr_code_reader/widgets/timeline/timeline_details_page.dart';
import 'package:timeline_tile/timeline_tile.dart';

class EventsTimeline extends StatefulWidget {
  EventsTimeline(
      {Key? key,
      required this.timeLineMap,
      required this.timelineYear,
      required this.lineStyle})
      : super(key: key);
  Map<String, String> timeLineMap;
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
    for (final entry in widget.timeLineMap.entries) {
      TimeLineData timeLineData = TimeLineData(entry.value, entry.key);
      originalTimelineList.add(timeLineData);
      if (timeLineData.year == widget.timelineYear) {
        chosenTimelineList.add(timeLineData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView.builder(itemBuilder: (BuildContext context, int index) {
      return EventTimelineTile(
          data: chosenTimelineList[index],
          isFirst: index == 0,
          isLast: index == chosenTimelineList.length - 1,
          lineStyle: widget.lineStyle);
    }));
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
        alignment: TimelineAlign.center,
        isFirst: isFirst,
        isLast: isLast,
        indicatorStyle: const IndicatorStyle(
          width: 25,
          height: 25,
          padding: EdgeInsets.symmetric(vertical: 8),
          drawGap: true,
          indicator: Center(
            child: Icon(Icons.event_available),
          ),
        ),
        endChild: Padding(
          padding: const EdgeInsets.all(10),
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
        startChild: Center(child: Text(data.year.toString())),
      ),
    );
  }
}
