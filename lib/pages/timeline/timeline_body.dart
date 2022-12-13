import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/events/events_timeline_listview.dart';
import 'package:iscte_spots/pages/timeline/list_view/intents.dart';
import 'package:iscte_spots/pages/timeline/list_view/year_timeline__listview.dart';
import 'package:iscte_spots/pages/timeline/state/timeline_state.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

import '../../services/logging/LoggerService.dart';
import 'details/timeline_details_page.dart';

class TimeLineBodyBuilder extends StatefulWidget {
  const TimeLineBodyBuilder({
    Key? key,
    required this.isFilterTimeline,
  }) : super(key: key);

  final bool isFilterTimeline;

  @override
  State<TimeLineBodyBuilder> createState() => _TimeLineBodyBuilderState();
}

class _TimeLineBodyBuilderState extends State<TimeLineBodyBuilder> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ValueListenableBuilder(
        valueListenable: TimelineState.yearsList,
        builder: (BuildContext context, Future<List<int>> currentYearsListValue,
                Widget? child) =>
            FutureBuilder<List<int>>(
          future: currentYearsListValue,
          builder:
              (BuildContext context, AsyncSnapshot<List<int>> yearsSnapshot) {
            if (yearsSnapshot.hasData) {
              if (yearsSnapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                      AppLocalizations.of(context)?.timelineNothingFound ??
                          "timelineNothingFound"),
                );
              } else {
                return ValueListenableBuilder<Future<List<Event>>>(
                  valueListenable: TimelineState.currentEventsList,
                  builder: (context, Future<List<Event>> future, child) =>
                      FutureBuilder<List<Event>>(
                          future: future,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Event>> eventsSnapshot) {
                            if (eventsSnapshot.hasData) {
                              return const TimelineBody();
                            } else if (eventsSnapshot.hasError) {
                              return const NetworkError(
                                display: "Error on eventsSnapshot", //TODO
                                onRefresh: TimelineState.refreshEventList,
                              );
                            } else {
                              return const LoadingWidget();
                            }
                          }),
                );
              }
            } else if (yearsSnapshot.connectionState != ConnectionState.done) {
              return const LoadingWidget();
            } else if (yearsSnapshot.hasError) {
              return const NetworkError(
                display: "Error on yearsSnapshot", //TODO
                onRefresh: TimelineState.refreshYearList,
              );
            } else {
              return const LoadingWidget();
            }
          },
        ),
      ),
    );
  }
}

class TimelineBody extends StatefulWidget {
  const TimelineBody({
    Key? key,
  }) : super(key: key);

  @override
  State<TimelineBody> createState() => _TimelineBodyState();
}

class _TimelineBodyState extends State<TimelineBody> {
  ValueNotifier<int?> hoveredEventIndex = ValueNotifier(null);
  ValueNotifier<int?> hoveredYearIndexNotifier = ValueNotifier(null);
  int? lastYearIndex;

  void navigateToEvent(int eventId) {
    Navigator.of(context)
        .pushNamed(TimeLineDetailsPage.pageRoute, arguments: eventId);
    LoggerService.instance.debug("handleEventSelection");
  }

  void handleEnterEvent(List<Event> eventsList, List<int> yearsList) {
    assert((hoveredEventIndex.value == null &&
            hoveredYearIndexNotifier.value != null) ||
        (hoveredEventIndex.value != null &&
            hoveredYearIndexNotifier.value == null));
    if (hoveredEventIndex.value != null) {
      Event selectedEvent = eventsList[hoveredEventIndex.value!];
      if (selectedEvent.isVisitable) {
        navigateToEvent(selectedEvent.id);
      }
    } else if (hoveredYearIndexNotifier.value != null) {
      TimelineState.changeCurrentYear(
          yearsList[hoveredYearIndexNotifier.value!]);
    }
    Logger().i(
        "selectedEventIndex: ${hoveredEventIndex.value} ; selectedYearIndex: ${hoveredYearIndexNotifier.value}");
  }

  void changeHoveredEvent(bool increase, List<Event> eventsList) {
    Logger()
        .i("increase: $increase ; widget.filteredEvents?.length $eventsList");

    int index = hoveredEventIndex.value != null
        ? increase
            ? hoveredEventIndex.value! + 1
            : hoveredEventIndex.value! - 1
        : 0;
    if (index >= 0 && index < eventsList.length) {
      hoveredEventIndex.value = index;
      hoveredYearIndexNotifier.value = null;
    }
  }

