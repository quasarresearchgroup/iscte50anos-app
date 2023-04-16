import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/models/quiz/answer.dart';
import 'package:iscte_spots/models/quiz/question.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/quiz/trial.dart';
import 'package:iscte_spots/pages/quiz/answer_widget.dart';
import 'package:iscte_spots/pages/quiz/quiz_image.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/quiz/quiz_exceptions.dart';
import 'package:iscte_spots/services/quiz/quiz_service.dart';
import 'package:iscte_spots/services/quiz/trial_controller.dart';
import 'package:iscte_spots/widgets/dialogs/CustomDialogs.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:logger/logger.dart';

class QuestionWidget extends StatefulWidget {
  QuestionWidget({
    Key? key,
    required this.trialController,
    required this.trialQuestion,
    required this.nextButtonCallback,
  })  : question = trialQuestion.question,
        super(key: key);
  final TrialQuestion trialQuestion;
  final TrialController trialController;
  final Question question;
  final Null Function(Iterable<int> selectedAnswers) nextButtonCallback;

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  final List<int> selectedAnswerIds = [];
  Timer? timer;
  late double answer_time = widget.question.time;

  bool submitting = false;

  bool isTimed = true;

  double countdown = 10000;
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

  void selectAnswerCallback(int answer, bool multiple) {
    setState(() {
      if (selectedAnswerIds.contains(answer)) {
        selectedAnswerIds.remove(answer);
      } else {
        if (selectedAnswerIds.isEmpty) {
          selectedAnswerIds.add(answer);
        } else {
          if (multiple) {
            selectedAnswerIds.add(answer);
          } else {
            selectedAnswerIds[0] = answer;
          }
        }
      }
      LoggerService.instance.info(
          "selectAnswerCallback -> answer: $answer , multiple:$multiple , selected answers:$selectedAnswerIds");
    });
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

  void startTimer({required double time, required bool isTimed}) {
    if (!isTimed) return;

    LoggerService.instance.debug("Starting QuestionTimer");
    timer?.cancel();
    countdown = time;
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

/*
  Future<bool> submitAnswer(int question) async {
    setState(() {
      submitting = true;
    });
    bool success = false;

    try {
      Map answer = {"choices": selectedAnswerIds};
      LoggerService.instance.debug(answer);
      await QuizService.answerQuestion(
        widget.trialController.quizNumber,
        widget.trialController.trial.number,
        question,
        answer,
      );
      stopTimer();
      success = true;
    } on QuizException catch (e) {
      success = false;
      LoggerService.instance.error(e);
    } finally {
      setState(() {
        submitting = false;
      });
    }
    setState(() {});
    return success;
  }*/

  /* void submitQuestionButtonCallback() =>
      countdown <= 0 || selectedAnswerIds.isEmpty || submitted || submitting
          ? null
          : () => submitAnswer(widget.trialQuestion.number);*/

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
            "${AppLocalizations.of(context)!.quizQuestion} ${widget.trialQuestion.number}/${widget.trialController.trial.quiz_size}"),
        const SizedBox(height: 5),
        Expanded(
          child: QuizImage(
            flickrUrl: widget.question.image_link!,
            onLoadCallback: () => startTimer(
                isTimed: widget.question.isTimed,
                time: widget.question.time * 1000),
            onErrorCallback: () => startTimer(
                isTimed: widget.question.isTimed,
                time: widget.question.time * 1000),
            key: ValueKey(widget.question.image_link),
          ),
        ),
        QuestionTextWidget(widget.question.text ?? "No question text"),
        //Question
        const SizedBox(height: 5),
        widget.question.isTimed
            ? Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: LinearProgressIndicator(
                  value: countdown / answer_time,
                  semanticsLabel: 'Linear progress indicator',
                ),
              )
            : Text(AppLocalizations.of(context)!.quizGeoQuestion),
        const SizedBox(height: 5),
        ...widget.question.choices.map((Answer answer) {
          return AnswerWidget(
            selectHandler: selectAnswerCallback,
            answerText: answer.text,
            answerId: answer.id,
            isMultipleChoice: widget.question.type == QuestionType.multiple,
            selectedAnswers: selectedAnswerIds,
            disabled: countdown <= 0 || submitting,
          );
        }).toList(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ----- Next button -----
            DynamicTextButton(
              onPressed: !isTimed
                  ? null
                  : selectedAnswerIds.isNotEmpty
                      ? () async => widget.nextButtonCallback(selectedAnswerIds)
                      : () async {
/*                          bool success =
                              await submitAnswer(widget.trialQuestion.number);
                          LoggerService.instance
                              .debug("nextQuestionButtonCallback-> $success");
                          if (!success) return;*/
                          setState(() {
                            showYesNoWarningDialog(
                              context: context,
                              text: AppLocalizations.of(context)!
                                  .quizProgressNoAnswer,
                              methodOnYes: () {
                                setState(() {
                                  Navigator.of(context).pop();
                                  widget.nextButtonCallback(selectedAnswerIds);
                                  // futureQuestion = getNextQuestion();
                                });
                              },
                            );
                          });
                        },
              style: buttonStyle,
              child: submitting
                  ? const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.quizNext,
                    ),
            ),
          ],
        )
      ],
    );
  }
}

class QuestionTextWidget extends StatelessWidget {
  final String questionText;

  const QuestionTextWidget(this.questionText, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      child: Text(
        questionText,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ), //Text
    ); //Container
  }
}
