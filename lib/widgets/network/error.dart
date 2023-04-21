import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class DynamicErrorWidget extends StatelessWidget {
  final Function()? onRefresh;
  final String? display;
  final Text? refreshText;
  final double size;

  const DynamicErrorWidget(
      {Key? key,
      this.onRefresh,
      this.display,
      this.refreshText,
      this.size = 60})
      : super(key: key);

  DynamicErrorWidget.networkError(
      {Key? key,
      this.onRefresh,
      this.refreshText,
      this.size = 60,
      required BuildContext context})
      : display = AppLocalizations.of(context)!.networkError,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: IscteTheme.greyColor.withAlpha(255),
      child: InkWell(
        onTap: onRefresh,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                  child: Text(
                      display ?? AppLocalizations.of(context)!.generalError,
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
                if (onRefresh != null)
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: refreshText ?? Text(
                          AppLocalizations.of(context)!.errorTouchToRefresh,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
