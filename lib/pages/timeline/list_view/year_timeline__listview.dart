import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';

class YearTimelineListView extends StatefulWidget {
  const YearTimelineListView(
      {Key? key,
      required this.changeYearFunction,
      required this.yearsList,
      required this.selectedYear})
      : super(key: key);

  final Function changeYearFunction;
  final List<int> yearsList;
  final int selectedYear;

  @override
  State<YearTimelineListView> createState() => _YearTimelineListViewState();
}

class _YearTimelineListViewState extends State<YearTimelineListView> {
  //late ScrollController scrollController;
  List<Widget> yearsList = [];

  @override
  void initState() {
    super.initState();
    //scrollController = ScrollController();
/*
    for (int index in widget.yearsList) {
      yearsList.add(
        Padding(
          key: GlobalKey(),
          padding: const EdgeInsets.only(bottom: 8.0),
          child: YearTimelineTile(
            changeYearFunction: widget.changeYearFunction,
            year: index,
            isSelected: widget.selectedYear == index,
            isFirst: index == 0,
            isLast: index == widget.yearsList.length - 1,
          ),
        ),
      );
    }*/
  }

  @override
  void dispose() {
    super.dispose();
    //scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Scrollable.ensureVisible(yearsList[widget.selectedYear].);
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: ListView.builder(
          //controller: scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: widget.yearsList.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: YearTimelineTile(
                changeYearFunction: widget.changeYearFunction,
                year: widget.yearsList[index],
                isSelected: widget.selectedYear == widget.yearsList[index],
                isFirst: index == 0,
                isLast: index == widget.yearsList.length - 1,
              ),
            );
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
      required this.isSelected})
      : super(key: key);

  final Function changeYearFunction;
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
    const double minWidth2 = 90;
    const double radius = 15;
    final Color color2 = Colors.white.withOpacity(0.3);
    const double timelineIconOffset = 0.7;
    Color iconTextColor = Theme.of(context).selectedRowColor;
    LineStyle lineStyle = LineStyle(color: iconTextColor, thickness: 6);

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
          beforeLineStyle: lineStyle,
          afterLineStyle: lineStyle,
          axis: TimelineAxis.horizontal,
          alignment: TimelineAlign.manual,
          lineXY: timelineIconOffset,
          isFirst: widget.isFirst,
          isLast: widget.isLast,
          hasIndicator: true,
          indicatorStyle: IndicatorStyle(
            drawGap: true,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            indicator: Center(
                child: widget.isSelected
                    ? Icon(
                        FontAwesomeIcons.calendarCheck,
                        color: iconTextColor,
                      )
                    : Icon(
                        FontAwesomeIcons.calendar,
                        color: iconTextColor,
                      )),
          ),
          startChild: Container(
            constraints: const BoxConstraints(minWidth: minWidth2),
            child: Center(
              child: Text(
                widget.year.toString(),
                style: TextStyle(fontSize: textFontSize, color: iconTextColor),
              ),
            ),
          ),
          //),
        ),
      ),
    );
  }
}
