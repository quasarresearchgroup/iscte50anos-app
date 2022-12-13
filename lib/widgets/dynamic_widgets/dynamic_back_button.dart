import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';

class DynamicBackIconButton extends StatelessWidget {
  const DynamicBackIconButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (!PlatformService.instance.isIos)
        ? IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        : CupertinoButton(
            child: const Icon(
              CupertinoIcons.back,
            ),
            //color: CupertinoTheme.of(context).primaryContrastingColor,
            onPressed: () {
              Navigator.of(context).pop();
            },
          );
  }
}
