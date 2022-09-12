import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/services/platform_service.dart';
import 'package:iscte_spots/services/quiz/quiz_service.dart';
import 'package:iscte_spots/widgets/dialogs/CustomDialogs.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_alert_dialog.dart';
import 'package:logger/logger.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

import '../../widgets/network/error.dart';
import './answer.dart';
import './question.dart';

const double ANSWER_TIME = 10000; //ms

class Quiz extends StatefulWidget {
  final Logger logger = Logger();

  final int trialNumber;
  final int quizNumber;

  Quiz({
    Key? key,
    required this.trialNumber,
    required this.quizNumber,
  }) : super(key: key);

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  Timer? timer;

  int selectedAnswerId = 0;
  final List<int> selectedAnswerIds = [];

  late Future<Map> futureQuestion;

  bool submitted = false;
  bool submitting = false;

  bool isTimed = true;

  double countdown = 10000;

  Future<Map> getNextQuestion() async {
    try {
      timer?.cancel();
      final question = await QuizService.getNextQuestion(widget.quizNumber,
          widget.trialNumber);
      selectedAnswerIds.clear();
      submitted = false;

      if (!question.containsKey("trial_score")) {
        question["question"]["choices"].shuffle();
        isTimed = question["question"]["is_timed"];
        if (isTimed) {
          startTimer();
        } else {
          countdown = 1;
        }
      }

      widget.logger.d(question.toString());
      //widget.logger.d(countdown);
      return question;
    }catch(e){
      widget.logger.d(e);
      rethrow;
    }
  }

  submitAnswer(int question) async {
    submitting = true;
    try {
      Map answer = {"choices": selectedAnswerIds};
      widget.logger.d(answer.toString());
      submitted = await QuizService.answerQuestion(widget.quizNumber,
          widget.trialNumber, question, answer);
      if (submitted) {
        timer?.cancel();
      }
    }finally{
      submitting = false;
    }
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    futureQuestion = getNextQuestion();
  }

  double getTimePercentage() {
    return countdown / ANSWER_TIME;
  }

  startTimer() {
    timer?.cancel();
    countdown = ANSWER_TIME;
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        countdown -= 10;
        if (countdown <= 0) {
          timer.cancel();
        }
      });
    });
  }

  selectAnswer(int answer, bool multiple) {
    setState(() {
      if (multiple) {
        if (selectedAnswerIds.contains(answer)) {
          selectedAnswerIds.remove(answer);
        } else {
          selectedAnswerIds.add(answer);
        }
        widget.logger.i("Selected answers:" + selectedAnswerIds.toString());
      } else {
        if (selectedAnswerIds.isEmpty) {
          selectedAnswerIds.add(answer);
        } else {
          selectedAnswerIds[0] = answer;
        }
        widget.logger.i("Selected answer: ${selectedAnswerIds[0]}");
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: futureQuestion, builder: (context, snapshot) {
      if (snapshot.hasData) {
        Map response = snapshot.data as Map;
        if (response.containsKey("trial_score")) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Pontuação da tentativa: ${response["trial_score"]}"),
            (PlatformService.instance.isIos)
                ? CupertinoButton(
                child: const Text("Voltar"),
                onPressed: () {
                  Navigator.of(context).pop();
                })
                : ElevatedButton(
              child: const Text("Voltar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
              ],
            ),
          );
        }
        Map trialQuestion = response;
        Map question = trialQuestion["question"];

        return Column(
          children: [
            Text("Pergunta ${trialQuestion["number"]}/8"),
            const SizedBox(height: 5),
            isTimed ? Padding(
              padding: const EdgeInsets.only(left:10.0, right:10.0),
              child: LinearProgressIndicator(
                value: getTimePercentage(),
                semanticsLabel: 'Linear progress indicator',
              ),
            ) : const Text("Explorar o Campus (Pergunta sem tempo)"),
            Question(
              question['text'].toString(),
            ), //Question
            Expanded(child: QuizImage(flickrUrl: question["image_link"], key: ValueKey(question["image_link"]))),
            const SizedBox(height: 5),
            ...question["choices"].map((answer) {
              return Answer(
                  selectAnswer,
                  answer['text'].toString(),
                  answer['id'] as int,
                  question["type"] == "M",
                  selectedAnswerIds);
            }).toList(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ----- Submit button -----
                (PlatformService.instance.isIos)
                ? CupertinoButton(
                child: Text(submitted ? "Submetido" : "Submeter"),
                onPressed: () {
                  submitAnswer(trialQuestion["number"]);
                })
                :ElevatedButton(
                  child: submitted? const Text("Submetido") :
                  submitting? const SizedBox(child: CircularProgressIndicator.adaptive(strokeWidth: 2), width:10, height:10)
                      : const Text("Submeter"),
                  onPressed: countdown <= 0 || selectedAnswerIds.isEmpty ||
                      submitted || submitting? null : () {
                    submitAnswer(trialQuestion["number"]);
                  },
                ),
                const SizedBox(width: 10),
                // ----- Next button -----
                (PlatformService.instance.isIos)
                    ? CupertinoButton(
                    child: Text("Seguinte"),
                    onPressed: !submitted && !isTimed ? null : countdown > 0 && !submitted ? () {
                      setState(() {
                        showYesNoWarningDialog("Deseja avançar sem responder?", () {
                          setState(() {
                            Navigator.of(context).pop();
                            futureQuestion = getNextQuestion();
                          });
                        }, context);
                      });
                    } :  () =>
                        setState(() {
                          futureQuestion = getNextQuestion();
                        }))
                    : ElevatedButton(
                  child: const Text("Seguinte"),
                  onPressed: !submitted && !isTimed ? null : countdown > 0 && !submitted ? () {
                    setState(() {
                      showYesNoWarningDialog("Deseja avançar sem responder?", () {
                        setState(() {
                          Navigator.of(context).pop();
                          futureQuestion = getNextQuestion();
                        });
                      }, context);
                    });
                  } :  () =>
                      setState(() {
                        futureQuestion = getNextQuestion();
                      }),
                )
              ],
            )
          ],
        );
      }else if (snapshot.hasError) {
        return NetworkError(onRefresh: () {
          setState(() {
            futureQuestion = getNextQuestion();
          });
        });
      }else {
        return const Center(
          child: SizedBox(
            child: CircularProgressIndicator.adaptive(),
            width: 60,
            height: 60,
          ),
        );
      } //Column
    }
    );
  }

}

class QuizImage extends StatefulWidget {

  final String flickrUrl;

  const QuizImage({Key? key, required this.flickrUrl}) : super(key: key);

  @override
  State<QuizImage> createState() => _QuizImageState();
}

class _QuizImageState extends State<QuizImage> {
  late Future<String> imageUrl;

  @override
  void initState() {
    imageUrl = QuizService.getPhotoURLfromQuizFlickrURL(widget.flickrUrl);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: imageUrl, builder: (context, snapshot) {
      if (snapshot.hasData) {
        return Container(
          color: Colors.white,
          child: PinchZoom(
            child: Image.network(snapshot.data.toString(),
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
        );
      }else{
        return const Center(
          child: SizedBox(
            child: CircularProgressIndicator.adaptive(),
            width: 60,
            height: 60,
          ),
        );
      }
    });
  }
}
