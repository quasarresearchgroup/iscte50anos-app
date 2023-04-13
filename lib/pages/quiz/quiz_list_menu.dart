import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/models/quiz/trial.dart';
import 'package:iscte_spots/pages/quiz/quiz_page.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

import '../../models/quiz/quiz.dart';
import '../../services/quiz/quiz_service.dart';
import '../../widgets/dialogs/CustomDialogs.dart';

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
  static const String pageRoute = "/quiz_menu";
  static const IconData icon = Icons.help;

  const QuizMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: AppLocalizations.of(context)!.quizPageTitle,
        leading: const DynamicBackIconButton(),
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
  late Future<List<Quiz>> futureQuizList;
  bool isLoading = false;

  bool isTrialLoading = false;

  @override
  void initState() {
    super.initState();
    futureQuizList = fetchFunction();
  }

  Future<void> startTrial(int quizNumber) async {
    isTrialLoading = true;
    try {
      Trial newTrialInfo = await QuizService.startTrial(quizNumber);
      isTrialLoading = false;
      LoggerService.instance.debug(newTrialInfo.toJson());
      if (mounted) {
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => QuizPage(
              quizNumber: quizNumber,
              trialNumber: newTrialInfo.number,
              numQuestions: newTrialInfo.quiz_size ?? 0,
            ),
          ),
        )
            .then((value) {
          setState(() {
            futureQuizList = fetchFunction();
          });
        });
      }
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
              children: <Widget>[
                Text(AppLocalizations.of(context)!.quizGenerating),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              SizedBox(
                // Container to hold the description
                height: 50,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.quizAvailable,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Quiz>>(
                  future: futureQuizList,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Quiz> items = snapshot.data ?? [];
                      LoggerService.instance.debug(
                          "quiz list items:\n${items.map((e) => e.toJson())}");
                      return RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            if (!isLoading) {
                              futureQuizList = fetchFunction();
                            }
                          });
                        },
                        child: items.isEmpty
                            ? Center(
                                child: Text(AppLocalizations.of(context)!
                                    .quizNoneAvailable),
                              )
                            : ListView.builder(
                                //shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  int quizNumber = items[index].number;
                                  int score = items[index].score;
                                  int trials = items[index].num_trials;
                                  var topicNames = items[index].topic_names;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Card(
                                      child: ExpansionTile(
                                        iconColor: IscteTheme.iscteColor,
                                        title: Text(
                                          "Quiz ${items[index].number}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: IscteTheme.iscteColor,
                                              ),
                                        ),
                                        subtitle: Text(
                                            "${AppLocalizations.of(context)!.quizPoints}: $score \n${AppLocalizations.of(context)!.quizAttempts}: $trials"
                                            "\n${AppLocalizations.of(context)!.quizTopics}: $topicNames",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium),
                                        children: [
                                          QuizDetail(
                                            quiz: items[index],
                                            startQuiz: () => setState(() {
                                              Navigator.of(context).pop();
                                              startTrial(quizNumber);
                                            }),
                                            returnToQuizList: () => setState(
                                                () => futureQuizList =
                                                    fetchFunction()),
                                          )
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
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return DynamicErrorWidget(onRefresh: () {
                        setState(() {
                          futureQuizList = fetchFunction();
                        });
                      });
                    } else {
                      return const Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator.adaptive(),
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
  const QuizDetail({
    Key? key,
    required this.startQuiz,
    required this.quiz,
    required this.returnToQuizList,
  }) : super(key: key);

  final Function() startQuiz;
  final Function() returnToQuizList;
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    var trials = quiz.trials;
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
                    Text(
                        "${AppLocalizations.of(context)!.quizAttempt}: ${trial.number}"),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                              "${AppLocalizations.of(context)!.quizPoints}: ${trial.is_completed ? trial.score : "-"}"),
                          Text(
                              "${AppLocalizations.of(context)!.quizProgress}: ${trial.progress}/${trial.quiz_size}"),
                        ]),
                    const SizedBox(
                      height: 5,
                    ),
                    if (!trial.is_completed)
                      ElevatedButton(
                        onPressed: () => showYesNoWarningDialog(
                          context: context,
                          text:
                              AppLocalizations.of(context)!.quizContinueAttempt,
                          methodOnYes: () {
                            Navigator.of(context).pop();
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (context) => QuizPage(
                                  quizNumber: quiz.number,
                                  trialNumber: trial.number,
                                  numQuestions: trial.quiz_size,
                                ),
                              ),
                            )
                                .then((value) {
                              returnToQuizList();
                            });
                          },
                        ),
                        child: Text(AppLocalizations.of(context)!.quizContinue),
                      ),
                    const Divider(
                      thickness: 2,
                    ),
                  ],
                );
              }),
          if (quiz.num_trials < quiz.max_num_trials)
            ElevatedButton(
              onPressed: () {
                showYesNoWarningDialog(
                  context: context,
                  text: AppLocalizations.of(context)!.quizBeginAttemptWarning,
                  methodOnYes: startQuiz,
                );
              },
              child: Text(AppLocalizations.of(context)!.quizBeginAttempt),
            )
        ],
      ),
    );
  }
}
