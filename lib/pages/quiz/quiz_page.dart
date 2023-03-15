import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './quiz.dart';
import '../../widgets/dialogs/CustomDialogs.dart';

//Main for isolated testing
void main() {
  runApp(MaterialApp(
      home: QuizPage(
    quizNumber: 1,
    trialNumber: 1,
    numQuestions: 1,
  )));
}

class QuizPage extends StatefulWidget {
  static const pageRoute = "/quiz";

  final int quizNumber;
  final int trialNumber;
  final int numQuestions;

  QuizPage({
    Key? key,
    required this.quizNumber,
    required this.trialNumber,
    required this.numQuestions,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _QuizPageState();
  }
}

class _QuizPageState extends State<QuizPage> {
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
            child: Quiz(
              trialNumber: widget.trialNumber,
              quizNumber: widget.quizNumber,
              numQuestions: widget.numQuestions,
            ),
          ),
        ), //Padding
      ),
    );
  }
}
