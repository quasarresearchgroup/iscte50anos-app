import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/quiz/trial.dart';
import 'package:iscte_spots/pages/quiz/question_widget.dart';
import 'package:iscte_spots/pages/quiz/quiz_finished_page.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/quiz/quiz_service.dart';
import 'package:iscte_spots/services/quiz/trial_controller.dart';

import 'package:iscte_spots/widgets/dialogs/CustomDialogs.dart';

class QuizPage extends StatefulWidget {
  final TrialController trialController;

  QuizPage({
    Key? key,
    required int quizNumber,
    required Trial trial,
  })  : trialController = TrialController(trial: trial, quizNumber: quizNumber),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _QuizPageState();
  }
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  Future<int>? trial_score;
  late TabController tabController = TabController(
      length: widget.trialController.trial.questions.length + 1, vsync: this);

  void nextButtonUiCallback(Iterable<int> selectedAnswerIds, int questionId) {
    LoggerService.instance.debug("nextButtonCallback!");
    widget.trialController.addAllAnswers(selectedAnswerIds, questionId);
    tabController.animateTo(tabController.index + 1);
  }

  void finishQuizButtonUiCallback(
      Iterable<int> selectedAnswerIds, int questionId) {
    LoggerService.instance.debug(
        "finishQuizButtonUiCallback! : ${widget.trialController.asnwersToJson()} ");
    widget.trialController.addAllAnswers(selectedAnswerIds, questionId);
    Future<int> bruh = answerTrial();
    setState(() {
      trial_score = bruh;
    });
    tabController.animateTo(tabController.index + 1);
  }

  Future<int> answerTrial() {
    return QuizService.answerTrial(
        widget.trialController.quizNumber,
        widget.trialController.trial.number,
        widget.trialController.asnwersToJson());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showYesNoWarningDialog(
          context: context,
          text: AppLocalizations.of(context)!.quizQuit,
          methodOnYes: () {
            Navigator.of(context).pop(); //Exit dialog
            Navigator.of(context).pop();
          },
        );
        return false;
      },
      child: Scaffold(
        /*   appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.quizPageTitle ?? "Quiz"),
        ),*/
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ...widget.trialController.trial.questions
                    .map((TrialQuestion e) => QuestionWidget(
                          trialController: widget.trialController,
                          trialQuestion: e,
                          nextButtonCallback: nextButtonUiCallback,
                          finishQuizButtonCallback: finishQuizButtonUiCallback,
                        ))
                    .toList(),
                QuizFinishedPage(
                  trial_score: trial_score,
                  errorCallback: answerTrial,
                ),
              ],
            ),
          ),
        ), //Padding
      ),
    );
  }
}
