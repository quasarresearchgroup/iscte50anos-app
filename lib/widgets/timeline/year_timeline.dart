import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class YearTimeline extends StatefulWidget {
  const YearTimeline(
      {Key? key,
      required this.changeYearFunction,
      required this.yearsList,
      required this.lineStyle})
      : super(key: key);

  final Function changeYearFunction;
  final List<int> yearsList;
  final LineStyle lineStyle;

  @override
  State<YearTimeline> createState() => _YearTimelineState();
}

class _YearTimelineState extends State<YearTimeline> {
  int year = 1972;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightBlue,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.yearsList.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return YearTimelineTile(
                changeYearFunction: widget.changeYearFunction,
                lineStyle: widget.lineStyle,
                year: widget.yearsList[index],
                isFirst: index == 0,
                isLast: index == widget.yearsList.length - 1);
          }),
    );
  }
}

class YearTimelineTile extends StatefulWidget {
  const YearTimelineTile(
      {Key? key,
      required this.changeYearFunction,
      required this.year,
      required this.isFirst,
      required this.isLast,
      required this.lineStyle})
      : super(key: key);

  final Function changeYearFunction;
  final LineStyle lineStyle;
  final int year;
  final bool isFirst;
  final bool isLast;

  @override
  State<YearTimelineTile> createState() => _YearTimelineTileState();
}

class _YearTimelineTileState extends State<YearTimelineTile> {
  @override
  Widget build(BuildContext context) {
    const double textFontSize = 20.0;
    const double textPadding = 30.0;
    const double iconEdgeInsets = 8.0;
    final Color color2 = Colors.white.withOpacity(0.3);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: color2,
        highlightColor: color2,
        enableFeedback: true,
        customBorder: const StadiumBorder(),
        onTap: () {
          setState(() {
            widget.changeYearFunction(widget.year);
          });
        },
        child: TimelineTile(
          indicatorStyle: const IndicatorStyle(
            padding: EdgeInsets.all(iconEdgeInsets),
            drawGap: true,
            indicator: Center(child: Icon(Icons.calendar_today)),
          ),
          beforeLineStyle: widget.lineStyle,
          afterLineStyle: widget.lineStyle,
          axis: TimelineAxis.horizontal,
          alignment: TimelineAlign.center,
          isFirst: widget.isFirst,
          isLast: widget.isLast,
          hasIndicator: true,
          startChild: Padding(
            padding: const EdgeInsets.only(top: textPadding),
            child: Text(
              widget.year.toString(),
              style: const TextStyle(fontSize: textFontSize),
            ),
          ),
        ),
      ),
    );
  }
}
