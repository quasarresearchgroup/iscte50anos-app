import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/quiz/answer.dart';
import 'package:iscte_spots/models/quiz/next_question_fetch_info.dart';
import 'package:iscte_spots/models/quiz/question.dart';
import 'package:iscte_spots/pages/leaderboard/leaderboard_screen.dart';
import 'package:iscte_spots/pages/quiz/answer_widget.dart';
import 'package:iscte_spots/pages/quiz/question_text_widget.dart';
import 'package:iscte_spots/pages/quiz/quiz_image.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/quiz/quiz_service.dart';
import 'package:iscte_spots/widgets/dialogs/CustomDialogs.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

//const double ANSWER_TIME = 10000; //ms

class Quiz extends StatefulWidget {
  final int trialNumber;
  final int quizNumber;
  final int numQuestions;

  const Quiz({
    Key? key,
    required this.trialNumber,
    required this.quizNumber,
    required this.numQuestions,
  }) : super(key: key);

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  Timer? timer;

  //int selectedAnswerId = 0;
  final List<int> selectedAnswerIds = [];

  late Future<NextQuestionFetchInfo> futureQuestion;

  bool submitted = false;
  bool submitting = false;

  bool isTimed = true;

  double countdown = 10000;
  late double answer_time;

  Future<NextQuestionFetchInfo> getNextQuestion() async {
    LoggerService.instance.debug("getNextQuestion called");
    try {
      stopTimer();
      final NextQuestionFetchInfo nextQuestionResponse =
          await QuizService.getNextQuestion(
        widget.quizNumber,
        widget.trialNumber,
      );
      LoggerService.instance.debug(nextQuestionResponse);
      selectedAnswerIds.clear();
      submitted = false;

      if (nextQuestionResponse.trial_score == null &&
          nextQuestionResponse.question != null) {
        Question question = nextQuestionResponse.question!;
        //["question"]["choices"].shuffle();
        // isTimed = question["question"]["is_timed"];
        // answer_time = question["question"]["time"].toDouble();
        question.choices.shuffle();
        isTimed = question.isTimed;
        answer_time = question.time.toDouble() * 1000;
        if (isTimed) {
          //startTimer();
        } else {
          countdown = 1;
        }
      }

      LoggerService.instance.debug(nextQuestionResponse.toString());
      //LoggerService.instance.debug(countdown);
      return nextQuestionResponse;
    } catch (e) {
      LoggerService.instance.debug(e);
      rethrow;
    }
  }

  void submitAnswer(int question) async {
    submitting = true;
    try {
      Map answer = {"choices": selectedAnswerIds};
      LoggerService.instance.debug(answer.toString());
      submitted = await QuizService.answerQuestion(
        widget.quizNumber,
        widget.trialNumber,
        question,
        answer,
      );
      if (submitted) {
        stopTimer();
      }
    } finally {
      submitting = false;
    }
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    futureQuestion = getNextQuestion();
  }

  double getTimePercentage() {
    return countdown / answer_time;
  }

  void stopTimer() {
    LoggerService.instance.debug("Stopping QuestionTimer");
    timer?.cancel();
  }

  void removeTimer() {
    LoggerService.instance.debug("Removing QuestionTimer");
    timer = null;
    countdown = 1;
  }

