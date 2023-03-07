import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/events/events_timeline_listview.dart';
import 'package:iscte_spots/pages/timeline/list_view/intents.dart';
import 'package:iscte_spots/pages/timeline/list_view/year_timeline__listview.dart';
import 'package:iscte_spots/pages/timeline/state/timeline_filter_result_state.dart';
import 'package:iscte_spots/pages/timeline/state/timeline_state.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

import '../../services/logging/LoggerService.dart';
import 'details/timeline_details_page.dart';

class TimeLineBodyBuilder extends StatelessWidget {
  const TimeLineBodyBuilder({
    Key? key,
    required this.isFilterTimeline,
  }) : super(key: key);

  final bool isFilterTimeline;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: TimelineBody(
          isFilterTimeline: isFilterTimeline,
        ));
  }
}

class TimelineBody extends StatelessWidget {
  TimelineBody({
    Key? key,
    required this.isFilterTimeline,
  }) : super(key: key);

  ///Bool variable for determining which state object to be called down the widget tree: TimelineState or TimelineFilterResultsState
  final bool isFilterTimeline;

  final ValueNotifier<int?> hoveredEventIndex = ValueNotifier(null);
  final ValueNotifier<int?> hoveredYearIndexNotifier = ValueNotifier(null);
  int? lastYearIndex;

  void navigateToEvent(int eventId, BuildContext context) {
    Navigator.of(context)
        .pushNamed(TimeLineDetailsPage.pageRoute, arguments: eventId);
    LoggerService.instance.debug("handleEventSelection");
  }

  void handleEnterEvent(
      List<Event> eventsList, List<int> yearsList, BuildContext context) {
    assert((hoveredEventIndex.value == null &&
            hoveredYearIndexNotifier.value != null) ||
        (hoveredEventIndex.value != null &&
            hoveredYearIndexNotifier.value == null));
    if (hoveredEventIndex.value != null) {
      Event selectedEvent = eventsList[hoveredEventIndex.value!];
      if (selectedEvent.isVisitable) {
        navigateToEvent(selectedEvent.id, context);
      }
    } else if (hoveredYearIndexNotifier.value != null) {
      TimelineState.changeCurrentYear(
          yearsList[hoveredYearIndexNotifier.value!]);
    }
    LoggerService.instance.info(
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
      valueListenable: isFilterTimeline
          ? TimelineFilterResultState.eventsList
          : TimelineState.eventsList,
      builder: (context, currentEventsListValue, child) =>
          FutureBuilder<List<Event>>(
        future: currentEventsListValue,
        builder: (context, eventsListSnapshot) {
          if (eventsListSnapshot.hasData) {
            return ValueListenableBuilder<Future<List<int>>>(
              valueListenable: isFilterTimeline
                  ? TimelineFilterResultState.yearsList
                  : TimelineState.yearsList,
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
                                LoggerService.instance
                                    .info("IncrementYearsIntent");
                                changeHoveredYear(true, yearListSnapshot.data!);
                                return null;
                              },
                            ),
                            DecrementYearsIntent:
                                CallbackAction<DecrementYearsIntent>(
                              onInvoke: (DecrementYearsIntent intent) {
                                LoggerService.instance
                                    .info("DecrementYearsIntent");
                                changeHoveredYear(
                                    false, yearListSnapshot.data!);
                                return null;
                              },
                            ),
                            IncrementEventsIntent:
                                CallbackAction<IncrementEventsIntent>(
                              onInvoke: (IncrementEventsIntent intent) {
                                LoggerService.instance
                                    .info("IncrementEventsIntent");
                                changeHoveredEvent(
                                    true, eventsListSnapshot.data!);
                                return null;
                              },
                            ),
                            DecrementEventsIntent:
                                CallbackAction<DecrementEventsIntent>(
                              onInvoke: (DecrementEventsIntent intent) {
                                LoggerService.instance
                                    .info("DecrementEventsIntent");
                                changeHoveredEvent(
                                    false, eventsListSnapshot.data!);
                                return null;
                              },
                            ),
                            EnterIntent: CallbackAction<EnterIntent>(
                                onInvoke: (EnterIntent intent) =>
                                    handleEnterEvent(eventsListSnapshot.data!,
                                        yearListSnapshot.data!, context)),
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
                                        currentYearsListValue:
                                            currentYearsListValue,
                                        onTap: isFilterTimeline
                                            ? TimelineFilterResultState
                                                .changeCurrentYear
                                            : TimelineState.changeCurrentYear,
                                        isFilter: isFilterTimeline,
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
                                        eventsList: currentEventsListValue,
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      );
                    } else if (yearListSnapshot.hasError) {
                      return DynamicErrorWidget(
                          display: yearListSnapshot.error.toString());
                    } else {
                      return const LoadingWidget();
                    }
                  }),
            );
          } else if (eventsListSnapshot.hasError) {
            return DynamicErrorWidget(
                display: eventsListSnapshot.error.toString());
          } else {
            return const LoadingWidget();
          }
        },
      ),
    );
  }
}
