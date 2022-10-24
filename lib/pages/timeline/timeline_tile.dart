import 'package:flutter/material.dart';
import 'package:iscte_spots/helper/datetime_extension.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:timeline_tile/timeline_tile.dart';

class EventTimelineTile extends StatefulWidget {
  const EventTimelineTile({
    Key? key,
    required this.lineStyle,
    required this.isFirst,
    required this.isLast,
    required this.event,
    required this.index,
    required this.handleEventSelection,
  }) : super(key: key);

  final int index;

  final bool isFirst;
  final bool isLast;
  final Event event;
  final LineStyle lineStyle;
  final void Function(int) handleEventSelection;

  @override
  State<EventTimelineTile> createState() => _EventTimelineTileState();
}

class _EventTimelineTileState extends State<EventTimelineTile> {
  final Color color2 = Colors.white.withOpacity(0.3);
  late bool isEven = widget.index % 2 == 0;
  final int flagFlex = 35;
  final int informationFlex = 85;
  final int dateFlex = 10;
  late Color? informationChildTextColor = !isEven
      ? Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black
      : Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black;
  late Color? dateChildTextColor = !isEven
      ? Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black
      : Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

  @override
  void initState() {
    super.initState();
  }

  Widget sizedBox = const SizedBox(
    width: 10,
  );

  Widget verticalConnector = Expanded(
    child: Container(
      width: 5,
      color: Colors.white,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: InkWell(
        onTap: widget.event.contentCount > 0
            ? () {
                widget.handleEventSelection(widget.event.id);
              }
            : null,
        child: Card(
          margin: EdgeInsets.zero,
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (widget.event.scopeIcon != null)
                Flexible(
                    flex: flagFlex,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: widget.event.scopeIcon!,
                    )),
              Flexible(
                flex: dateFlex,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    !widget.isFirst ? verticalConnector : const Spacer(),
                    EventTimelineIndicator(
                        isEven: isEven,
                        event: widget.event,
                        textColor: dateChildTextColor),
                    !widget.isLast ? verticalConnector : const Spacer(),
                  ],
                ),
              ),
              Expanded(
                flex: informationFlex,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TimelineInformationChild(
                      isEven: isEven,
                      data: widget.event,
                      textColor: informationChildTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventTimelineIndicator extends StatelessWidget {
  const EventTimelineIndicator({
    Key? key,
    required this.isEven,
    required this.event,
    this.textColor,
  }) : super(key: key);

  final bool isEven;
  final Event event;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isEven ? Colors.transparent : Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              event.dateTime.monthName(),
              style: TextStyle(
                color: textColor,
              ),
              textScaleFactor: 1,
              maxLines: 1,
            ),
            Text(
              event.dateTime.day.toString(),
              style: TextStyle(
                color: textColor,
              ),
            ),
          ],
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
    this.textColor,
  }) : super(key: key);

  final bool isEven;
  final Event data;
  final double padding = 10;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: !isEven ? Colors.transparent : Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                data.title,
                maxLines: 3,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textColor),
                //fontSize: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (data.contentCount > 0)
                  Icon(
                    Icons.adaptive.arrow_forward,
                    color: textColor,
                  ),
                if (data.contentCount > 0)
                  data.visited
                      ? Icon(Icons.check, color: textColor)
                      //? const Icon(Icons.check, color: Colors.lightGreenAccent)
                      : Container(),
                if (data.contentCount > 0)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                      "#${data.contentCount.toString()}",
                      style: TextStyle(color: textColor),
                    )),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
