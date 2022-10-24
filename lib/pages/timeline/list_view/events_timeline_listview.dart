import 'package:flutter/material.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/timeline_tile.dart';
import 'package:iscte_spots/services/timeline/timeline_event_service.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:timeline_tile/timeline_tile.dart';

class EventTimelineListView extends StatefulWidget {
  const EventTimelineListView({
    Key? key,
    required this.timelineYear,
    required this.handleEventSelection,
    this.events,
  }) : super(key: key);
  final int timelineYear;
  final List<Event>? events;
  final void Function(int) handleEventSelection;

  @override
  State<EventTimelineListView> createState() => _EventTimelineListViewState();
}

class _EventTimelineListViewState extends State<EventTimelineListView> {
  late Future<List<Event>> chosenTimelineList;
  final double tileOffset = 0.4;

  @override
  void initState() {
    super.initState();
    if (widget.events == null) {
      chosenTimelineList =
          TimelineEventService.fetchEventsFromYear(year: widget.timelineYear);
    } else {
      chosenTimelineList = Future(() => widget.events!
          .where((element) => element.dateTime.year == widget.timelineYear)
          .toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final LineStyle lineStyle =
        LineStyle(color: Theme.of(context).focusColor, thickness: 6);
    List<Widget> timelineTiles = [];

    return FutureBuilder<List<Event>>(
        future: chosenTimelineList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => EventTimelineTile(
                  index: index,
                  event: snapshot.data![index],
                  isFirst: index == 0,
                  isLast: index == snapshot.data!.length - 1,
                  lineStyle: lineStyle,
                  handleEventSelection: widget.handleEventSelection,
                ),
              );
            } else {
              return const Center(
                child: Text("No data"),
              );
            }
          } else {
            return LoadingWidget();
          }
        });
  }
}
