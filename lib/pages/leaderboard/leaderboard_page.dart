import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

import 'leaderboard_widget.dart';

class LeaderBoardPage extends StatelessWidget {
  static const pageRoute = "/leaderboard";
  final Logger logger = Logger();

  LeaderBoardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.leaderBoardScreen),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: Leaderboard(),
      ),
    );
  }
}
