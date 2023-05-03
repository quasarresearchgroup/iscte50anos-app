import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';

import '../util/iscte_theme.dart';

class DynamicLoadingWidget extends StatelessWidget {
  const DynamicLoadingWidget({
    Key? key,
    this.messagesStyle = const TextStyle(),
    this.color = IscteTheme.iscteColor,
    this.valueColor,
    this.progress,
    this.strokeWidth = 3,
  }) : super(key: key);

  final TextStyle messagesStyle;
  final Color color;
  final double? progress;
  final Animation<Color?>? valueColor;
  final double strokeWidth;
  @override
  Widget build(BuildContext context) {
    if (!PlatformService.instance.isIos) {
      return Center(
        child: progress != null
            ? TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                tween: Tween<double>(
                  begin: 0,
                  end: progress,
                ),
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value,
                  color: color,
                  strokeWidth: strokeWidth,
                  valueColor: valueColor,
                ),
              )
            : CircularProgressIndicator(
                color: color,
                strokeWidth: strokeWidth,
                valueColor: valueColor,
              ),
      );
    } else {
      return CupertinoActivityIndicator(color: color);
    }
  }
}
