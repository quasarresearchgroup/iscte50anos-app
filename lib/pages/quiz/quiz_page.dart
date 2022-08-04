import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:logger/logger.dart';

import './quiz.dart';

//Main for isolated testing
void main() {
  runApp(MaterialApp(home: QuizPage(quizNumber: 1, trialNumber: 1)));
}

class QuizPage extends StatefulWidget {
  static const pageRoute = "/quiz";
  final Logger logger = Logger();

  final int quizNumber;
  final int trialNumber;

  QuizPage({Key? key, required this.quizNumber, required this.trialNumber})
      : super(key: key);
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
          showAlertDialog(context);
          return false;
        },
        child: Scaffold(
          appBar: MyAppBar(
            title: AppLocalizations.of(context)?.quizPageTitle ?? "Quiz",
            leading: DynamicBackIconButton(),
          ),
          body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Quiz(
                  trialNumber: widget.trialNumber,
                  quizNumber: widget.quizNumber)), //Padding
        ));
  }

  void showAlertDialog(BuildContext context) {
    DynamicAlertDialog.showDynamicDialog(
      useRootNavigator: false,
      context: context,
      title: const Text("Aviso"),
      content: const Text("Deseja sair do Quiz?"),
      actions: (PlatformService.instance.isIos)
          ? [
              CupertinoButton(
                  child: const Text('Não'),
                  onPressed: () {
                    Navigator.of(context).pop(); //Exit dialog
                  }),
              CupertinoButton(
                child: const Text('Sim'),
                onPressed: () {
                  Navigator.of(context).pop(); //Exit dialog
                  Navigator.of(context).pop(); //Exit quiz
                },
              )
            ]
          : [
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
  }
}
