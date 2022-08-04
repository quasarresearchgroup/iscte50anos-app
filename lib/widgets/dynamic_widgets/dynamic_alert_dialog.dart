import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';

class DynamicAlertDialog extends StatelessWidget {
  final List<Widget>? actions;
  final Widget? content;
  final Widget? title;

  const DynamicAlertDialog({Key? key, this.actions, this.content, this.title})
      : super(key: key);

  static showDynamicDialog({
    required BuildContext context,
    final List<Widget>? actions,
    final Widget? content,
    final Widget? title,
  }) async {
    if (PlatformService.instance.isIos) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return DynamicAlertDialog(
            actions: actions,
            content: content,
            title: title,
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return DynamicAlertDialog(
            actions: actions,
            content: content,
            title: title,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return (PlatformService.instance.isIos)
        ? CupertinoAlertDialog(
            title: title,
            content: content,
            actions: actions ?? [],
          )
        : AlertDialog(
            title: title,
            content: content,
            actions: actions,
          );
  }
}
