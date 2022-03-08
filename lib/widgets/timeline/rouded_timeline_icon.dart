import 'package:flutter/material.dart';

class roundedTimelineIcon extends StatelessWidget {
  roundedTimelineIcon({
    Key? key,
    required this.child,
  }) : super(key: key);

  final double borderRadious = 10;
  final double padding = 10;
  final Image child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadious), child: child),
    );
  }
}
