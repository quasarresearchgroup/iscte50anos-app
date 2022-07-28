import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/content.dart';
import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/pages/timeline/timeline_search_delegate.dart';
import 'package:iscte_spots/services/timeline_service.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class TimelinePage extends StatefulWidget {
  TimelinePage({Key? key}) : super(key: key);
  final Logger _logger = Logger();

  static const pageRoute = "/timeline";

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late Future<List<Content>> mapdata;

  @override
  void initState() {
    super.initState();
    setState(() {
      mapdata = DatabaseContentTable.getAll();
    });
  }

  void resetMapData() {
    setState(() async {
      mapdata = DatabaseContentTable.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isDialOpen = ValueNotifier<bool>(false);

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
        /* floatingActionButton: TimelineDial(
            isDialOpen: isDialOpen,
            deleteTimelineData: deleteTimelineData,
            refreshTImelineData: refreshTimelineData),*/
        body: FutureBuilder<List<Content>>(
          future: mapdata,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return TimeLineBody(mapdata: snapshot.data!);
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(AppLocalizations.of(context)!.generalError));
            } else {
              return LoadingWidget();
            }
          },
        ),
      ),
    );
  }

  Future<void> refreshTimelineData(BuildContext context) async {
    await deleteTimelineData(context);
    await TimelineContentService.insertContentEntriesFromCSV();
    setState(() async {
      mapdata = DatabaseContentTable.getAll();
    });
    widget._logger.d("Inserted from CSV");
    //List<Content> mapdataCompleted = await mapdata;
    //widget._logger.d(mapdataCompleted.length);
    //Navigator.popAndPushNamed(context, TimelinePage.pageRoute);
  }

  Future<void> deleteTimelineData(BuildContext context) async {
    await DatabaseContentTable.removeALL();
    widget._logger.d("Removed all content from db");
    //setState(() {
    //Navigator.popAndPushNamed(context, TimelinePage.pageRoute);
    //});
  }
}
