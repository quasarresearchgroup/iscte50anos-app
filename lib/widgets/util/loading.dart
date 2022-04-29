import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    Key? key,
    this.messagesStyle = const TextStyle(),
  }) : super(key: key);

  final TextStyle messagesStyle;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircularProgressIndicator.adaptive(),
            Text(
              AppLocalizations.of(context)!.loading,
              style: messagesStyle,
            )
          ]),
    );
  }
}
