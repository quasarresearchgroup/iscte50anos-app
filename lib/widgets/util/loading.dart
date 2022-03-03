import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoadingWidget extends StatelessWidget {
  LoadingWidget({
    Key? key,
    this.messagesStyle = const TextStyle(),
  }) : super(key: key);

  TextStyle messagesStyle;
  Future future = Future.delayed(const Duration(seconds: 30));
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (BuildContext context, snapshot) {
          return Center(
            child: Column(children: [
              const CircularProgressIndicator.adaptive(),
              Text(
                AppLocalizations.of(context)!.loading,
                style: messagesStyle,
              )
            ]),
          );
        });
  }
}
