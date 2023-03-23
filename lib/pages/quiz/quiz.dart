import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/quiz/quiz_image.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/quiz/quiz_service.dart';
import 'package:iscte_spots/widgets/dialogs/CustomDialogs.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

import 'package:iscte_spots/pages/quiz/answer.dart';
import 'package:iscte_spots/pages/quiz/question.dart';

const double ANSWER_TIME = 10000; //ms

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

  late Future<Map> futureQuestion;

  bool submitted = false;
  bool submitting = false;

  bool isTimed = true;

  double countdown = 10000;

  Future<Map> getNextQuestion() async {
    try {
      stopTimer();
      final question = await QuizService.getNextQuestion(
        widget.quizNumber,
        widget.trialNumber,
      );
      selectedAnswerIds.clear();
      submitted = false;

      if (!question.containsKey("trial_score")) {
        question["question"]["choices"].shuffle();
        isTimed = question["question"]["is_timed"];
        if (isTimed) {
          //startTimer();
        } else {
          countdown = 1;
        }
      }

      LoggerService.instance.debug(question.toString());
      //LoggerService.instance.debug(countdown);
      return question;
    } catch (e) {
      LoggerService.instance.debug(e);
      rethrow;
    }
  }

  submitAnswer(int question) async {
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
    return countdown / ANSWER_TIME;
  }

  stopTimer() {
    LoggerService.instance.debug("Stopping QuestionTimer");
    timer?.cancel();
  }

  removeTimer() {
    LoggerService.instance.debug("Removing QuestionTimer");
    timer = null;
    countdown = 1;
  }

  startTimer() {
    LoggerService.instance.debug("Starting QuestionTimer");
    timer?.cancel();
    countdown = ANSWER_TIME;
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        countdown -= 10;
        if (countdown <= 0) {
          timer.cancel();
          DynamicAlertDialog.showDynamicDialog(
            context: context,
            title: Text("data"),
          );
        }
      });
    });
  }

  selectAnswer(int answer, bool multiple) {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureQuestion,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map response = snapshot.data as Map;
          //LoggerService.instance.debug(response);
          if (response.containsKey("trial_score")) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      "${AppLocalizations.of(context)!.quizPointsOfTrial}: ${response["trial_score"]}"),
                  DynamicTextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(AppLocalizations.of(context)!.back),
                  ),
                ],
              ),
            );
          }
          Map trialQuestion = response;
          Map question = trialQuestion["question"];

          return Column(
            children: [
              Text(
                  "${AppLocalizations.of(context)!.quizQuestion} ${trialQuestion["number"]}/${widget.numQuestions}"),
              const SizedBox(height: 5),
              Question(question['text'].toString()), //Question
              Expanded(
                child: QuizImage(
                  flickrUrl: question["image_link"],
                  onLoadCallback: startTimer,
                  onErrorCallback: removeTimer,
                  key: ValueKey(question["image_link"]),
                ),
              ),
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
              ...question["choices"].map((answer) {
                return Answer(
                  selectAnswer,
                  answer['text'].toString(),
                  answer['id'] as int,
                  question["type"] == "M",
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
                        : () => submitAnswer(trialQuestion["number"]),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.resolveWith(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return IscteTheme.greyColor;
                          }
                          return IscteTheme.iscteColor;
                        },
                      ),
                    ),
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
                    onPressed: () => nextButtonCallback(context),
                    child: Text(
                      AppLocalizations.of(context)!.quizNext,
                    ),
                  ),
                ],
              )
            ],
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

  void Function()? nextButtonCallback(BuildContext context) {
    LoggerService.instance.debug("nextButtonCallback called");
    return !submitted && !isTimed
        ? null
        : countdown > 0 && !submitted
            ? () async => await showYesNoWarningDialog(
                  context: context,
                  text: AppLocalizations.of(context)!.quizProgressNoAnswer,
                  methodOnYes: () => setState(() {
                    Navigator.of(context).pop();
                    futureQuestion = getNextQuestion();
                  }),
                )
            : () => setState(() => futureQuestion = getNextQuestion());
  }
}
