import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/events/events_timeline_listview.dart';
import 'package:iscte_spots/pages/timeline/list_view/intents.dart';
import 'package:iscte_spots/pages/timeline/list_view/year_timeline__listview.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class TimeLineBodyBuilder extends StatefulWidget {
  const TimeLineBodyBuilder({
    Key? key,
    this.selectedYear,
    required this.filteredEvents,
    required this.yearsList,
    required this.handleYearSelection,
    required this.handleEventSelection,
    required this.isFilterTimeline,
  }) : super(key: key);

  final ValueNotifier<int?>? selectedYear;
  final Future<List<int>> yearsList;
  final Future<List<Event>> filteredEvents;
  final void Function(int) handleYearSelection;
  final void Function(int) handleEventSelection;
  final bool isFilterTimeline;

  @override
  State<TimeLineBodyBuilder> createState() => _TimeLineBodyBuilderState();
}

class _TimeLineBodyBuilderState extends State<TimeLineBodyBuilder> {
  late Future<List<int>> stateYears;
  late Function(int) stateHandleYearSelection;
  late ValueNotifier<int?> stateSelectedYear;
  @override
  void initState() {
    super.initState();
    //assert(widget.filteredEvents != null && widget.yearsList == null || widget.filteredEvents == null && widget.yearsList != null);
    /*if (widget.filteredEvents != null) {
      stateYears = Future(() =>
          widget.filteredEvents!.map((e) => e.dateTime.year).toSet().toList());
    } else {
      stateYears = widget.yearsList!;
    }*/
    stateYears = widget.yearsList;
    stateSelectedYear = widget.selectedYear ?? ValueNotifier<int?>(null);

    if (widget.isFilterTimeline) {
      stateHandleYearSelection = (int year) {
        setState(() {
          stateSelectedYear.value = year;
        });
      };
    } else {
      stateHandleYearSelection = widget.handleYearSelection;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: FutureBuilder<List<int>>(
        future: stateYears,
        builder:
            (BuildContext context, AsyncSnapshot<List<int>> yearsSnapshot) {
          if (yearsSnapshot.hasData) {
            if (yearsSnapshot.data!.isEmpty) {
              return Center(
                child: Text(
                    AppLocalizations.of(context)?.timelineNothingFound ?? ""),
              );
            } else {
              return FutureBuilder<List<Event>>(
                  future: widget.filteredEvents,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Event>> eventsSnapshot) {
                    if (eventsSnapshot.hasData) {
                      return TimelineBody(
                        stateHandleYearSelection: stateHandleYearSelection,
                        currentYear: stateSelectedYear,
                        filteredEvents: eventsSnapshot.data!,
                        handleEventSelection: widget.handleEventSelection,
                        yearsList: yearsSnapshot.data!,
                      );
                    } else if (eventsSnapshot.hasError) {
                      return ErrorWidget(eventsSnapshot.error!);
                    } else {
                      return const LoadingWidget();
                    }
                  });
            }
          } else if (yearsSnapshot.connectionState != ConnectionState.done) {
            return const LoadingWidget();
          } else if (yearsSnapshot.hasError) {
            return Center(
                child: Text(AppLocalizations.of(context)!.generalError));
          } else {
            return const LoadingWidget();
          }
        },
      ),
    );
  }
}

class TimelineBody extends StatefulWidget {
  const TimelineBody({
    Key? key,
    required this.stateHandleYearSelection,
    required this.currentYear,
    required this.filteredEvents,
    required this.handleEventSelection,
    required this.yearsList,
  }) : super(key: key);

  final ValueNotifier<int?> currentYear;
  final List<Event> filteredEvents;
  final Function(int year) stateHandleYearSelection;
  final void Function(int eventId) handleEventSelection;
  final List<int> yearsList;

  @override
  State<TimelineBody> createState() => _TimelineBodyState();
}

class _TimelineBodyState extends State<TimelineBody> {
  ValueNotifier<int?> selectedEventIndex = ValueNotifier(null);
  ValueNotifier<int?> selectedYearIndex = ValueNotifier(null);
  int? lastYearIndex;

