import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/loader/timeline_loader.dart';
import 'package:iscte_spots/models/content.dart';
import 'package:iscte_spots/widgets/nav_drawer/navigation_drawer.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:iscte_spots/widgets/timeline/events_timeline.dart';
import 'package:iscte_spots/widgets/timeline/year_timeline.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../models/database/tables/database_content_table.dart';

class TimelinePage extends StatefulWidget {
  TimelinePage({Key? key}) : super(key: key);
  final Logger logger = Logger();

  static const pageRoute = "/timeline";

  Future<List<Content>>? mapdata;

  final lineStyle = const LineStyle(color: Colors.black, thickness: 6);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  int chosenYear = DateTime.now().year;
  List<int> yearsList = [];

  void createYearsList(Future<List<Content>>? mapdata) async {
    //yearsList = [DateTime.now().year];
    mapdata?.then((value) {
      for (Content value in value) {
        int year = value.year;
        if (!yearsList.contains(year)) {
          yearsList.add(year);
        }
      }
      yearsList.sort();
      setState(() {});
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.mapdata = ContentLoader.getTimeLineEntries();
    createYearsList(widget.mapdata);
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
          floatingActionButton: FloatingActionButton(onPressed: () {
            widget.logger.d("Pressed to reload");
            DatabaseContentsTable.removeALL();
            widget.logger.d("Removed all content");
            ContentLoader.insertContentEntriesFromCSV();
            widget.logger.d("Inserted from CSV");
            DatabaseContentsTable.getAll()
                .then((value) => widget.logger.d(value));
            setState(() {});
          }),
          body: Column(children: [
            Expanded(
                flex: 1,
                child: YearTimeline(
                  lineStyle: widget.lineStyle,
                  yearsList: yearsList,
                  changeYearFunction: changeChosenYear,
                )),
            Expanded(
              flex: 9,
              child: FutureBuilder<List<Content>>(
                future: widget.mapdata,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return EventsTimeline(
                      timeLineMap: snapshot.data!,
                      timelineYear: chosenYear,
                      lineStyle: widget.lineStyle,
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
          ]),
        ));
  }
}
