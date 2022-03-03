import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/loader/timeline_loader.dart';
import 'package:iscte_spots/models/timeline_item.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:iscte_spots/widgets/timeline/events_timeline.dart';
import 'package:iscte_spots/widgets/timeline/year_timeline.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelinePage extends StatefulWidget {
  TimelinePage({Key? key}) : super(key: key);
  final Logger logger = Logger();

  static const pageRoute = "/timeline";

  late final Future<List<TimeLineData>> mapdata;
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
    super.initState();
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
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacementNamed(context, PageRoutes.home);
          return true;
        },
        child: Scaffold(
          drawer: const NavigationDrawer(),
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.timelineScreen),
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
                      return Center(
                          child:
                              Text(AppLocalizations.of(context)!.generalError));
                    } else {
                      return LoadingWidget();
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
                      return Center(child: Text(AppLocalizations.of(context)!.generalError));
                    } else {
                      return LoadingWidget();
                    }
                  },
                ),
              ),
            ]),
          ),
        ));
  }
}
