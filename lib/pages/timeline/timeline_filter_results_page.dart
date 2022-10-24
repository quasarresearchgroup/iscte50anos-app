import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/pages/timeline/timeline_body.dart';
import 'package:iscte_spots/services/timeline/timeline_topic_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class TimelineFilterResultsPage extends StatefulWidget {
  TimelineFilterResultsPage({
    Key? key,
    required this.timelineFilterParams,
  }) : super(key: key);

  final TimelineFilterParams timelineFilterParams;
  static const String pageRoute = "results";
  static const ValueKey pageKey = ValueKey(pageRoute);
  final Logger _logger = Logger();

  @override
  State<TimelineFilterResultsPage> createState() =>
      _TimelineFilterResultsPageState();
}

class _TimelineFilterResultsPageState extends State<TimelineFilterResultsPage> {
  late Future<List<Event>> filteredEvents;
  @override
  void initState() {
    super.initState();
    List<int> topicIds =
        widget.timelineFilterParams.getTopics.map((e) => e.id).toList();

    Future<List<Event>> setOfEvents;

    setOfEvents = TimelineTopicService.fetchEvents(
        topicIds: topicIds,
        scopes:
            widget.timelineFilterParams.getScopes.map((e) => e.name).toList());
    filteredEvents = setOfEvents.then((value) {
      widget._logger.d("events from topics: $setOfEvents");
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        leading: const DynamicBackIconButton(),
        title: AppLocalizations.of(context)!.timelineSearchResults,
      ),
      body: FutureBuilder<List<Event>>(
          future: filteredEvents,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text("No results"));
              } else {
                return TimeLineBody(
                  filteredEvents: snapshot.data!,
                  selectedYear: snapshot.data!.last.dateTime.year,
                );
              }
            } else if (snapshot.hasError) {
              return ErrorWidget(AppLocalizations.of(context)!.generalError);
            } else {
              return const LoadingWidget();
            }
          }),
    );
  }
}
