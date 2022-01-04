import 'package:ISCTE_50_Anos/loader/timeline_loader.dart';
import 'package:ISCTE_50_Anos/models/timeline_item.dart';
import 'package:ISCTE_50_Anos/widgets/timeline/events_timeline.dart';
import 'package:ISCTE_50_Anos/widgets/timeline/year_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelinePage extends StatefulWidget {
  TimelinePage({Key? key}) : super(key: key);

  Logger logger = Logger();
  late Future<List<TimeLineData>> mapdata;
  late final Future<List<int>> yearsList;

  final lineStyle = const LineStyle(color: Colors.black, thickness: 6);

  @override
  State<TimelinePage> createState() => _TimelinePageState();

  Future<List<int>> createYearsList(Future<List<TimeLineData>> mapdata) async {
    List<int> yearsList = [DateTime.now().year];
    mapdata.then((value) {
      for (TimeLineData value in value) {
        int year = value.year;
        if (!yearsList.contains(year)) {
          yearsList.add(year);
        }
      }
    });
    yearsList.sort();
    return yearsList;
  }
}

class _TimelinePageState extends State<TimelinePage> {
  int chosenYear = DateTime.now().year;

  @override
  void initState() {
    widget.mapdata = TimelineLoader.getTimeLineEntries();
    widget.yearsList = widget.createYearsList(widget.mapdata);
  }

  void changeChosenYear(int year) {
    setState(() {
      chosenYear = year;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Timeline"),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            flex: 2,
            child: FutureBuilder<List<int>>(
              future: widget.yearsList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return YearTimeline(
                    lineStyle: widget.lineStyle,
                    yearsList: snapshot.data!,
                    changeYearFunction: changeChosenYear,
                  );
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error"));
                } else {
                  return const Center(child: Center(child: Text("Loading")));
                }
              },
            ),
          ),
          Expanded(
            flex: 8,
            child: FutureBuilder<List<TimeLineData>>(
              future: widget.mapdata,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return EventsTimeline(
                    timeLineMap: snapshot.data!,
                    timelineYear: chosenYear,
                    lineStyle: widget.lineStyle,
                  );
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error"));
                } else {
                  return const Center(child: Center(child: Text("Loading")));
                }
              },
            ),
          ),
        ]),
      ),
    );
  }
}
