import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/pages/quiz/quiz_page.dart';
import 'package:iscte_spots/widgets/util/constants.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:logger/logger.dart';

import '../../services/quiz/quiz_service.dart';
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
      appBar: AppBar(
        title:
            const Text("Quiz"), //AppLocalizations.of(context)!.quizPageTitle)
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
              builder: (context) => QuizPage(
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
                Text('Gerando Quiz...'),
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
                                          trials >= MAX_TRIALS
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const <Widget>[
                                                    Text("Completo"),
                                                  ],
                                                )
                                              : ElevatedButton(
                                                  child: const Text("Iniciar"),
                                                  onPressed: () {
                                                    showDialog(
                                                      useRootNavigator: false,
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Center(
                                                              child: Text(
                                                                  "Aviso")),
                                                          content: const Text(
                                                              "Deseja iniciar uma tentativa de Quiz? \n(Certifique-se que tem uma conexão estável)"),
                                                          actions: [
                                                            TextButton(
                                                              child: const Text(
                                                                  'Não'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Sim'),
                                                              onPressed: () {
                                                                setState(() {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  startTrial(
                                                                      quizNumber);
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }),
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