  void handleEnterEvent() {
    assert((selectedEventIndex.value == null &&
            selectedYearIndex.value != null) ||
        (selectedEventIndex.value != null && selectedYearIndex.value == null));
    if (selectedEventIndex.value != null) {
      Event selectedEvent = widget.filteredEvents[selectedEventIndex.value!];
      if (selectedEvent.isVisitable) {
        widget.handleEventSelection(selectedEvent.id);
      }
    } else if (selectedYearIndex.value != null) {
      widget
          .stateHandleYearSelection(widget.yearsList[selectedYearIndex.value!]);
    }
    Logger().i(
        "selectedEventIndex: ${selectedEventIndex.value} ; selectedYearIndex: ${selectedYearIndex.value}");
  }

  void changeSelectedEvent(bool increase) {
    Logger().i(
        "increase: $increase ; widget.filteredEvents?.length ${widget.filteredEvents}");

    int index = selectedEventIndex.value != null
        ? increase
            ? selectedEventIndex.value! + 1
            : selectedEventIndex.value! - 1
        : 0;
    if (index >= 0 && index < widget.filteredEvents.length) {
      selectedEventIndex.value = index;
      selectedYearIndex.value = null;
    }
  }

  void changeSelectedYear(bool increase) {
    int index = selectedYearIndex.value != null
        ? increase
            ? selectedYearIndex.value! + 1
            : selectedYearIndex.value! - 1
        : lastYearIndex ?? widget.yearsList.indexOf(selectedYearIndex.value!);

    if (index >= 0 && index < widget.yearsList.length) {
      selectedYearIndex.value = index;
      lastYearIndex = index;
      selectedEventIndex.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowRight, includeRepeats: true):
            IncrementYearsIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft, includeRepeats: true):
            DecrementYearsIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown, includeRepeats: true):
            IncrementEventsIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp, includeRepeats: true):
            DecrementEventsIntent(),
        SingleActivator(LogicalKeyboardKey.enter): EnterIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): EnterIntent(),
        SingleActivator(LogicalKeyboardKey.space): EnterIntent(),
        SingleActivator(LogicalKeyboardKey.escape): EscapeIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          IncrementYearsIntent: CallbackAction<IncrementYearsIntent>(
            onInvoke: (IncrementYearsIntent intent) {
              Logger().i("IncrementYearsIntent");
              changeSelectedYear(true);
            },
          ),
          DecrementYearsIntent: CallbackAction<DecrementYearsIntent>(
            onInvoke: (DecrementYearsIntent intent) {
              Logger().i("DecrementYearsIntent");
              changeSelectedYear(false);
            },
          ),
          IncrementEventsIntent: CallbackAction<IncrementEventsIntent>(
            onInvoke: (IncrementEventsIntent intent) {
              Logger().i("IncrementEventsIntent");
              changeSelectedEvent(true);
            },
          ),
          DecrementEventsIntent: CallbackAction<DecrementEventsIntent>(
            onInvoke: (DecrementEventsIntent intent) {
              Logger().i("DecrementEventsIntent");
              changeSelectedEvent(false);
            },
          ),
          EnterIntent: CallbackAction<EnterIntent>(
              onInvoke: (EnterIntent intent) => handleEnterEvent()),
          EscapeIntent: CallbackAction<EscapeIntent>(
            onInvoke: (EscapeIntent intent) {
              selectedYearIndex.value = null;
              selectedEventIndex.value = null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Listener(
              onPointerSignal: (PointerSignalEvent event) {
                if (event is PointerScrollEvent) {
                  changeSelectedYear(event.scrollDelta.direction > 0);
                }
              },
              child: SizedBox(
                height: kToolbarHeight,
                child: YearTimelineListView(
                  yearsList: widget.yearsList,
                  changeYearFunction: widget.stateHandleYearSelection,
                  currentYear: widget.currentYear,
                  selectedYearIndex: selectedYearIndex,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: EventTimelineListViewBuilder(
                  key: UniqueKey(),
                  events: widget.filteredEvents,
                  timelineYear: widget.currentYear,
                  handleEventSelection: widget.handleEventSelection,
                  selectedEventIndex: selectedEventIndex,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
