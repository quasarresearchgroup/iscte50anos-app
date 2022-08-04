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
    final bool barrierDismissible = true,
    final String? barrierLabel,
    //defaults to true
    bool useRootNavigator = true,
  }) async {
    if (PlatformService.instance.isIos) {
      showCupertinoDialog(
        useRootNavigator: useRootNavigator,
        context: context,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
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
        useRootNavigator: useRootNavigator,
        context: context,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
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
