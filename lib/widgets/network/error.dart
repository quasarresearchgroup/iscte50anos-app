import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/services/platform_service.dart';

class DynamicErrorWidget extends StatelessWidget {
  final Function()? onRefresh;
  final String? display;
  final double size;

  const DynamicErrorWidget(
      {Key? key, this.onRefresh, this.display, this.size = 60})
      : super(key: key);

  DynamicErrorWidget.networkError(
      {Key? key, this.onRefresh, this.size = 60, required BuildContext context})
      : display = AppLocalizations.of(context)!.networkError,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRefresh,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              PlatformService.instance.isIos
                  ? CupertinoIcons.exclamationmark_circle_fill
                  : Icons.error_outline_rounded,
              color: Colors.red,
              size: size,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(display ?? AppLocalizations.of(context)!.generalError,
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            if (onRefresh != null)
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  AppLocalizations.of(context)!.errorTouchToRefresh,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
