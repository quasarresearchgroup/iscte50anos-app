import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/events/timeline_tile.dart';
import 'package:iscte_spots/pages/timeline/web_scroll_behaviour.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/widgets/util/loading.dart';

class EventTimelineListViewBuilder extends StatefulWidget {
  const EventTimelineListViewBuilder({
    Key? key,
    this.hoveredEventIndexNotifier,
    required this.handleEventSelection,
    required this.eventsList,
  }) : super(key: key);
  final void Function(int, BuildContext) handleEventSelection;
  final ValueNotifier<int?>? hoveredEventIndexNotifier;
  final Future<List<Event>> eventsList;

  @override
  State<EventTimelineListViewBuilder> createState() =>
      _EventTimelineListViewBuilderState();
}

class _EventTimelineListViewBuilderState
    extends State<EventTimelineListViewBuilder> {
  @override
  void initState() {
    super.initState();
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
    LoggerService.instance
        .debug(newList.map((e) => e.map((e) => e.scope)).toList());
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
      future: widget.eventsList,
      builder: (context, AsyncSnapshot<List<Event>> snapshot) {
        if (snapshot.data != null && snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            List<int> positionData =
                eventsTimelineTileGenerator(eventsList: snapshot.data!);
            return widget.hoveredEventIndexNotifier != null
                ? ValueListenableBuilder<int?>(
                    valueListenable: widget.hoveredEventIndexNotifier!,
                    builder: (context, int? hoveredEventIndex, _) {
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
                            isSelected: hoveredEventIndex == index,
                          ),
                        ),
                      );
                    },
                  )
                : ScrollConfiguration(
                    behavior: WebScrollBehaviour(),
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) => EventTimelineTile(
                        isFirst: positionData[index] == 0,
                        isLast: positionData[index] == 2,
                        event: snapshot.data![index],
                        index: index,
                        handleEventSelection: widget.handleEventSelection,
                        isSelected: false,
                      ),
                    ),
                  );
          } else {
            return Center(
              child: Text(AppLocalizations.of(context)!.timelineEventNoData),
            );
          }
        } else {
          return const LoadingWidget();
        }
      },
    );
  }
}
