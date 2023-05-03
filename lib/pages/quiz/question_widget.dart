import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/quiz/answer.dart';
import 'package:iscte_spots/models/quiz/question.dart';
import 'package:iscte_spots/models/quiz/trial.dart';
import 'package:iscte_spots/pages/quiz/answer_widget.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/quiz/trial_controller.dart';
import 'package:iscte_spots/widgets/dialogs/CustomDialogs.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class QuestionWidget extends StatefulWidget {
  QuestionWidget({
    Key? key,
    required this.trialController,
    required this.trialQuestion,
    required this.nextButtonCallback,
    required this.finishQuizButtonCallback,
    required this.precachedQuestionImage,
  })  : question = trialQuestion.question,
        super(key: key);
  final TrialQuestion trialQuestion;
  final TrialController trialController;
  final Question question;
  final Image precachedQuestionImage;
  final void Function(Iterable<int> selectedAnswers, int questionId)
      nextButtonCallback;
  final void Function(Iterable<int> selectedAnswers, int questionId)
      finishQuizButtonCallback;

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  final List<int> selectedAnswerIds = [];
  Timer? timer;
  late double answer_time = widget.question.time * 1000;
  late bool isTimed = widget.question.isTimed;
  late double countdown = answer_time;

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

  void startTimer({required double time}) {
    LoggerService.instance.info("Starting QuestionTimer");
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

  @override
  void initState() {
    super.initState();

    widget.precachedQuestionImage.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((image, synchronousCall) {
      if (isTimed) startTimer(time: answer_time);
    }));
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Text(
          "${AppLocalizations.of(context)!.quizQuestion} ${widget.trialQuestion.number}/${widget.trialController.trial.quiz_size}",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 5),
        Expanded(
          child: PinchZoom(
            resetDuration: const Duration(minutes: 1),
            child: widget.precachedQuestionImage,
          )
          /*QuizImage(
            flickrUrl: widget.question.image_link!,
            onLoadCallback: () =>
                !isTimed ? null : startTimer(time: widget.question.time * 1000),
            onErrorCallback: () =>
                !isTimed ? null : startTimer(time: widget.question.time * 1000),
            key: ValueKey(widget.question.image_link),
          )*/
          ,
        ),
        QuestionTextWidget(widget.question.text ?? "No question text"),
        //Question
        const SizedBox(height: 5),
        widget.question.isTimed
            ? Flex(
                direction: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: LinearProgressIndicator(
                        color: IscteTheme.iscteColorSmooth,
                        backgroundColor: IscteTheme.iscteColor,
                        value: 1 - (countdown / answer_time),
                        semanticsLabel: 'Linear progress',
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Icon(
                      PlatformService.instance.isIos
                          ? CupertinoIcons.timer
                          : Icons.timer,
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: LinearProgressIndicator(
                        color: IscteTheme.iscteColor,
                        backgroundColor: IscteTheme.iscteColorSmooth,
                        value: countdown / answer_time,
                        semanticsLabel: 'Linear progress',
                      ),
                    ),
                  ),
                ],
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
            disabled: countdown <= 0,
          );
        }).toList(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ----- Next button -----
            Builder(builder: (context) {
              bool isNextButton = widget.trialQuestion.number <
                  widget.trialController.trial.quiz_size;
              return DynamicTextButton(
                onPressed: () =>
                    nextButtonQuestionUiCallback(context, !isNextButton),
                style: buttonStyle,
                child: Text(
                  isNextButton
                      ? AppLocalizations.of(context)!.quizNext
                      : AppLocalizations.of(context)!.quizFinish,
                ),
              );
            }),
          ],
        )
      ],
    );
  }

  void nextButtonQuestionUiCallback(BuildContext context, bool isFinishButton) {
    //timer?.cancel();
    if (selectedAnswerIds.isNotEmpty) {
      _nextButtonQuestionUCallbackAux(isFinishButton);
    } else if (selectedAnswerIds.isEmpty && countdown > 0) {
      showYesNoWarningDialog(
        context: context,
        text: AppLocalizations.of(context)!.quizProgressNoAnswer,
        methodOnYes: () {
          setState(() {
            Navigator.of(context).pop();
            _nextButtonQuestionUCallbackAux(isFinishButton);
          });
        },
      );
    } else {
      _nextButtonQuestionUCallbackAux(isFinishButton);
    }
  }

  void _nextButtonQuestionUCallbackAux(bool isFinishButton) {
    if (isFinishButton) {
      widget.finishQuizButtonCallback(selectedAnswerIds, widget.question.id);
    } else {
      widget.nextButtonCallback(selectedAnswerIds, widget.question.id);
    }
  }
}

class QuestionTextWidget extends StatelessWidget {
  final String questionText;

  const QuestionTextWidget(this.questionText, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(10),
      child: Text(
        questionText,
        style: Theme.of(context).textTheme.titleLarge,
        maxLines: 10,
        textAlign: TextAlign.center,
      ), //Text
    ); //Container
  }
}
