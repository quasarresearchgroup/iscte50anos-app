import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/list_view/events_timeline_listview.dart';
import 'package:iscte_spots/pages/timeline/list_view/year_timeline__listview.dart';

class TimeLineBody extends StatefulWidget {
  const TimeLineBody({
    Key? key,
    required this.mapdata,
    this.initialchosenYear,
  }) : super(key: key);

  final int? initialchosenYear;
  final List<Event> mapdata;

  @override
  State<TimeLineBody> createState() => _TimeLineBodyState();
}

class _TimeLineBodyState extends State<TimeLineBody> {
  int? chosenYear;
  List<int> list = [];

  void changeChosenYear(int year) {
    setState(() {
      chosenYear = year;
    });
  }

  List<int> createYearsList(List<Event> mapdata) {
    List<int> yearsList = [];
    for (Event value in mapdata) {
      int year = value.dateTime.year;
      if (!yearsList.contains(year)) {
        yearsList.add(year);
      }
    }
    yearsList.sort();
    return yearsList;
  }

  @override
  void initState() {
    list = createYearsList(widget.mapdata);
    chosenYear = widget.initialchosenYear ?? (list.length > 1 ? list.first : 0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)?.timelineNothingFound ?? ""),
      );
    } else {
      return Column(children: [
        Container(
          height: 100,
          decoration: const BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 15.0,
            )
          ]),
          child: YearTimelineListView(
            yearsList: list,
            changeYearFunction: changeChosenYear,
            selectedYear: chosenYear ?? list.last,
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: EventTimelineListView(
              key: UniqueKey(),
              timeLineMap: widget.mapdata,
              timelineYear: chosenYear!,
            ),
          ),
        ),
      ]);
    }
  }
}
