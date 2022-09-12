import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/pages/quiz/quiz_page.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:logger/logger.dart';

import '../../services/quiz/quiz_service.dart';
import '../../widgets/dialogs/CustomDialogs.dart';
import '../../widgets/network/error.dart';

//const API_ADDRESS = "http://192.168.1.124";

//const API_ADDRESS_PROD = "https://194.210.120.48";
//const API_ADDRESS_TEST = "http://192.168.1.124";
const MAX_TRIALS = 3;

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

// FOR ISOLATED TESTING
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: QuizMenu()));
}

class QuizMenu extends StatelessWidget {
  static const pageRoute = "/quiz_menu";

  const QuizMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title:"Quiz", //AppLocalizations.of(context)!.quizPageTitle)
          leading: DynamicBackIconButton(),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: const QuizList(),
      ),
    );
  }
}

class QuizList extends StatefulWidget {
  const QuizList({Key? key}) : super(key: key);

  @override
  _QuizListState createState() => _QuizListState();
}

class _QuizListState extends State<QuizList> {
  final fetchFunction = QuizService.getQuizList;
  late Future<List<dynamic>> futureQuizList;
  bool isLoading = false;

  bool isTrialLoading = false;

  @override
  void initState() {
    super.initState();
    futureQuizList = fetchFunction();
  }

  startTrial(int quizNumber) async {
    isTrialLoading = true;
    try {
      Map newTrialInfo = await QuizService.startTrial(quizNumber);
      isTrialLoading = false;

      int newTrialNumber = newTrialInfo["trial_number"];

      Navigator.of(context)
          .push(MaterialPageRoute(
          builder: (context) =>
              QuizPage(
                quizNumber: quizNumber,
                trialNumber: newTrialNumber,
              )))
          .then((value) {
        setState(() {
          futureQuizList = fetchFunction();
        });
      });
    } catch (e) {
      setState(() {
        isTrialLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isTrialLoading
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const <Widget>[
          Text('Gerando Quiz... Aguarde'),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: SizedBox(
              child: CircularProgressIndicator.adaptive(),
              width: 60,
              height: 60,
            ),
          ),
        ],
      ),
    )
        : Column(
      children: [
        const SizedBox(
          // Container to hold the description
          height: 50,
          child: Center(
            child: Text("Quizzes disponíveis",
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: futureQuizList,
            builder: (context, snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                var items = snapshot.data as List<dynamic>;
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      if (!isLoading) {
                        futureQuizList = fetchFunction();
                      }
                    });
                  },
                  child: items.isEmpty
                      ? const Center(
                      child: Text(
                          "Não existem Quizzes disponíveis de momento"))
                      : ListView.builder(
                    //shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      int quizNumber = items[index]["number"];
                      int trials = items[index]["num_trials"];
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0),
                        child: Card(
                          child: ExpansionTile(
                            title: Text(
                                "Quiz ${items[index]["number"].toString()}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            subtitle: Text(
                                "Pontos: ${items[index]["score"]} \nTentativas: ${items[index]["num_trials"]}"
                                    "\nTopicos: ${items[index]["topic_names"]}"),
                            children: [
                              QuizDetail(startQuiz: () {
                                setState(() {
                                  Navigator.of(
                                      context)
                                      .pop();
                                  startTrial(
                                      quizNumber);
                                });
                              }, returnToQuizList: (){
                                  setState(() {
                                    futureQuizList = fetchFunction();
                                  });
                              },quiz: items[index])
                            ],
                            //minVerticalPadding: 10.0,
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.connectionState !=
                  ConnectionState.done) {
                return const Center(
                  child: SizedBox(
                    child: CircularProgressIndicator.adaptive(),
                    width: 60,
                    height: 60,
                  ),
                );
              } else if (snapshot.hasError) {
                return NetworkError(onRefresh: () {
                  setState(() {
                    futureQuizList = fetchFunction();
                  });
                });
              } else {
                return const Center(
                  child: SizedBox(
                    child: CircularProgressIndicator.adaptive(),
                    width: 60,
                    height: 60,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class QuizDetail extends StatelessWidget {
  const QuizDetail({Key? key, required this.startQuiz, required this.quiz, required this.returnToQuizList}) : super(key: key);

  final Function() startQuiz;
  final Function() returnToQuizList;
  final Map quiz;

  @override
  Widget build(BuildContext context) {
    var trials = quiz["trials"];
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trials.length,
              itemBuilder: (context, index) {
                var trial = trials[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Tentativa ${trial["number"]}"),
                    const SizedBox(height: 5,),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Pontos: ${ trial["is_completed"] ? trial["score"] : "-" }"),
                          Text("Progresso: ${trial["progress"]}/${trial["quiz_size"]}"),
                        ]),
                    const SizedBox(height: 5,),
                    if (!trial["is_completed"]) ElevatedButton(
                        onPressed: () => showYesNoWarningDialog("Deseja continuar esta tentativa de quiz?", (){
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                              builder: (context) =>
                                  QuizPage(
                                    quizNumber: quiz["number"],
                                    trialNumber: trial["number"],
                                  )))
                              .then((value) {
                            returnToQuizList();
                          });
                        }, context), child: const Text("Continuar")),
                    const Divider(thickness: 2,),
                  ],
                );}),
          if (quiz["num_trials"] < MAX_TRIALS) ElevatedButton(onPressed: () {
            showYesNoWarningDialog("Deseja iniciar uma tentativa de Quiz? "
                "(Certifique-se que tem uma ligação de Internet estável)", startQuiz, context);
          }, child: const Text("Iniciar nova tentativa"))
        ],
      ),
    );
  }
}

