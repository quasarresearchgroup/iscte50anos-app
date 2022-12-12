import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/services/timeline/timeline_topic_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:logger/logger.dart';

class TimelineFilterResultsPage extends StatefulWidget {
  TimelineFilterResultsPage({
    Key? key,
    required this.timelineFilterParams,
    required this.handleEventSelection,
    required this.handleYearSelection,
  }) : super(key: key);

  factory TimelineFilterResultsPage.androidBuilder(
      {required TimelineFilterParams timelineFilterParams}) {
    return TimelineFilterResultsPage(
      timelineFilterParams: timelineFilterParams,
      handleEventSelection: (eventId) {},
      handleYearSelection: (year) => null,
    );
  }

  final TimelineFilterParams timelineFilterParams;
  final void Function(int eventId) handleEventSelection;
  final void Function(int year) handleYearSelection;
  static const String pageRoute = "results";
  static const ValueKey pageKey = ValueKey(pageRoute);
  final Logger _logger = Logger();

  @override
  State<TimelineFilterResultsPage> createState() =>
      _TimelineFilterResultsPageState();
}

class _TimelineFilterResultsPageState extends State<TimelineFilterResultsPage> {
  late Future<List<Event>> filteredEvents;
  late Future<List<int>> filteredYears;
  @override
  void initState() {
    super.initState();
    List<int> topicIds =
        widget.timelineFilterParams.getTopics.map((e) => e.id).toList();

    Future<List<Event>> setOfEvents = TimelineTopicService.fetchEvents(
        topicIds: topicIds,
        scopes:
            widget.timelineFilterParams.getScopes.map((e) => e.name).toList());

    filteredEvents = setOfEvents.then((value) {
      widget._logger.d("events from topics: $value");
      String textSearchBar =
          widget.timelineFilterParams.searchText.toLowerCase();

      if (textSearchBar.isNotEmpty) {
        return value.where((Event element) {
          String eventTitle = (element.title).toLowerCase();
          return eventTitle.contains(textSearchBar) ||
              textSearchBar.contains(eventTitle);
        }).toList();
      } else {
        return value;
      }
    });

    filteredYears = filteredEvents
        .then((value) => value.map((e) => e.dateTime.year).toSet().toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(
          leading: const DynamicBackIconButton(),
          title: AppLocalizations.of(context)!.timelineSearchResults,
        ),
        body: TimeLineBodyBuilder(
          isFilterTimeline: true,
        ));
  }
}
