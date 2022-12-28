import 'package:flutter/material.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/filter/timeline_filter_results_page.dart';
import 'package:iscte_spots/pages/timeline/state/timeline_state.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/timeline/timeline_topic_service.dart';

class TimelineFilterResultState {
  TimelineFilterResultState._privateConstructor()
      : _yearsList = ValueNotifier<Future<List<int>>>(Future.value([])),
        _eventsList =
            ValueNotifier<Future<List<Event>>>(Future.value(<Event>[])),
        _fullEventsList =
            ValueNotifier<Future<List<Event>>>(Future.value(<Event>[])),
        _selectedYear = ValueNotifier<int?>(null);

  static final TimelineFilterResultState _instance =
      TimelineFilterResultState._privateConstructor();

  final ValueNotifier<Future<List<int>>> _yearsList;
  static ValueNotifier<Future<List<int>>> get yearsList => _instance._yearsList;

  ///List of events available for display, spanning multiple years, used for internal storage and no need for server interaction while filtering
  final ValueNotifier<Future<List<Event>>> _fullEventsList;

  ///List of events available for display, only for selected year used for UI
  final ValueNotifier<Future<List<Event>>> _eventsList;
  static ValueNotifier<Future<List<Event>>> get eventsList =>
      _instance._eventsList;

  final ValueNotifier<int?> _selectedYear;
  static ValueNotifier<int?> get selectedYear => _instance._selectedYear;

  static void changeCurrentYear(int year) async {
    LoggerService.instance
        .debug("TimelineFilterResultState::changeCurrentYear $year");
    _instance._selectedYear.value = year;
    List<Event> eventsList = await _instance._fullEventsList.value;
    List<int> yearsList = await _instance._yearsList.value;

    _instance._eventsList.value = Future.value(eventsList
        .where(
          (e) =>
              e.dateTime.year ==
              (_instance._selectedYear.value ?? yearsList.last),
        )
        .toList());
  }

  static Future<void> submitFilter(BuildContext context) async {
    LoggerService.instance.debug("handleFilterSubmission");

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

    List<int> filteredYears =
        filteredEvents.map((e) => e.dateTime.year).toSet().toList();
    LoggerService.instance.debug(filteredEvents);
    LoggerService.instance.debug(filteredYears);

    _instance._fullEventsList.value = Future.value(filteredEvents);
    _instance._eventsList.value = Future.value(filteredEvents
        .where(
          (e) =>
              e.dateTime.year ==
              (_instance._selectedYear.value ?? filteredYears.last),
        )
        .toList());
    _instance._yearsList.value = Future.value(filteredYears);
    try {
      _instance._selectedYear.value = filteredYears.last;
    } catch (e) {
      LoggerService.instance.debug("Search Result filteredYears was empty: $e");
      _instance._selectedYear.value = 0;
    }

    //if (!context.mounted) return;
    Navigator.of(context).pushNamed(TimelineFilterResultsPage.pageRoute,
        arguments: TimelineState.currentTimelineFilterParams.value);
  }
}
