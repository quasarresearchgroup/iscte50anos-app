import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/content.dart';
import 'package:logger/logger.dart';

import '../models/database/tables/database_content_table.dart';
import '../services/timeline_service.dart';
import '../widgets/timeline/timeline_body.dart';
import '../widgets/timeline/timeline_dial.dart';
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
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
              shape: const ContinuousRectangleBorder(),
            ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.timelineScreen),
          actions: [
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: TimelineSearchDelegate(mapdata: mapdata),
                );
              },
              icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
            )
          ],
        ),
        floatingActionButton: TimelineDial(
            isDialOpen: isDialOpen,
            deleteTimelineData: deleteTimelineData,
            refreshTImelineData: refreshTImelineData),
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

  void refreshTImelineData(BuildContext context) {
    TimelineContentService.insertContentEntriesFromCSV().then((value) {
      setState(() {
        widget.logger.d("Inserted from CSV");
        mapdata = DatabaseContentTable.getAll();
        mapdata.then((value) => widget.logger.d(value.length));
        Navigator.popAndPushNamed(context, TimelinePage.pageRoute);
      });
    });
  }

  void deleteTimelineData(BuildContext context) {
    setState(() {
      DatabaseContentTable.removeALL();
      widget.logger.d("Removed all content");
      Navigator.popAndPushNamed(context, TimelinePage.pageRoute);
    });
  }
}
