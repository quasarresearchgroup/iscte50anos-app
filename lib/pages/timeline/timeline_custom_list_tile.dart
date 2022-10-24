import 'package:flutter/material.dart';

class EventCustomTimelineTile extends StatelessWidget {
  EventCustomTimelineTile({
    Key? key,
    required this.isEven,
    required this.endChild,
    required this.startChild,
    required this.isFirst,
    required this.isLast,
    required this.indicator,
    this.onTap,
  }) : super(key: key);

  final bool isFirst;
  final bool isLast;
  final Widget endChild;
  final Widget indicator;
  final Widget startChild;
  final double lineXY = 0.2;

  final bool isEven;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Widget sizedBox = const SizedBox(
      width: 10,
    );
    Widget verticalConnector = Expanded(
      child: Container(
        width: 2,
        color: Colors.white.withOpacity(0.50),
      ),
    );
    return InkWell(
      onTap: onTap,
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          height: 100,
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                startChild,
                sizedBox,
                Column(
                  children: [
                    verticalConnector,
                    indicator,
                    verticalConnector,
                  ],
                ),
                sizedBox,
                endChild,
              ],
            ),
          ),
        );
      }),
    );
  }
}
