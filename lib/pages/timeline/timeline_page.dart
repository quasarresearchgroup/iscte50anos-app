import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_topic_table.dart';
import 'package:iscte_spots/models/database/tables/database_topic_table.dart';
import 'package:iscte_spots/models/timeline/content.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/pages/timeline/timeline_dial.dart';
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
  late Future<List<Event>> mapdata;

  @override
  void initState() {
    super.initState();
    resetMapData();
  }

  void resetMapData() {
    setState(() {
      mapdata = DatabaseEventTable.getAll();
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
        floatingActionButton: TimelineDial(
          isDialOpen: isDialOpen,
          deleteTimelineData: deleteTimelineData,
          refreshTImelineData: deleteGetAllEventsFromCsv,
        ),
        body: FutureBuilder<List<Event>>(
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

  Future<void> deleteGetAllEventsFromCsv(BuildContext context) async {
    await deleteTimelineData(context);
    await TimelineContentService.insertContentEntriesFromCSV();
    setState(() {
      mapdata = DatabaseEventTable.getAll();
    });
    await logAllLength();
    widget._logger.d("Inserted from CSV");
  }

  Future<void> deleteTimelineData(BuildContext context) async {
    await DatabaseEventTopicTable.removeALL();
    await DatabaseEventContentTable.removeALL();
    await DatabaseContentTable.removeALL();
    await DatabaseEventTable.removeALL();
    await DatabaseTopicTable.removeALL();
    widget._logger.d("Removed all content, events and topics from db");
    setState(() {
      mapdata = DatabaseEventTable.getAll();
    });
  }

  Future<void> logAllLength() async {
    List<Content> databaseContentTable = await DatabaseContentTable.getAll();
    List<Event> databaseEventTable = await DatabaseEventTable.getAll();
    List<Topic> databaseTopicTable = await DatabaseTopicTable.getAll();
    List<EventTopicDBConnection> databaseEventTopicTable =
        await DatabaseEventTopicTable.getAll();
    List<EventContentDBConnection> databaseEventContentTable =
        await DatabaseEventContentTable.getAll();

    widget._logger.d("""databaseContentTable: ${databaseContentTable.length}
    databaseEventTable: ${databaseEventTable.length}
    databaseTopicTable: ${databaseTopicTable.length}
    databaseEventTopicTable: ${databaseEventTopicTable.length}
    databaseEventContentTable: ${databaseEventContentTable.length}""");
  }
}
