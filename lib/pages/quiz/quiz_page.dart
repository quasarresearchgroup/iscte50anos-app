import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/models/quiz/trial.dart';
import 'package:iscte_spots/pages/quiz/question_widget.dart';
import 'package:iscte_spots/pages/quiz/quiz_finished_page.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/services/quiz/quiz_service.dart';
import 'package:iscte_spots/services/quiz/trial_controller.dart';
import 'package:iscte_spots/widgets/dialogs/custom_dialogs.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_loading_widget.dart';
import 'package:iscte_spots/widgets/network/error.dart';

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
  Future<int>? trialScore;
  late TabController tabController = TabController(
      length: widget.trialController.trial.questions.length + 1, vsync: this);
  late Future<List<Image>> cachedImages = getCachedImages();
  int cachedImagesCounter = 0;
  bool submitted = false;

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
    setState(() {
      trialScore = answerTrial();
    });
    tabController.animateTo(tabController.index + 1);
  }

  Future<int> answerTrial() {
    Future<int> trialScore = QuizService.answerTrial(
        widget.trialController.quizNumber,
        widget.trialController.trial.number,
        widget.trialController.asnwersToJson());
    trialScore.then((value) => setState(() => submitted = true));
    return trialScore;
  }

  Future<List<Image>> getCachedImages() async {
    List<Image> images = [];
    for (var question in widget.trialController.trial.questions) {
      Image image;
      try {
        image = Image.network(
            await QuizService.getPhotoURLfromQuizFlickrURL(
                question.question.image_link),
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator.adaptive(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        });
      } catch (e) {
        LoggerService.instance.error(e);
        image = Image.network(ISCTE_DEFAULT_QUESTION_IMAGE_URL);
      }
      images.add(image);
      if (mounted) {
        await precacheImage(image.image, context);
        LoggerService.instance.debug("precached image: $cachedImagesCounter");
        setState(() => cachedImagesCounter += 1);
      }
    }
    return images;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: submitted
          ? null
          : () async {
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
            child: FutureBuilder<List<Image>>(
                future: cachedImages,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Image>? completedCachedImages = snapshot.data;

                    if (completedCachedImages != null) {
                      return TabBarView(
                        controller: tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ...widget.trialController.trial.questions
                              .map((TrialQuestion e) => QuestionWidget(
                                    trialController: widget.trialController,
                                    trialQuestion: e,
                                    precachedQuestionImage:
                                        completedCachedImages[widget
                                            .trialController.trial.questions
                                            .indexOf(e)],
                                    nextButtonCallback: nextButtonUiCallback,
                                    finishQuizButtonCallback:
                                        finishQuizButtonUiCallback,
                                  ))
                              .toList(),
                          QuizFinishedPage(
                            trial_score: trialScore,
                            errorCallback: answerTrial,
                          ),
                        ],
                      );
                    } else {
                      return const DynamicErrorWidget();
                    }
                  } else if (snapshot.hasError) {
                    return DynamicErrorWidget(
                        display: snapshot.error.toString());
                  } else {
                    return DynamicLoadingWidget(
                      progress: cachedImagesCounter /
                          widget.trialController.trial.questions.length,
                    );
                  }
                }),
          ),
        ), //Padding
      ),
    );
  }
}
