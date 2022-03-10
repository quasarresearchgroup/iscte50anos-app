import 'package:flutter/material.dart';
import 'package:iscte_spots/widgets/timeline/year_timeline.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../models/content.dart';
import 'events_timeline.dart';

class TimeLineBody extends StatefulWidget {
  TimeLineBody({
    Key? key,
    required this.mapdata,
    this.initialchosenYear,
  }) : super(key: key);

  final int? initialchosenYear;

  final LineStyle lineStyle =
      const LineStyle(color: Colors.black, thickness: 6);
  List<Content> mapdata;

  @override
  State<TimeLineBody> createState() => _TimeLineBodyState();
}

class _TimeLineBodyState extends State<TimeLineBody> {
  int? chosenYear;
  List<int> list = [];

  void changeChosenYear(int year) {
    setState(() {
      chosenYear = year;
    });
  }

  List<int> createYearsList(List<Content> mapdata) {
    list = [];
    for (Content value in mapdata) {
      int year = value.year;
      if (!list.contains(year)) {
        list.add(year);
      }
    }
    list.sort();
    return list;
  }

  @override
  void initState() {
    list = createYearsList(widget.mapdata);
    chosenYear = widget.initialchosenYear ?? (list.length > 1 ? list.first : 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          flex: 15,
          child: Container(
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 15.0,
              )
            ]),
            child: YearTimeline(
              lineStyle: widget.lineStyle,
              yearsList: list,
              changeYearFunction: changeChosenYear,
              selectedYear: chosenYear != null ? chosenYear! : list.last,
            ),
          )),
      Expanded(
          flex: 100,
          child: EventsTimeline(
            timeLineMap: widget.mapdata,
            timelineYear: chosenYear!,
            lineStyle: widget.lineStyle,
          )),
    ]);
  }
}
