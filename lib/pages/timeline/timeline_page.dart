import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:iscte_spots/pages/timeline/timeline_filter_page.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/timeline/timeline_content_service.dart';
import 'package:iscte_spots/services/timeline/timeline_event_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
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

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    resetMapData();
  }

  void resetMapData() {
    setState(() {
      mapdata = DatabaseEventTable.getAll();
    });
    mapdata.then((value) {
      if (value.isEmpty) {
        deleteGetAllEventsFromCsv();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isDialOpen = ValueNotifier<bool>(false);

    Scaffold scaffold = Scaffold(
      appBar: MyAppBar(
        title: AppLocalizations.of(context)!.timelineScreen,
        trailing: (!PlatformService.instance.isIos)
            ? IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(TimelineFilterPage.pageRoute);
                },
                icon: const Icon(Icons.search),
              )
            : CupertinoButton(
                child: const Icon(
                  CupertinoIcons.search,
                  color: CupertinoColors.white,
                ),
                //color: CupertinoTheme.of(context).primaryContrastingColor,
                onPressed: () {
                  Navigator.of(context).pushNamed(TimelineFilterPage.pageRoute);
                },
              ),
        leading: DynamicBackIconButton(),
      ),
      floatingActionButton: TimelineDial(
          isDialOpen: isDialOpen,
          deleteTimelineData: deleteTimelineData,
          refreshTimelineData: deleteGetAllEventsFromCsv),
      body: RefreshIndicator(
        onRefresh: deleteGetAllEventsFromCsv,
        child: FutureBuilder<List<Event>>(
          future: mapdata,
          builder: (context, snapshot) {
            if (_loading) {
              return const LoadingWidget();
            } else if (snapshot.hasData) {
              if (snapshot.data!.isNotEmpty) {
                return TimeLineBody(mapdata: snapshot.data!);
              } else {
                return Center(
                  child:
                      Text(AppLocalizations.of(context)!.timelineNothingFound),
                );
              }
            } else if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingWidget();
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(AppLocalizations.of(context)!.generalError));
            } else {
              return const LoadingWidget();
            }
          },
        ),
      ),
    );

    return PlatformService.instance.isIos
        ? scaffold
        : Theme(
            data: Theme.of(context).copyWith(
              appBarTheme: Theme.of(context)
                  .appBarTheme
                  .copyWith(shape: const ContinuousRectangleBorder()),
            ),
            child: scaffold,
          );
  }

  Future<void> deleteGetAllEventsFromCsv() async {
    setState(() {
      // _loading = true;
    });
    await deleteTimelineData();
    List<Event> events = await TimelineEventService.fetchAllEvents();
    await DatabaseEventTable.addBatch(events);
    List<Content> contents;
    int contentId = 0;
    do {
      contents = await TimelineContentService.fetchContentsWithinIds(
          lower_id: contentId, upper_id: contentId + 100);
      widget._logger.d(contents.length);
      await DatabaseContentTable.addBatch(contents);
      contentId += 100;
    } while (contents.isNotEmpty);
    // widget._logger.d(events);
    // await TimelineCSVService.insertContentEntriesFromCSV();
    setState(() {
      mapdata = DatabaseEventTable.getAll();
      // _loading = false;
    });
    await logAllLength();
    widget._logger.d("Inserted from CSV");
  }

  Future<void> deleteTimelineData() async {
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
