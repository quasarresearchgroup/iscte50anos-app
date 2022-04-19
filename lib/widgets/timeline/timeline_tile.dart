import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/widgets/timeline/timeline_details_page.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../models/content.dart';

class EventTimelineTile extends StatelessWidget {
  EventTimelineTile({
    Key? key,
    required this.lineStyle,
    required this.isFirst,
    required this.isLast,
    required this.data,
  }) : super(key: key);

  final bool isFirst;
  final bool isLast;
  final Content data;
  final LineStyle lineStyle;
  final Color color2 = Colors.white.withOpacity(0.3);

  Route _createRoute() {
    return PageRouteBuilder(
      maintainState: true,
      pageBuilder: (context, animation, secondaryAnimation) =>
          TimeLineDetailsPage(
        data: data,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.ease));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: color2,
      highlightColor: color2,
      enableFeedback: true,
      customBorder: const StadiumBorder(),
      onTap: () => Navigator.push(context, _createRoute()),
      child: TimelineTile(
        beforeLineStyle: lineStyle,
        afterLineStyle: lineStyle,
        axis: TimelineAxis.vertical,
        alignment: TimelineAlign.manual,
        lineXY: 0.20,
        isFirst: isFirst,
        isLast: isLast,
        indicatorStyle: IndicatorStyle(
          width: 25,
          height: 25,
          padding: const EdgeInsets.symmetric(vertical: 8),
          drawGap: true,
          indicator: Center(
            child: data.contentIcon,
          ),
        ),
        endChild: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.getDateString()),
                    data.description != null
                        ? Text(
                            data.description!,
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
        startChild: Center(child: data.scopeIcon),
      ),
    );
  }
}
