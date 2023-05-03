import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/quiz/quiz_exceptions.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_loading_widget.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class QuizFinishedPage extends StatefulWidget {
  QuizFinishedPage({
    Key? key,
    required this.trial_score,
    required this.errorCallback,
  }) : super(key: key);

  Future<int>? trial_score;
  final Future<int> Function() errorCallback;

  @override
  State<QuizFinishedPage> createState() => _QuizFinishedPageState();
}

class _QuizFinishedPageState extends State<QuizFinishedPage> {
  bool resubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<int>(
          future: widget.trial_score,
          builder: (context, AsyncSnapshot<int> snapshot) {
            Widget child;
            if (snapshot.hasData && snapshot.data != null) {
              child = QuizFinishedSuccess(points: snapshot.data!);
            } else if (snapshot.hasError) {
              String displayMessage = "";
              if (snapshot.error is TrialQuizNotExistException) {
                displayMessage =
                    AppLocalizations.of(context)!.trialQuizNotExistException;
              } else if (snapshot.error is TrialAlreadyAnsweredException) {
                displayMessage =
                    AppLocalizations.of(context)!.trialAlreadyAnsweredException;
              } else if (snapshot.error is TrialInvalidAnswerException) {
                displayMessage =
                    AppLocalizations.of(context)!.trialInvalidAnswerException;
              } else if (snapshot.error is TrialFailedSubmitAnswer) {
                displayMessage =
                    AppLocalizations.of(context)!.trialFailedSubmitAnswer;
              } else {
                displayMessage = "";
              }
              child = Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.quizFinishPageErrorTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  resubmitting
                      ? const DynamicLoadingWidget()
                      : DynamicErrorWidget(
                          display: displayMessage,
                          onRefresh: () async {
                            try {
                              setState(() {
                                resubmitting = true;
                                widget.trial_score = widget.errorCallback();
                              });
                              await widget.trial_score;
                            } finally {
                              setState(() => resubmitting = false);
                            }
                          },
                          refreshText: Text(
                            AppLocalizations.of(context)!
                                .quizFinishPageErrorResubmitText,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                ],
              );
              LoggerService.instance.debug("snapshot data: ${snapshot.data}");
            } else {
              child = const DynamicLoadingWidget();
            }
            return AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

class QuizFinishedSuccess extends StatelessWidget {
  const QuizFinishedSuccess({
    Key? key,
    required this.points,
  }) : super(key: key);
  final int points;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "${AppLocalizations.of(context)!.quizPointsOfTrial}: ${points}",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
              AppLocalizations.of(context)!.quizFinishedRecommendLeaderboard,
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
              onPressed: () =>
                  Navigator.of(context).pushNamed(LeaderBoardPage.pageRoute),
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
        )
      ],
    );
  }
}
