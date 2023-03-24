import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';

class DynamicAlertDialog extends StatelessWidget {
  final List<Widget>? actions;
  final Widget? content;
  final Widget? title;
  final Widget? icon;

  const DynamicAlertDialog._internal({
    Key? key,
    this.actions,
    this.content,
    this.title,
    this.icon,
  }) : super(key: key);

  static Future<void> showDynamicDialog({
    required BuildContext context,
    final List<Widget>? actions,
    final Widget? content,
    final Widget? title,
    final Widget? icon,
    final bool barrierDismissible = true,
    final String? barrierLabel,
    final Offset? anchorPoint,
    final RouteSettings? routeSettings,
    //defaults to true
    bool useRootNavigator = true,
  }) async {
    if (PlatformService.instance.isIos) {
      await showCupertinoDialog(
        useRootNavigator: useRootNavigator,
        context: context,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        anchorPoint: anchorPoint,
        routeSettings: routeSettings,
        builder: (context) => DynamicAlertDialog._internal(
          actions: actions,
          content: content,
          title: title,
          icon: icon,
        ),
      );
    } else {
      await showDialog(
        useRootNavigator: useRootNavigator,
        context: context,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        builder: (context) {
          return DynamicAlertDialog._internal(
            actions: actions,
            content: content,
            title: title,
            icon: icon,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return (PlatformService.instance.isIos)
        ? CupertinoAlertDialog(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) icon!,
                if (title != null) title!,
              ],
            ),
            content: content,
            actions: actions ?? [],
          )
        : AlertDialog(
            icon: icon,
            title: title,
            content: content,
            actions: actions,
          );
  }
}
