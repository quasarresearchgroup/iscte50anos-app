import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

import './quiz.dart';
import './result.dart';

//Main for isolated testing
void main(){
  runApp(MaterialApp(home:QuizPage(quizNumber: 1, trialNumber: 1)));
}

class QuizPage extends StatefulWidget {
  static const pageRoute = "/quiz";
  final Logger logger = Logger();

  final int quizNumber;
  final int trialNumber;

  QuizPage({Key? key, required this.quizNumber, required this.trialNumber}) : super(key: key);
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
          showDialog( useRootNavigator: false, context:context, builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Aviso"),
              content: const Text("Deseja sair do Quiz?"),
              actions: [
                TextButton(
                  child: const Text('Não'),
                  onPressed: () {
                    Navigator.of(context).pop(); //Exit dialog
                  },
                ),
                TextButton(
                  child: const Text('Sim'),
                  onPressed: () {
                    Navigator.of(context).pop(); //Exit dialog
                    Navigator.of(context).pop(); //Exit quiz
                  },
                ),
              ],
            );
          },);
          return false;
        },
        child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.quizPageTitle ?? "Quiz"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Quiz(trialNumber: widget.trialNumber, quizNumber: widget.quizNumber)
        ), //Padding
      )
    );
  }
}
