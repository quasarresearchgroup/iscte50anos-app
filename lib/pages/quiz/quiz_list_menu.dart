import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/models/quiz/trial.dart';
import 'package:iscte_spots/models/timeline/topic.dart';
import 'package:iscte_spots/pages/quiz/quiz_page.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

import '../../models/quiz/quiz.dart';
import '../../models/timeline/timeline_filter_params.dart';
import '../../services/quiz/quiz_service.dart';
import '../../widgets/dialogs/custom_dialogs.dart';
import '../home/scanPage/timeline_study_quiz_page.dart';

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
        title: AppLocalizations.of(context)!.quizAvailable,
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
  QuizListState createState() => QuizListState();
}

class QuizListState extends State<QuizList> {
  final fetchFunction = QuizService.getQuizList;
  late Future<List<Quiz>> futureQuizList;
  bool isLoading = false;

  bool isTrialLoading = false;

  @override
  void initState() {
    super.initState();
    futureQuizList = fetchFunction(context);
  }

  void _trialCallbackAux({required Trial trial, required int quizNumber}) {
    isTrialLoading = false;
    LoggerService.instance.debug(trial.toJson());
    if (mounted) {
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => QuizPage(
            quizNumber: quizNumber,
            trial: trial,
          ),
        ),
      )
          .then((_) {
        setState(() {
          futureQuizList = fetchFunction(context);
        });
      });
    }
  }

  Future<void> continueTrialCallback(
      {required int quizNumber, required int trialNumber}) async {
    isTrialLoading = true;
    try {
      Trial trial = await QuizService.getTrial(quizNumber, trialNumber);
      _trialCallbackAux(trial: trial, quizNumber: quizNumber);
    } catch (e) {
      LoggerService.instance.error(e);
      setState(() => isTrialLoading = false);
    }
  }

  Future<void> startTrialCallback({required int quizNumber}) async {
    isTrialLoading = true;
    try {
      Trial newTrial = await QuizService.startTrial(quizNumber);
      _trialCallbackAux(trial: newTrial, quizNumber: quizNumber);
    } catch (e) {
      LoggerService.instance.error(e);
      setState(() => isTrialLoading = false);
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
        : FutureBuilder<List<Quiz>>(
            future: futureQuizList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Quiz> items = snapshot.data ?? [];
                List<ScrollController> scrollControllers =
                    items.map((e) => ScrollController()).toList();

                LoggerService.instance
                    .debug("quiz list items:\n${items.map((e) => e.toJson())}");
                return RefreshIndicator(
                  color: IscteTheme.iscteColor,
                  onRefresh: () async {
                    setState(() {
                      if (!isLoading) {
                        futureQuizList = fetchFunction(context);
                      }
                    });
                  },
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                              AppLocalizations.of(context)!.quizNoneAvailable),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            int quizNumber = items[index].number;
                            int score = items[index].score;
                            int trials = items[index].num_trials;
                            List<Topic> topics = items[index].topics;

                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0),
                              child: Card(
                                elevation: 3,
                                child: ExpansionTile(
                                  initiallyExpanded: trials <= 0,
                                  iconColor: IscteTheme.iscteColor,

                                  title: Text(
                                    "Quiz ${items[index].number}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: trials <= 0
                                              ? IscteTheme.iscteColor
                                              : null,
                                        ),
                                  ),
                                  subtitle: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${AppLocalizations.of(context)!.quizPoints}: $score \n${AppLocalizations.of(context)!.quizAttempts}: $trials",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      Scrollbar(
                                        thumbVisibility: true,
                                        controller: scrollControllers[index],
                                        scrollbarOrientation:
                                            ScrollbarOrientation.bottom,
                                        child: SingleChildScrollView(
                                          controller: scrollControllers[index],
                                          scrollDirection: Axis.horizontal,
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          child: Row(
                                            children: topics
                                                .where((e) => e.title != null)
                                                .map(
                                                  (e) => Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 4.0,
                                                    ),
                                                    child: Chip(
                                                      label: Text(
                                                        e.title ?? "",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    QuizDetail(
                                      quiz: items[index],
                                      startQuiz: startTrialCallback,
                                      continueQuizCallback:
                                          continueTrialCallback,
                                      returnToQuizList: () => setState(
                                        () => futureQuizList =
                                            fetchFunction(context),
                                      ),
                                    )
                                  ],
                                  //minVerticalPadding: 10.0,
                                ),
                              ),
                            );
                          },
                        ),
                );
              } else if (snapshot.connectionState != ConnectionState.done) {
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
                    futureQuizList = fetchFunction(context);
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
          );
  }
}

class QuizDetail extends StatelessWidget {
  const QuizDetail({
    Key? key,
    required this.startQuiz,
    required this.continueQuizCallback,
    required this.quiz,
    required this.returnToQuizList,
  }) : super(key: key);

  final Function({required int quizNumber}) startQuiz;
  final Function({required int quizNumber, required int trialNumber})
      continueQuizCallback;
  final Function() returnToQuizList;
  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    List<TrialInfo> trials = quiz.trials;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trials.length,
              itemBuilder: (context, index) {
                TrialInfo trial = trials[index];
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
                            "${AppLocalizations.of(context)!.quizPoints}: ${trial.score}"),
                        Text(
                            "${AppLocalizations.of(context)!.quizProgress}: ${trial.progress}/${trial.quiz_size}"),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
/*                    if (!trial.is_completed)
                      ElevatedButton(
                        onPressed: () => showYesNoWarningDialog(
                          context: context,
                          text:
                              AppLocalizations.of(context)!.quizContinueAttempt,
                          methodOnYes: () async {
                            Navigator.of(context).pop();
                            await continueQuizCallback(
                              quizNumber: quiz.number,
                              trialNumber: trial.number,
                            );
                          },
                        ),
                        child: Text(AppLocalizations.of(context)!.quizContinue),
                      ),*/
                    const Divider(
                      thickness: 2,
                    ),
                  ],
                );
              }),
          if (quiz.num_trials < quiz.max_num_trials)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                direction: Axis.horizontal,
                spacing: 20,
                runSpacing: 20,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DynamicTextButton(
                    child: Text(AppLocalizations.of(context)!.quizStudyForQuiz),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TimelineStudyForQuiz.fromFilter(
                          filterParams: TimelineFilterParams(
                            topics: quiz.topics
                                .map((Topic e) =>
                                    Topic(id: e.id, title: e.title))
                                .toSet(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showYesNoWarningDialog(
                        context: context,
                        text: AppLocalizations.of(context)!
                            .quizBeginAttemptWarning,
                        methodOnYes: () async {
                          Navigator.of(context).pop();
                          await startQuiz(quizNumber: quiz.number);
                        },
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.quizBeginAttempt),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}
