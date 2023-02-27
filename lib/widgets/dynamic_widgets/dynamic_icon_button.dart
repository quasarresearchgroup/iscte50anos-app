import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';

class DynamicIconButton extends StatelessWidget {
  const DynamicIconButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.style,
  }) : super(key: key);

  final Widget child;
  final void Function()? onPressed;
  final Color? style;

  @override
  Widget build(BuildContext context) {
    return (PlatformService.instance.isIos)
        ? CupertinoButton(
            onPressed: onPressed,
            color: style,
            padding: EdgeInsets.zero,
            child: child,
          )
        : IconButton(
            icon: child,
            onPressed: onPressed,
/*            style: ButtonStyle(
                backgroundColor: style != null
                    ? MaterialStateProperty.all<Color>(style!)
                    : null),
                    */
          );
  }
}
