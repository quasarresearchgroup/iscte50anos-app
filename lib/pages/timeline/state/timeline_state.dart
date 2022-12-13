import 'package:flutter/src/foundation/change_notifier.dart'
    show ChangeNotifier, ValueNotifier;
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/models/timeline/timeline_filter_params.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/services/timeline/timeline_event_service.dart';
import 'package:iscte_spots/services/timeline/timeline_topic_service.dart';

class TimelineState extends ChangeNotifier {
  TimelineState._privateConstructor()
      : _isDialOpen = ValueNotifier<bool>(false),
        _isFilter = ValueNotifier<bool>(false),
        _yearsList = ValueNotifier<Future<List<int>>>(
            TimelineEventService.fetchYearsList()),
        _availableTopicsFuture = ValueNotifier<Future<List<Topic>>>(
            TimelineTopicService.fetchAllTopics()),
        _availableScopesFuture = ValueNotifier<Future<List<EventScope>>>(
            Future(() => EventScope.values)),
        _selectedYear = SharedPrefsService().currentTimelineYearNotifier,
        _currentEventsList = ValueNotifier<Future<List<Event>>>(
            TimelineEventService.fetchEventsFromYear(
                year: SharedPrefsService().currentTimelineYearNotifier.value ??
                    1)),
        _currentTimelineFilterParams =
            SharedPrefsService().currentTimelineFilterNotifier;

  static final TimelineState _instance = TimelineState._privateConstructor();
  //static TimelineState get instance => _instance;

  final ValueNotifier<bool> _isDialOpen;
  final ValueNotifier<bool> _isFilter;

  static ValueNotifier<bool> get isDialOpen => _instance._isDialOpen;
  final ValueNotifier<Future<List<int>>> _yearsList;
  static ValueNotifier<Future<List<int>>> get yearsList => _instance._yearsList;
  final ValueNotifier<Future<List<Topic>>> _availableTopicsFuture;
  static ValueNotifier<Future<List<Topic>>> get availableTopicsFuture =>
      _instance._availableTopicsFuture;
  final ValueNotifier<Future<List<EventScope>>> _availableScopesFuture;
  static ValueNotifier<Future<List<EventScope>>> get availableScopesFuture =>
      _instance._availableScopesFuture;
  final ValueNotifier<int?> _selectedYear;
  static ValueNotifier<int?> get selectedYear => _instance._selectedYear;
  final ValueNotifier<Future<List<Event>>> _currentEventsList;
  static ValueNotifier<Future<List<Event>>> get currentEventsList =>
      _instance._currentEventsList;
  final ValueNotifier<TimelineFilterParams> _currentTimelineFilterParams;
  static ValueNotifier<TimelineFilterParams> get currentTimelineFilterParams =>
      _instance._currentTimelineFilterParams;

  static void changeCurrentYear(int year) {
    LoggerService.instance.debug("changeCurrentYear $year");
    SharedPrefsService.storeTimelineSelectedYear(year);
    if (!_instance._isFilter.value) {
      _instance._currentEventsList.value =
          TimelineEventService.fetchEventsFromYear(
              year: SharedPrefsService().currentTimelineYearNotifier.value);
    } else {}
    _instance.notifyListeners();
  }

  static void refreshYearList() {
    LoggerService.instance.debug("refreshYearList");
    _instance._yearsList.value = TimelineEventService.fetchYearsList();
    _instance.notifyListeners();
  }

  static void refreshEventList() {
    LoggerService.instance.debug(
        "refreshEventList ${SharedPrefsService().currentTimelineYearNotifier.value}");
    _instance._currentEventsList.value =
        TimelineEventService.fetchEventsFromYear(
            year: SharedPrefsService().currentTimelineYearNotifier.value);

    _instance.notifyListeners();
  }

  static Future<void> storeEventList(List<Event> newEvents) async {
    _instance._currentEventsList.value = Future(() => newEvents);
    _instance._yearsList.value = _instance._currentEventsList.value
        .then((value) => value.map((e) => e.dateTime.year).toSet().toList());
    _instance.notifyListeners();
  }

  static Future<void> storedNewTimelineFilterParams(
      TimelineFilterParams timelineFilterParams) async {
    await SharedPrefsService.storeTimelineFilters(timelineFilterParams);
    _instance._currentTimelineFilterParams.value = timelineFilterParams;

    _instance.notifyListeners();
  }

  static Future<void> operateFilter(
      TimelineFilterParams Function(TimelineFilterParams params) method) async {
    TimelineFilterParams timelineFilterParams =
        method(_instance._currentTimelineFilterParams.value);

    LoggerService.instance.debug(
        "${_instance._currentTimelineFilterParams.value}; to :$timelineFilterParams;");

    storedNewTimelineFilterParams(timelineFilterParams);
  }

/*
  filteredEvents = yearsList.then(
  (value) => value.contains(selectedYear.value)
  ? TimelineEventService.fetchEventsFromYear(year: selectedYear.value!)
      : TimelineEventService.fetchEventsFromYear(year: value.last),
  );*/
}
