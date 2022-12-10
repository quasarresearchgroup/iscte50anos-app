import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class YearTimelineTile extends StatefulWidget {
  const YearTimelineTile({
    Key? key,
    required this.changeYearFunction,
    required this.year,
    required this.isFirst,
    required this.isLast,
    required this.isSelected,
    required this.isHover,
  }) : super(key: key);

  final Function changeYearFunction;
  final int year;
  final bool isFirst;
  final bool isLast;
  final bool isSelected;
  final bool isHover;

  @override
  State<YearTimelineTile> createState() => _YearTimelineTileState();
}

class _YearTimelineTileState extends State<YearTimelineTile> {
  final double textFontSize = 20.0;
  final double minWidth2 = 90;
  final double radius = 15;
  //final Color color2 = Colors.white.withOpacity(0.3);
  final double timelineIconOffset = 0.7;
  late bool isHover = widget.isHover;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() => isHover = true),
      onExit: (event) => setState(() => isHover = false),
      child: GestureDetector(
        onTap: () {
          widget.changeYearFunction(widget.year);
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: widget.isHover || isHover ? IscteTheme.iscteColorSmooth : null,
          child: Container(
            constraints: BoxConstraints(minWidth: minWidth2),
            child: Center(
              child: Text(
                widget.year.toString(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: widget.isSelected ? IscteTheme.iscteColor : null,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
