import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/services/quiz/quiz_service.dart';
import 'package:logger/logger.dart';

import './answer.dart';
import './question.dart';

const double ANSWER_TIME = 10000; //ms

class Quiz extends StatefulWidget {
  final List<Map<String, Object>> questions;
  final int questionIndex;
  final Function answerQuestion;
  final Logger logger = Logger();

  final int trialNumber = 1;
  final int quizNumber = 1;

  Quiz({
    Key? key,
    required this.questions,
    required this.answerQuestion,
    required this.questionIndex,
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

  double countdown = 10000;

  Future<Map> getNextQuestion() async {
    final question = await QuizService.getNextQuestion(widget.quizNumber,
        widget.trialNumber);
    selectedAnswerId = 0;
    selectedAnswerIds.clear();
    submitted = false;
    startTimer();
    print(question.toString());
    return question;
  }

  submitAnswer(int question) async{
    // TODO create answer json
    Map answer = {"choices": selectedAnswerIds};
    print(answer);
    final response = await QuizService.answerQuestion(widget.quizNumber,
        widget.trialNumber, question, answer);
    submitted = true;
    timer?.cancel();
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
      if(multiple) {
        if (selectedAnswerIds.contains(answer)) {
          selectedAnswerIds.remove(answer);
        } else {
          selectedAnswerIds.add(answer);
        }
      }else{
        if(selectedAnswerIds.isEmpty){
          selectedAnswerIds.add(answer);
        }else{
          selectedAnswerIds[0]=answer;
        }
      }
      !multiple
          ? widget.logger.i("Selected answer: ${selectedAnswerIds[0]}")
          : widget.logger
          .i("Selected answers:" + selectedAnswerIds.toString());
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
        if(response["trial_score"] != null){
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Pontuação da tentativa: ${response["trial_score"]}"),
                ElevatedButton(
                  child: Text(AppLocalizations
                      .of(context)
                      ?.advance ?? "Return"),
                  onPressed:() {
                    futureQuestion = getNextQuestion();
                  },
                ),
              ],
            ),
          );
        }
        Map trialQuestion = response;
        Map question = trialQuestion["question"];
        return Column(
          children: [
            LinearProgressIndicator(
              value: getTimePercentage(),
              semanticsLabel: 'Linear progress indicator',
            ),
            Question(
              question['text'].toString(),
            ), //Question
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitHeight,
                          alignment: FractionalOffset.topCenter,
                          image: NetworkImage(
                            // TODO handle lack of image
                              "https://upload.wikimedia.org/wikipedia/commons/7/71/Raul_Hestnes_Ferreira_ISCTE_4042.jpg",
                              //question['image_link'].toString(),
                              scale: 0.5),
                        )),
                  ),
                ),
              ),
            ),

            ...(question['choices'] as List)
                .map((answer) {
              return Answer(
                  selectAnswer,
                  answer['text'].toString(),
                  answer['id'] as int,
                  question["type"] == "M",
                  selectedAnswerId,
                  selectedAnswerIds);
            }).toList(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: Text(AppLocalizations
                      .of(context)
                      ?.advance ?? "Submit"),
                  onPressed: countdown <= 0 || selectedAnswerIds.isEmpty || submitted ? null : () {
                    submitAnswer(trialQuestion["number"]);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black45,
                    onPrimary: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  child: Text(AppLocalizations
                      .of(context)
                      ?.advance ?? "Next"),
                  onPressed: countdown > 0 && !submitted ? null : () {
                    futureQuestion = getNextQuestion();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black45,
                    onPrimary: Colors.white,
                  ),
                )
              ],
            )
          ],
        );
      } else {
        return const Text("Loading...");
      } //Column
    }
    );
  }

}