  void startTimer() {
    if (!isTimed) return;

    LoggerService.instance.debug("Starting QuestionTimer");
    timer?.cancel();
    countdown = answer_time;
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        countdown -= 10;
        if (countdown <= 0) {
          timer.cancel();
          DynamicAlertDialog.showDynamicDialog(
            context: context,
            title:
                Text(AppLocalizations.of(context)!.quizTimerEndNoAnswerTitle),
            content: Text(AppLocalizations.of(context)!.quizTimerEndNoAnswer),
          );
        }
      });
    });
  }

  void selectAnswer(int answer, bool multiple) {
    setState(() {
      if (multiple) {
        if (selectedAnswerIds.contains(answer)) {
          selectedAnswerIds.remove(answer);
        } else {
          selectedAnswerIds.add(answer);
        }
        LoggerService.instance.info("Selected answers:$selectedAnswerIds");
      } else {
        if (selectedAnswerIds.isEmpty) {
          selectedAnswerIds.add(answer);
        } else {
          selectedAnswerIds[0] = answer;
        }
        LoggerService.instance.info("Selected answer: ${selectedAnswerIds[0]}");
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  final ButtonStyle buttonStyle = ButtonStyle(
    foregroundColor: MaterialStateProperty.resolveWith(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return IscteTheme.greyColor;
        }
        return IscteTheme.iscteColor;
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NextQuestionFetchInfo>(
      future: futureQuestion,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          NextQuestionFetchInfo nextQuestionInfo = snapshot.data!;
          //LoggerService.instance.debug(response);
          if (nextQuestionInfo.trial_score != null) {
            return QuizFinishedPage(trial_score: nextQuestionInfo.trial_score!);
          }
          // Map trialQuestion = nextQuestionInfo;
          // Question question = trialQuestion["question"];

          if (nextQuestionInfo.question != null &&
              nextQuestionInfo.number != null) {
            int questionNumber = nextQuestionInfo.number!;
            Question question = nextQuestionInfo.question!;
            return Column(
              children: [
                Text(
                    "${AppLocalizations.of(context)!.quizQuestion} ${questionNumber}/${widget.numQuestions}"),
                const SizedBox(height: 5),
                Expanded(
                  child: QuizImage(
                    flickrUrl: question.image_link,
                    onLoadCallback: startTimer,
                    onErrorCallback: startTimer,
                    key: ValueKey(question.image_link),
                  ),
                ),
                QuestionTextWidget(question.text), //Question
                const SizedBox(height: 5),
                isTimed
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: LinearProgressIndicator(
                          value: getTimePercentage(),
                          semanticsLabel: 'Linear progress indicator',
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.quizGeoQuestion),
                const SizedBox(height: 5),
                ...question.choices.map((Answer answer) {
                  return AnswerWidget(
                    selectAnswer,
                    answer.text,
                    answer.id,
                    question.type == QuestionType.multiple,
                    selectedAnswerIds,
                    countdown <= 0 || submitted || submitting,
                  );
                }).toList(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ----- Submit button -----
                    DynamicTextButton(
                      onPressed: countdown <= 0 ||
                              selectedAnswerIds.isEmpty ||
                              submitted ||
                              submitting
                          ? null
                          : () => submitAnswer(questionNumber),
                      style: buttonStyle,
                      child: submitted
                          ? Text(AppLocalizations.of(context)!.submitted)
                          : submitting
                              ? const SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator.adaptive(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)!.submit,
                                ),
                    ),
                    const SizedBox(width: 10),
                    // ----- Next button -----
                    DynamicTextButton(
                      style: buttonStyle,
                      onPressed: !submitted && !isTimed
                          ? null
                          : countdown > 0 && !submitted
                              ? () {
                                  setState(() {
                                    showYesNoWarningDialog(
                                      context: context,
                                      text: AppLocalizations.of(context)!
                                          .quizProgressNoAnswer,
                                      methodOnYes: () {
                                        setState(() {
                                          Navigator.of(context).pop();
                                          futureQuestion = getNextQuestion();
                                        });
                                      },
                                    );
                                  });
                                }
                              : () => setState(
                                    () {
                                      futureQuestion = getNextQuestion();
                                    },
                                  ),
                      child: Text(AppLocalizations.of(context)!.quizNext),
                    ),
                  ],
                )
              ],
            );
          }
          return DynamicErrorWidget(
            onRefresh: () => setState(
              () => futureQuestion = getNextQuestion(),
            ),
          );
        } else if (snapshot.hasError) {
          return DynamicErrorWidget(
            onRefresh: () => setState(
              () => futureQuestion = getNextQuestion(),
            ),
          );
        } else {
          return const Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        } //Column
      },
    );
  }
}

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
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(IscteTheme.iscteColor)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.leaderboard),
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
