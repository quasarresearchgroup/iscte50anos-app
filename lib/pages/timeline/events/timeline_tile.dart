import 'package:flutter/material.dart';
import 'package:iscte_spots/models/timeline/event.dart';
import 'package:iscte_spots/pages/timeline/events/event_timeline_indicator.dart';
import 'package:iscte_spots/pages/timeline/events/inverd_T_clipper.dart';
import 'package:iscte_spots/pages/timeline/events/timeline_information_child.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class EventTimelineTile extends StatefulWidget {
  EventTimelineTile({
    Key? key,
    required this.isFirst,
    required this.isLast,
    required this.event,
    required this.index,
    required this.handleEventSelection,
    required this.isSelected,
  }) : super(key: key);

  /// Index for isEven production
  final int index;

  ///isFirst : Bool used for different display of tile
  final bool isFirst;

  ///isLast : Bool used for different display of tile
  final bool isLast;

  /// isSelected bool for coloring
  final bool isSelected;

  /// Event that the tile is going to display
  final Event event;

  ///Function for handling what hapens when this event/tile is selected, should navigate to a screen showing details on the event
  final void Function(int) handleEventSelection;

  @override
  State<EventTimelineTile> createState() => _EventTimelineTileState();
}

class _EventTimelineTileState extends State<EventTimelineTile> {
  final Color color2 = Colors.white.withOpacity(0.3);

  late bool isEven = widget.index % 2 == 0;

  static const int flagFlex = 15;
  static const int informationFlex = 85;
  static const int dateFlex = 10;
  static const int totalFlex = flagFlex + informationFlex + dateFlex;
  static const double separatorWidth = 2;

  late bool isHover = widget.isSelected;
  final int widthEventScopeThreshold = 500;
  final int widthDateThreshold = 400;
  @override
  Widget build(BuildContext context) {
    late Color? informationChildTextColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black;
    return GestureDetector(
      onTap: widget.event.contentCount > 0
          ? () {
              widget.handleEventSelection(widget.event.id);
            }
          : null,
      child: MouseRegion(
        cursor: widget.event.isVisitable
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (event) => setState(() => isHover = true),
        onExit: (event) => setState(() => isHover = false),
        child: SizedBox(
          height: 100,
          child: Card(
            margin: EdgeInsets.zero,
            color: widget.isSelected || isHover
                ? IscteTheme.iscteColorSmooth
                : isEven
                    ? IscteTheme.greyColor
                    : null,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.event.scopeIcon != null &&
                    MediaQuery.of(context).size.width >
                        widthEventScopeThreshold)
                  Flexible(
                    flex: flagFlex,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width *
                          (flagFlex / totalFlex),
                      child: widget.isFirst
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: widget.event.scopeIcon!,
                            )
                          : widget.isLast
                              ? Center(
                                  child: ClipPath(
                                    clipper:
                                        InvertedTClipper(width: separatorWidth),
                                    child: Container(
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: SizedBox(
                                    width: separatorWidth,
                                    child: Container(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                    ),
                  ),
                if (widget.event.scopeIcon != null &&
                    MediaQuery.of(context).size.width > widthDateThreshold)
                  Flexible(
                    flex: dateFlex,
                    child: EventTimelineIndicator(
                      isEven: isEven,
                      time: widget.event.dateTime,
                      textColor: informationChildTextColor,
                      isFirst: widget.isFirst,
                      isLast: widget.isLast,
                    ),
                  ),
                Expanded(
                  flex: informationFlex,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TimelineInformationChild(
                      isEven: isEven,
                      data: widget.event,
                      //textColor: informationChildTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
