import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/events/events_timeline_listview.dart';
import 'package:iscte_spots/pages/timeline/list_view/intents.dart';
import 'package:iscte_spots/pages/timeline/list_view/year_timeline__listview.dart';
import 'package:iscte_spots/pages/timeline/state/timeline_filter_result_state.dart';
import 'package:iscte_spots/pages/timeline/state/timeline_state.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_loading_widget.dart';
import 'package:iscte_spots/widgets/network/error.dart';

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
      child: TimelineKeyboardEventWrapper(
        isFilterTimeline: isFilterTimeline,
      ),
    );
  }
}

class TimelineKeyboardEventWrapper extends StatelessWidget {
  TimelineKeyboardEventWrapper({
    Key? key,
    required this.isFilterTimeline,
  })  : hoveredEventIndexNotifier = ValueNotifier(null),
        hoveredYearIndexNotifier = ValueNotifier(null),
        super(key: key);

  ///Bool variable for determining which state object to be called down the widget tree: TimelineState or TimelineFilterResultsState
  final bool isFilterTimeline;

  final ValueNotifier<int?> hoveredEventIndexNotifier;
  final ValueNotifier<int?> hoveredYearIndexNotifier;
  int? lastYearIndex;

  void navigateToEvent(int eventId, BuildContext context) {
    Navigator.of(context)
        .pushNamed(TimeLineDetailsPage.pageRoute, arguments: eventId);
    LoggerService.instance.debug("handleEventSelection");
  }

  void handleEnterEvent(
      List<Event> eventsList, List<int> yearsList, BuildContext context) {
    assert((hoveredEventIndexNotifier.value == null &&
            hoveredYearIndexNotifier.value != null) ||
        (hoveredEventIndexNotifier.value != null &&
            hoveredYearIndexNotifier.value == null));
    if (hoveredEventIndexNotifier.value != null) {
      Event selectedEvent = eventsList[hoveredEventIndexNotifier.value!];
      if (selectedEvent.isVisitable) {
        navigateToEvent(selectedEvent.id, context);
      }
    } else if (hoveredYearIndexNotifier.value != null) {
      TimelineState.changeCurrentYear(
          yearsList[hoveredYearIndexNotifier.value!]);
    }
    LoggerService.instance.info(
        "selectedEventIndex: ${hoveredEventIndexNotifier.value} ; selectedYearIndex: ${hoveredYearIndexNotifier.value}");
  }

  void changeHoveredEvent(bool increase, List<Event> eventsList) {
    LoggerService.instance.info(
        "increase: $increase ; widget.filteredEvents?.length $eventsList");

    int index = hoveredEventIndexNotifier.value != null
        ? increase
            ? hoveredEventIndexNotifier.value! + 1
            : hoveredEventIndexNotifier.value! - 1
        : 0;
    if (index >= 0 && index < eventsList.length) {
      hoveredEventIndexNotifier.value = index;
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
      hoveredEventIndexNotifier.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Future<List<Event>>>(
      valueListenable: isFilterTimeline
          ? TimelineFilterResultState.eventsList
          : TimelineState.eventsList,
      builder: (context, currentEventsListFuture, child) =>
          FutureBuilder<List<Event>>(
        future: currentEventsListFuture,
        builder: (context, eventsListSnapshot) {
          if (eventsListSnapshot.hasData) {
            return ValueListenableBuilder<Future<List<int>>>(
              valueListenable: isFilterTimeline
                  ? TimelineFilterResultState.yearsList
                  : TimelineState.yearsList,
              builder: (context, currentYearsListValue, child) => FutureBuilder<
                      List<int>>(
                  future: currentYearsListValue,
                  builder:
                      (context, AsyncSnapshot<List<int>> yearListSnapshot) {
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
                                hoveredEventIndexNotifier.value = null;
                                return null;
                              },
                            ),
                          },
                          child: Focus(
                            autofocus: true,
                            child: TimelineBody(
                                changeHoveredYearCallback: changeHoveredYear,
                                keyboardScrollCallback:
                                    (PointerSignalEvent event) {
                                  if (event is PointerScrollEvent) {
                                    changeHoveredYear(
                                        event.scrollDelta.direction > 0,
                                        yearListSnapshot.data!);
                                  }
                                },
                                hoveredYearIndexNotifier:
                                    hoveredYearIndexNotifier,
                                yearsListFuture: currentYearsListValue,
                                isFilterTimeline: isFilterTimeline,
                                handleEventSelection: navigateToEvent,
                                hoveredEventIndexNotifier:
                                    hoveredEventIndexNotifier,
                                eventsListFuture: currentEventsListFuture,
                                changeYearCallback: isFilterTimeline
                                    ? TimelineFilterResultState
                                        .changeCurrentYear
                                    : TimelineState.changeCurrentYear,
                                currentYearNotifier: isFilterTimeline
                                    ? TimelineFilterResultState.selectedYear
                                    : TimelineState.selectedYear),
                          ),
                        ),
                      );
                    } else if (yearListSnapshot.hasError) {
                      return DynamicErrorWidget(
                          display: yearListSnapshot.error.toString());
                    } else {
                      return const DynamicLoadingWidget();
                    }
                  }),
            );
          } else if (eventsListSnapshot.hasError) {
            return DynamicErrorWidget(
                display: eventsListSnapshot.error.toString());
          } else {
            return const DynamicLoadingWidget();
          }
        },
      ),
    );
  }
}

class TimelineBody extends StatelessWidget {
  const TimelineBody({
    Key? key,
    required this.yearsListFuture,
    required this.eventsListFuture,
    required this.isFilterTimeline,
    required this.handleEventSelection,
    required this.currentYearNotifier,
    this.changeHoveredYearCallback,
    this.changeYearCallback,
    this.hoveredEventIndexNotifier,
    this.hoveredYearIndexNotifier,
    this.keyboardScrollCallback,
  }) : super(key: key);

  final void Function(bool, List<int>)? changeHoveredYearCallback;
  final void Function(PointerSignalEvent)? keyboardScrollCallback;

  final ValueNotifier<int?> currentYearNotifier;
  final ValueNotifier<int?>? hoveredYearIndexNotifier;
  final Future<List<int>> yearsListFuture;
  final void Function(int)? changeYearCallback;

  final void Function(int, BuildContext) handleEventSelection;
  final ValueNotifier<int?>? hoveredEventIndexNotifier;
  final Future<List<Event>> eventsListFuture;

  final bool isFilterTimeline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Listener(
          onPointerSignal: keyboardScrollCallback,
          child: SizedBox(
            height: kToolbarHeight,
            child: YearTimeline(
              hoveredYearIndexNotifier: hoveredYearIndexNotifier,
              currentYearsListValue: yearsListFuture,
              changeYearCallback: changeYearCallback,
              currentYearNotifier: currentYearNotifier,
              isFilter: isFilterTimeline,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: EventTimelineListViewBuilder(
              key: UniqueKey(),
              handleEventSelection: handleEventSelection,
              hoveredEventIndexNotifier: hoveredEventIndexNotifier,
              eventsList: eventsListFuture,
            ),
          ),
        ),
      ],
    );
  }
}
