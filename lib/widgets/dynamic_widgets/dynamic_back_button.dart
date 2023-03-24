import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class DynamicBackIconButton extends StatelessWidget {
  const DynamicBackIconButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (!PlatformService.instance.isIos)
        ? IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back,
              color: IscteTheme.iscteColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        : CupertinoButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            padding: EdgeInsets.zero,
            child: const Icon(
              CupertinoIcons.back,
              color: IscteTheme.iscteColor,
            ),
          );
  }
}
