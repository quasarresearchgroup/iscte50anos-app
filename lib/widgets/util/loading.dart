import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    Key? key,
    this.messagesStyle = const TextStyle(),
    this.backgroundColor,
    this.valueColor,
    this.strokeWidth = 1,
  }) : super(key: key);

  final TextStyle messagesStyle;
  final Color? backgroundColor;
  final Animation<Color?>? valueColor;
  final double strokeWidth;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator.adaptive(
              backgroundColor: backgroundColor,
              strokeWidth: strokeWidth,
              valueColor: valueColor,
            ),
            Text(
              AppLocalizations.of(context)?.loading ?? "",
              style: messagesStyle,
            )
          ]),
    );
  }
}
