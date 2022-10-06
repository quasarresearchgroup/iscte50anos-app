import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    Key? key,
    this.messagesStyle = const TextStyle(),
    this.backgroundColor,
    this.valueColor,
    this.strokeWidth = 1,
  }) : super(key: key);

  final TextStyle messagesStyle;
  final Color? backgroundColor;
  final Animation<Color?>? valueColor;
  final double strokeWidth;
  @override
  Widget build(BuildContext context) {
    if (!PlatformService.instance.isIos) {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: backgroundColor,
          strokeWidth: strokeWidth,
          valueColor: valueColor,
        ),
      );
    } else {
      return CupertinoActivityIndicator(
        color: backgroundColor,
      );
    }
  }
}
