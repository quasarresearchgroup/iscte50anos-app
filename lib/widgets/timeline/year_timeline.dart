import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';

class YearTimeline extends StatefulWidget {
  const YearTimeline(
      {Key? key,
      required this.changeYearFunction,
      required this.yearsList,
      required this.lineStyle,
      required this.selectedYear})
      : super(key: key);

  final Function changeYearFunction;
  final List<int> yearsList;
  final LineStyle lineStyle;
  final int? selectedYear;

  @override
  State<YearTimeline> createState() => _YearTimelineState();
}

class _YearTimelineState extends State<YearTimeline> {
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
                isSelected: widget.selectedYear == widget.yearsList[index],
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
      required this.lineStyle,
      required this.isSelected})
      : super(key: key);

  final Function changeYearFunction;
  final LineStyle lineStyle;
  final int year;
  final bool isFirst;
  final bool isLast;
  final bool isSelected;

  @override
  State<YearTimelineTile> createState() => _YearTimelineTileState();
}

class _YearTimelineTileState extends State<YearTimelineTile> {
  @override
  Widget build(BuildContext context) {
    const double textFontSize = 20.0;
    const double textPadding = 30.0;
    const double iconEdgeInsets = 8.0;
    const double minWidth2 = 90;
    const double radius = 15;
    final Color color2 = Colors.white.withOpacity(0.3);
    const double timelineIconOffset = 0.7;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: color2,
        highlightColor: color2,
        enableFeedback: true,
        customBorder: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius))),
        onTap: () {
          setState(() {
            widget.changeYearFunction(widget.year);
          });
        },
        child: TimelineTile(
          beforeLineStyle: widget.lineStyle,
          afterLineStyle: widget.lineStyle,
          axis: TimelineAxis.horizontal,
          alignment: TimelineAlign.manual,
          lineXY: timelineIconOffset,
          isFirst: widget.isFirst,
          isLast: widget.isLast,
          hasIndicator: true,
          indicatorStyle: IndicatorStyle(
            drawGap: true,
            indicator: Center(
                child: widget.isSelected
                    ? const Icon(FontAwesomeIcons.calendarCheck)
                    : const Icon(FontAwesomeIcons.calendar)),
          ),
          startChild: Container(
            constraints: const BoxConstraints(minWidth: minWidth2),
            child: Center(
              child: Text(
                widget.year.toString(),
                style: const TextStyle(fontSize: textFontSize),
              ),
            ),
          ),
          //),
        ),
      ),
    );
  }
}
