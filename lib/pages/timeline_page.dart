import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/content.dart';
import 'package:logger/logger.dart';

import '../models/database/tables/database_content_table.dart';
import '../services/timeline_service.dart';
import '../widgets/timeline/timeline_body.dart';
import '../widgets/timeline/timeline_search_delegate.dart';
import '../widgets/util/loading.dart';

class TimelinePage extends StatefulWidget {
  TimelinePage({Key? key}) : super(key: key);
  final Logger logger = Logger();

  static const pageRoute = "/timeline";

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late Future<List<Content>> mapdata;

  @override
  void initState() {
    super.initState();
    //mapdata = ContentLoader.getTimeLineEntries();
    mapdata = DatabaseContentTable.getAll();
  }

  void resetMapData() {
    mapdata = DatabaseContentTable.getAll();
  }

  @override
  Widget build(BuildContext context) {
    var isDialOpen = ValueNotifier<bool>(false);

    return Theme(
      data: Theme.of(context).copyWith(
          appBarTheme: Theme.of(context)
              .appBarTheme
              .copyWith(shape: const ContinuousRectangleBorder())),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.timelineScreen),
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: TimelineSearchDelegate(mapdata: mapdata));
                },
                icon: const FaIcon(FontAwesomeIcons.search))
          ],
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          backgroundColor: Theme.of(context).primaryColor,
          openCloseDial: isDialOpen,
          elevation: 8.0,
          children: [
            SpeedDialChild(
                child: const FaIcon(FontAwesomeIcons.trash),
                backgroundColor: Colors.red,
                label: 'Delete',
                onTap: () {
                  setState(() {
                    DatabaseContentTable.removeALL();
                    widget.logger.d("Removed all content");
                    Navigator.popAndPushNamed(context, TimelinePage.pageRoute);
                  });
                }),
            SpeedDialChild(
                child: const Icon(Icons.refresh),
                backgroundColor: Colors.green,
                label: 'Refresh',
                onTap: () {
                  TimelineContentService.insertContentEntriesFromCSV()
                      .then((value) {
                    setState(() {
                      widget.logger.d("Inserted from CSV");
                      mapdata = DatabaseContentTable.getAll();
                      mapdata.then((value) => widget.logger.d(value.length));
                      Navigator.popAndPushNamed(
                          context, TimelinePage.pageRoute);
                    });
                  });
                }),
          ],
        ),
        body: FutureBuilder<List<Content>>(
          future: mapdata,
          builder: (context, snapshot) {
            Widget body = Container();
            if (snapshot.hasData) {
              body = TimeLineBody(mapdata: snapshot.data!);
            } else if (snapshot.hasError) {
              body = Center(
                  child: Text(AppLocalizations.of(context)!.generalError));
            } else {
              body = const LoadingWidget();
            }
            return body;
          },
        ),
      ),
    );
  }
}
/*
            headerSliverBuilder:
              (BuildContext context, bool innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              title: Text(AppLocalizations.of(context)!.timelineScreen),
              actions: [
                IconButton(
                    onPressed: () {
                      showSearch(
                          context: context,
                          delegate: TimelineSearchDelegate(mapdata: mapdata));
                    },
                    icon: const FaIcon(FontAwesomeIcons.search))
              ],
              bottom: PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height / 9),
                child: Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      blurRadius: 15.0,
                    )
                  ]),
                  child: YearTimelineListView(
                    yearsList: list,
                    changeYearFunction: changeChosenYear,
                    selectedYear: chosenYear != null ? chosenYear! : list.last,
                  ),
                ),
              ),
            )
          ]
* */
