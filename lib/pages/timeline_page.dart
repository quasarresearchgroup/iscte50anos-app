import 'package:ISCTE_50_Anos/widgets/timeline/events_timeline.dart';
import 'package:ISCTE_50_Anos/widgets/timeline/year_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelinePage extends StatefulWidget {
  TimelinePage({Key? key}) : super(key: key);

  static const String TIMELINEENTRIESFILE = 'Resources/timeline.csv';
  Logger logger = Logger();
  late Future<Map<String, String>> mapdata;

  final List<int> yearsList = <int>[
    1972,
    1973,
    1974,
    1975,
    1976,
    1977,
    1978,
    1979,
    1980
  ];
  final lineStyle = const LineStyle(color: Colors.black, thickness: 6);

  Future<Map<String, String>> getTimeLineEntries() async {
    final Map<String, String> timeLineMap = {};

    try {
      final String file = await rootBundle.loadString(TIMELINEENTRIESFILE);

      logger.d(file.split("\n").length);
      file.split("\n").forEach((e) {
        var e_split = e.split(",");
        logger.d(e_split);
        timeLineMap.addEntries([MapEntry(e_split.first, e_split.last)]);
      });

      logger.d(timeLineMap);
      return timeLineMap;
    } catch (e) {
      // If encountering an error, return 0
      return timeLineMap;
    }
  }

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  int chosenYear = 1972;

  @override
  void initState() {
    widget.mapdata = widget.getTimeLineEntries();
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
            child: YearTimeline(
              lineStyle: widget.lineStyle,
              changeYearFunction: changeChosenYear,
              yearsList: widget.yearsList,
            ),
          ),
          Expanded(
            flex: 8,
            child: FutureBuilder<Map<String, String>>(
              future: widget.mapdata,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error"));
                } else if (snapshot.hasData) {
                  return EventsTimeline(
                    timeLineMap: snapshot.data!,
                    timelineYear: chosenYear,
                    lineStyle: widget.lineStyle,
                  );
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