  void changeHoveredYear(bool increase, List<int> yearsList) {
    int index = hoveredYearIndexNotifier.value != null
        ? increase
            ? hoveredYearIndexNotifier.value! + 1
            : hoveredYearIndexNotifier.value! - 1
        : lastYearIndex ?? yearsList.indexOf(hoveredYearIndexNotifier.value!);

    if (index >= 0 && index < yearsList.length) {
      hoveredYearIndexNotifier.value = index;
      lastYearIndex = index;
      hoveredEventIndex.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Future<List<Event>>>(
      valueListenable: TimelineState.currentEventsList,
      builder: (context, currentEventsListValue, child) =>
          FutureBuilder<List<Event>>(
        future: currentEventsListValue,
        builder: (context, eventsListSnapshot) {
          if (eventsListSnapshot.hasData) {
            return ValueListenableBuilder<Future<List<int>>>(
              valueListenable: TimelineState.yearsList,
              builder: (context, currentYearsListValue, child) => FutureBuilder<
                      List<int>>(
                  future: currentYearsListValue,
                  builder: (context, yearListSnapshot) {
                    if (yearListSnapshot.hasData) {
                      return Shortcuts(
                        shortcuts: const <ShortcutActivator, Intent>{
                          SingleActivator(LogicalKeyboardKey.arrowRight,
                              includeRepeats: true): IncrementYearsIntent(),
                          SingleActivator(LogicalKeyboardKey.arrowLeft,
                              includeRepeats: true): DecrementYearsIntent(),
                          SingleActivator(LogicalKeyboardKey.arrowDown,
                              includeRepeats: true): IncrementEventsIntent(),
                          SingleActivator(LogicalKeyboardKey.arrowUp,
                              includeRepeats: true): DecrementEventsIntent(),
                          SingleActivator(LogicalKeyboardKey.enter):
                              EnterIntent(),
                          SingleActivator(LogicalKeyboardKey.numpadEnter):
                              EnterIntent(),
                          SingleActivator(LogicalKeyboardKey.space):
                              EnterIntent(),
                          SingleActivator(LogicalKeyboardKey.escape):
                              EscapeIntent(),
                        },
                        child: Actions(
                          actions: <Type, Action<Intent>>{
                            IncrementYearsIntent:
                                CallbackAction<IncrementYearsIntent>(
                              onInvoke: (IncrementYearsIntent intent) {
                                Logger().i("IncrementYearsIntent");
                                changeHoveredYear(true, yearListSnapshot.data!);
                                return null;
                              },
                            ),
                            DecrementYearsIntent:
                                CallbackAction<DecrementYearsIntent>(
                              onInvoke: (DecrementYearsIntent intent) {
                                Logger().i("DecrementYearsIntent");
                                changeHoveredYear(
                                    false, yearListSnapshot.data!);
                                return null;
                              },
                            ),
                            IncrementEventsIntent:
                                CallbackAction<IncrementEventsIntent>(
                              onInvoke: (IncrementEventsIntent intent) {
                                Logger().i("IncrementEventsIntent");
                                changeHoveredEvent(
                                    true, eventsListSnapshot.data!);
                                return null;
                              },
                            ),
                            DecrementEventsIntent:
                                CallbackAction<DecrementEventsIntent>(
                              onInvoke: (DecrementEventsIntent intent) {
                                Logger().i("DecrementEventsIntent");
                                changeHoveredEvent(
                                    false, eventsListSnapshot.data!);
                                return null;
                              },
                            ),
                            EnterIntent: CallbackAction<EnterIntent>(
                                onInvoke: (EnterIntent intent) =>
                                    handleEnterEvent(eventsListSnapshot.data!,
                                        yearListSnapshot.data!)),
                            EscapeIntent: CallbackAction<EscapeIntent>(
                              onInvoke: (EscapeIntent intent) {
                                hoveredYearIndexNotifier.value = null;
                                hoveredEventIndex.value = null;
                                return null;
                              },
                            ),
                          },
                          child: Focus(
                            autofocus: true,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Listener(
                                    onPointerSignal:
                                        (PointerSignalEvent event) {
                                      if (event is PointerScrollEvent) {
                                        changeHoveredYear(
                                            event.scrollDelta.direction > 0,
                                            yearListSnapshot.data!);
                                      }
                                    },
                                    child: SizedBox(
                                      height: kToolbarHeight,
                                      child: YearTimelineListView(
                                        hoveredYearIndexNotifier:
                                            hoveredYearIndexNotifier,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: EventTimelineListViewBuilder(
                                        key: UniqueKey(),
                                        handleEventSelection: navigateToEvent,
                                        hoveredEventIndex: hoveredEventIndex,
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      );
                    } else if (yearListSnapshot.hasError) {
                      return NetworkError(
                          display: yearListSnapshot.error.toString());
                    } else {
                      return const LoadingWidget();
                    }
                  }),
            );
          } else if (eventsListSnapshot.hasError) {
            return NetworkError(display: eventsListSnapshot.error.toString());
          } else {
            return const LoadingWidget();
          }
        },
      ),
    );
  }
}
