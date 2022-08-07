import 'package:flutter/material.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/timeline_details_page.dart';
import 'package:timeline_tile/timeline_tile.dart';

class EventTimelineTile extends StatefulWidget {
  const EventTimelineTile({
    Key? key,
    required this.lineStyle,
    required this.isFirst,
    required this.isLast,
    required this.data,
    required this.isEven,
    required this.index,
  }) : super(key: key);

  final int index;
  final bool isFirst;
  final bool isLast;
  final bool isEven;
  final Event data;
  final LineStyle lineStyle;

  @override
  State<EventTimelineTile> createState() => _EventTimelineTileState();
}

class _EventTimelineTileState extends State<EventTimelineTile> {
  final Color color2 = Colors.white.withOpacity(0.3);
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(milliseconds: 100 * (widget.index + 1)),
      () {
        setState(() {
          opacity = 1;
        });
      },
    ).onError((error, stackTrace) => null);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: opacity,
      child: InkWell(
        splashColor: color2,
        highlightColor: color2,
        enableFeedback: true,
        customBorder: const StadiumBorder(),
        onTap: () => Navigator.pushNamed(
          context,
          TimeLineDetailsPage.pageRoute,
          arguments: widget.data,
        ),
        child: TimelineTile(
          beforeLineStyle: widget.lineStyle,
          afterLineStyle: widget.lineStyle,
          axis: TimelineAxis.vertical,
          alignment: TimelineAlign.manual,
          lineXY: 0.30,
          isFirst: widget.isFirst,
          isLast: widget.isLast,
          indicatorStyle: IndicatorStyle(
            width: 25,
            height: 25,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            drawGap: true,
            indicator: Center(
              child: widget.data.scopeIcon,
            ),
          ),
          endChild: TimelineInformationChild(
              isEven: widget.isEven, data: widget.data),
          startChild: Center(child: widget.data.scopeIcon),
        ),
      ),
    );
  }
}

class TimelineInformationChild extends StatelessWidget {
  const TimelineInformationChild({
    Key? key,
    required this.isEven,
    required this.data,
  }) : super(key: key);

  final bool isEven;
  final Event data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: isEven
                ? Colors.transparent
                : Theme.of(context).primaryColor.withAlpha(200),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.getDateString()),
                    data.title != null
                        ? Text(
                            data.title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Container(),
                  ],
                ),
              ),
              Icon(Icons.adaptive.arrow_forward)
            ],
          ),
        ),
      ),
    );
  }
}
