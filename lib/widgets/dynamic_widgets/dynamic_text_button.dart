import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';

class DynamicTextButton extends StatelessWidget {
  const DynamicTextButton({
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
            child: child,
          )
        : TextButton(
            onPressed: onPressed,
            style: ButtonStyle(
              backgroundColor: style != null
                  ? MaterialStateProperty.all<Color>(style!)
                  : null,
              foregroundColor: style != null
                  ? MaterialStateProperty.all<Color>(Colors.white)
                  : null,
            ),
            child: child,
          );
  }
}
