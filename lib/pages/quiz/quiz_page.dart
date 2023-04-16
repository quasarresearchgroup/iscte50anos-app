import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/quiz/trial.dart';
import 'package:iscte_spots/pages/quiz/question_widget.dart';
import 'package:iscte_spots/pages/quiz/quiz_finished_page.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/quiz/trial_controller.dart';

import 'package:iscte_spots/widgets/dialogs/CustomDialogs.dart';

class QuizPage extends StatefulWidget {
  final int quizNumber;
  final TrialController trialController;

  QuizPage({
    Key? key,
    required this.quizNumber,
    required Trial trial,
  })  : trialController = TrialController(trial: trial, quizNumber: quizNumber),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _QuizPageState();
  }
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  late TabController tabController = TabController(
      length: widget.trialController.trial.questions.length + 1, vsync: this);

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
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ...widget.trialController.trial.questions
                    .map((TrialQuestion e) => QuestionWidget(
                          trialController: widget.trialController,
                          trialQuestion: e,
                          nextButtonCallback:
                              (Iterable<int> selectedAnswerIds) {
                            LoggerService.instance.debug("nextButtonCallback!");
                            widget.trialController
                                .addAllAnswers(selectedAnswerIds);
                            tabController.animateTo(tabController.index + 1);
                          },
                        ))
                    .toList(),
                const QuizFinishedPage(trial_score: 0),
              ],
            ),
          ),
        ), //Padding
      ),
    );
  }
}
