import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/timeline/feedback_form.dart';
import 'package:iscte_spots/pages/timeline/filter/timeline_filter_page.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/services/timeline/timeline_event_service.dart';
import 'package:iscte_spots/services/timeline/timeline_topic_service.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class TimelinePage extends StatefulWidget {
  TimelinePage({Key? key}) : super(key: key);
  final Logger _logger = Logger();
  static const String pageRoute = "timeline";
  static const ValueKey pageKey = ValueKey(pageRoute);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late final Future<List<Event>> filteredEvents;
  late final ValueNotifier<int?> selectedYear;
  late final Future<List<int>> yearsList;

  late ValueNotifier<bool> isDialOpen;
  late Future<List<Topic>> availableTopicsFuture;
  late Future<List<EventScope>> availableScopesFuture;

  @override
  void initState() {
    super.initState();
    selectedYear = SharedPrefsService().currentTimelineYearNotifier;
    availableTopicsFuture = TimelineTopicService.fetchAllTopics();
    availableScopesFuture = Future(() => EventScope.values);
    yearsList = TimelineEventService.fetchYearsList();
    filteredEvents = yearsList.then(
      (value) => value.contains(selectedYear.value)
          ? TimelineEventService.fetchEventsFromYear(year: selectedYear.value!)
          : TimelineEventService.fetchEventsFromYear(year: value.last),
    );
    isDialOpen = ValueNotifier<bool>(false);
  }

  void handleEventSelection(int eventId) {
    LoggerService.instance.debug("handleEventSelection");
  }

  void handleYearSelection(int year) =>
      SharedPrefsService.storeTimelineSelectedYear(year);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: MyAppBar(
        title: AppLocalizations.of(context)!.timelineScreen,
        leading: FutureBuilder<List<int>>(
            future: yearsList,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    return IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => FeedbackForm(
                          yearsList: snapshot.data!,
                          selectedYear: selectedYear.value,
                        ),
                      ),
                      icon: const Icon(Icons.feedback_outlined),
                    );
                  } else {
                    return const LoadingWidget();
                  }
                default:
                  return const LoadingWidget();
              }
            }),
        trailing: Builder(builder: (context) {
          return (!PlatformService.instance.isIos)
              ? IconButton(
                  onPressed: Scaffold.of(context).openEndDrawer,
                  icon: const Icon(Icons.search),
                )
              : CupertinoButton(
                  onPressed: Scaffold.of(context).openEndDrawer,
                  child: const Icon(CupertinoIcons.search),
                );
        }),
      ),
      endDrawer: Drawer(
        width: width > 400
            ? width > 500
                ? width > 600
                    ? width * 0.4
                    : width * 0.7
                : width * 0.8
            : width,
        child: TimelineFilterPage(),
      ),
      body: TimeLineBodyBuilder(
        handleEventSelection: handleEventSelection,
        handleYearSelection: handleYearSelection,
        selectedYear: selectedYear,
        yearsList: yearsList,
        filteredEvents: filteredEvents,
        isFilterTimeline: false,
      ),
      persistentFooterAlignment: AlignmentDirectional.bottomStart,
      persistentFooterButtons: [
        if (MediaQuery.of(context).size.height < 700)
          Image.asset(
            "Resources/Img/Logo/rgb_iscte_pt_horizontal.png",
            height: kToolbarHeight + 25,
          )
      ],
    );
  }
}
