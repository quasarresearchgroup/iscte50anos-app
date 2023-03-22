import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';

class DynamicTextButton extends StatelessWidget {
  const DynamicTextButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.style,
  }) : super(key: key);
  final Widget child;
  final void Function()? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return (PlatformService.instance.isIos)
        ? CupertinoButton(
            onPressed: onPressed,
            disabledColor:
                style?.foregroundColor?.resolve({MaterialState.disabled}) ??
                    CupertinoColors.quaternarySystemFill,
            color: style?.foregroundColor?.resolve({
              MaterialState.focused,
              MaterialState.hovered,
              MaterialState.pressed,
              MaterialState.selected,
            }),
            padding: const EdgeInsets.all(8),
            child: child,
          )
        : TextButton(
            onPressed: onPressed,
            style: style,
            child: child,
/*            style: ButtonStyle(
              backgroundColor: style != null
                  ? MaterialStateProperty.all<Color>(style!)
                  : null,
              foregroundColor: style != null
                  ? MaterialStateProperty.all<Color>(Colors.white)
                  : null,
            ),*/
          );
  }
}
