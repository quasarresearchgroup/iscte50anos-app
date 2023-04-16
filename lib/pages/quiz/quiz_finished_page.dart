import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class QuizFinishedPage extends StatelessWidget {
  const QuizFinishedPage({
    Key? key,
    required this.trial_score,
  }) : super(key: key);

  final int trial_score;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${AppLocalizations.of(context)!.quizPointsOfTrial}: $trial_score",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                  AppLocalizations.of(context)!
                      .quizFinishedRecommendLeaderboard,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DynamicTextButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(
                    AppLocalizations.of(context)!.back,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: IscteTheme.iscteColor),
                  ),
                ),
                DynamicTextButton(
                  onPressed: () => Navigator.of(context)
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
