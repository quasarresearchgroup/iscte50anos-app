import 'package:flutter/material.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/events/timeline_tile.dart';
import 'package:iscte_spots/pages/timeline/state/timeline_state.dart';
import 'package:iscte_spots/pages/timeline/web_scroll_behaviour.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class EventTimelineListViewBuilder extends StatefulWidget {
  const EventTimelineListViewBuilder({
    Key? key,
    required this.handleEventSelection,
    required this.hoveredEventIndex,
  }) : super(key: key);
  final void Function(int) handleEventSelection;
  final ValueNotifier<int?> hoveredEventIndex;

  @override
  State<EventTimelineListViewBuilder> createState() =>
      _EventTimelineListViewBuilderState();
}

class _EventTimelineListViewBuilderState
    extends State<EventTimelineListViewBuilder> {
  //late Future<List<Event>> currentEvents;

  @override
  void initState() {
    super.initState();
    //currentEvents = Future(() => widget.events
    //    .where((element) => element.dateTime.year == widget.timelineYear.value)
    //    .toList());
  }

  List<int> eventsTimelineTileGenerator({required List<Event> eventsList}) {
    List<List<Event>> newList = [[]];
    Event storedObj = eventsList.first;
    for (Event item in eventsList) {
      if (storedObj.scope != item.scope) {
        newList.add([item]);
        storedObj = item;
      } else {
        newList.last.add(item);
      }
    }
    Logger().d(newList.map((e) => e.map((e) => e.scope)).toList());
    List<int> result = [];
    for (List<Event> innerList in newList) {
      for (int i = 0; i < innerList.length; i++) {
        if (i == 0) {
          result.add(0);
        } else if (i == innerList.length - 1) {
          result.add(2);
        } else {
          result.add(1);
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
        //future: currentEvents,
        future: TimelineState.instance.currentEventsList,
        builder: (context, snapshot) {
          if (snapshot.data != null && snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              List<int> positionData =
                  eventsTimelineTileGenerator(eventsList: snapshot.data!);
              return ValueListenableBuilder<int?>(
                  valueListenable: widget.hoveredEventIndex,
                  builder: (context, value, _) {
                    return ScrollConfiguration(
                      behavior: WebScrollBehaviour(),
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) => EventTimelineTile(
                          isFirst: positionData[index] == 0,
                          isLast: positionData[index] == 2,
                          event: snapshot.data![index],
                          index: index,
                          handleEventSelection: widget.handleEventSelection,
                          isSelected: value == index,
                        ),
                      ),
                    );
                  });
            } else {
              return const Center(
                child: Text("No data"),
              );
            }
          } else {
            return const LoadingWidget();
          }
        });
  }
}

class EventTimelineListView extends StatelessWidget {
  const EventTimelineListView({
    Key? key,
    required this.data,
    required this.handleEventSelection,
    required this.selectedEventIndex,
  }) : super(key: key);

  final List<Event> data;
  final void Function(int) handleEventSelection;
  final ValueNotifier<int?> selectedEventIndex;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
        valueListenable: selectedEventIndex,
        builder: (context, value, _) {
          return ScrollConfiguration(
            behavior: WebScrollBehaviour(),
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => EventTimelineTile(
                index: index,
                event: data[index],
                isFirst: index == 0,
                isLast: index == data.length - 1,
                handleEventSelection: handleEventSelection,
                isSelected: index == value,
              ),
            ),
          );
        });
  }
}
