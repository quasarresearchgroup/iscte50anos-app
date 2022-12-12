import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/services/timeline/timeline_event_service.dart';
import 'package:iscte_spots/services/timeline/timeline_topic_service.dart';

class TimelineState extends ChangeNotifier {
  TimelineState._privateConstructor()
      : isDialOpen = ValueNotifier<bool>(false),
        yearsList = TimelineEventService.fetchYearsList(),
        availableTopicsFuture = TimelineTopicService.fetchAllTopics(),
        availableScopesFuture = Future(() => EventScope.values),
        selectedYear = SharedPrefsService().currentTimelineYearNotifier,
        currentEventsList = TimelineEventService.fetchEventsFromYear(
            year: SharedPrefsService().currentTimelineYearNotifier.value ?? 1);

  static final TimelineState _instance = TimelineState._privateConstructor();
  static TimelineState get instance => _instance;

  final ValueNotifier<int?> selectedYear;
  final ValueNotifier<bool> isDialOpen;
  Future<List<int>> yearsList;
  Future<List<Event>> currentEventsList;
  Future<List<Topic>> availableTopicsFuture;
  Future<List<EventScope>> availableScopesFuture;

  static void changeCurrentYear(int year) {
    LoggerService.instance.debug("changeCurrentYear $year");
    SharedPrefsService.storeTimelineSelectedYear(year);
    instance.currentEventsList = TimelineEventService.fetchEventsFromYear(
        year: SharedPrefsService().currentTimelineYearNotifier.value ?? 1);
    instance.notifyListeners();
  }

  static void refreshYearList() {
    LoggerService.instance.debug("refreshYearList");
    instance.yearsList = TimelineEventService.fetchYearsList();
    instance.notifyListeners();
  }

  static void refreshEventList() {
    LoggerService.instance.debug(
        "refreshEventList ${SharedPrefsService().currentTimelineYearNotifier.value}");
    instance.currentEventsList = TimelineEventService.fetchEventsFromYear(
        year: SharedPrefsService().currentTimelineYearNotifier.value ?? 1);
    instance.notifyListeners();
  }

/*
  filteredEvents = yearsList.then(
  (value) => value.contains(selectedYear.value)
  ? TimelineEventService.fetchEventsFromYear(year: selectedYear.value!)
      : TimelineEventService.fetchEventsFromYear(year: value.last),
  );*/
}
