import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/services/platform_service.dart';

class DynamicSnackBar {
  static showSnackBar(
      BuildContext context, Widget child, Duration duration) async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (PlatformService.instance.isIos) {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => CupertinoPopupSurface(
            child: SizedBox(
              height: kToolbarHeight,
              child: Center(child: child),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: child,
          duration: duration,
        ));
      }
    });
  }
}
