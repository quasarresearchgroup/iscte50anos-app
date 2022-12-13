import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/pages/timeline/state/timeline_state.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/timeline/timeline_topic_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';

class TimelineFilterResultsPage extends StatefulWidget {
  TimelineFilterResultsPage({Key? key}) : super(key: key);

  factory TimelineFilterResultsPage.androidBuilder(
      {required TimelineFilterParams timelineFilterParams}) {
    return TimelineFilterResultsPage();
  }

  static const String pageRoute = "results";
  static const ValueKey pageKey = ValueKey(pageRoute);

  @override
  State<TimelineFilterResultsPage> createState() =>
      _TimelineFilterResultsPageState();
}

class _TimelineFilterResultsPageState extends State<TimelineFilterResultsPage> {
  @override
  void initState() {
    super.initState();
    asyncinit();
  }

  Future<void> asyncinit() async {
    List<int> topicIds = (await TimelineState.availableTopicsFuture.value)
        .map((e) => e.id)
        .toList();

    List<Event> setOfEvents = await TimelineTopicService.fetchEvents(
        topicIds: TimelineState.currentTimelineFilterParams.value.topics
            .map((e) => e.id)
            .toList(),
        scopes: TimelineState.currentTimelineFilterParams.value.scopes
            .map((e) => e.name)
            .toList());
    LoggerService.instance.debug("events from topics: $setOfEvents");

    List<Event> filteredEvents;
    String textSearchBar = TimelineState
        .currentTimelineFilterParams.value.searchText
        .toLowerCase();

    filteredEvents = (textSearchBar.isNotEmpty)
        ? setOfEvents.where((Event element) {
            String eventTitle = (element.title).toLowerCase();
            return eventTitle.contains(textSearchBar) ||
                textSearchBar.contains(eventTitle);
          }).toList()
        : setOfEvents;

    TimelineState.storeEventList(filteredEvents);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        TimelineState.refreshEventList();
        TimelineState.refreshYearList();
        LoggerService.instance.info("popped out of timeline filter results");
        return true;
      },
      child: Scaffold(
          appBar: MyAppBar(
            leading: const DynamicBackIconButton(),
            title: AppLocalizations.of(context)!.timelineSearchResults,
          ),
          body: const TimeLineBodyBuilder(
            isFilterTimeline: true,
          )),
    );
  }
}
