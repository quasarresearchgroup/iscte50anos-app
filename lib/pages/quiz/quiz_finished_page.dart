import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_loading_widget.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class QuizFinishedPage extends StatefulWidget {
  const QuizFinishedPage({
    Key? key,
    required this.trial_score, required this.errorCallback,
  }) : super(key: key);

  final Future<int>? trial_score;
  final Future<int> Function() errorCallback;

  @override
  State<QuizFinishedPage> createState() => _QuizFinishedPageState();
}

class _QuizFinishedPageState extends State<QuizFinishedPage> {
  late Future<int>? trial_score = widget.trial_score;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<int>(
                future: widget.trial_score,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Text(
                      "${AppLocalizations.of(context)!
                          .quizPointsOfTrial}: ${snapshot.data!}",
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge,
                    );
                  } else if (snapshot.hasError) {
                    return DynamicErrorWidget(
                      display: snapshot.error!.toString(),
                      onRefresh: () =>
                          setState(() {
                            trial_score = widget.errorCallback();
                          }),
                    );
                  } else {
                    return const DynamicLoadingWidget();
                  }
                }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                  AppLocalizations.of(context)!
                      .quizFinishedRecommendLeaderboard,
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DynamicTextButton(
                  onPressed: Navigator
                      .of(context)
                      .pop,
                  child: Text(
                    AppLocalizations.of(context)!.back,
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: IscteTheme.iscteColor),
                  ),
                ),
                DynamicTextButton(
                  onPressed: () =>
                      Navigator.of(context)
                          .pushNamed(LeaderBoardPage.pageRoute),
                  style: const ButtonStyle(
                      backgroundColor:
                      MaterialStatePropertyAll(IscteTheme.iscteColor)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.leaderboard, color: Colors.white),
                      Text(
                        AppLocalizations.of(context)!.leaderBoardScreen,
                        style: Theme
                            .of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
