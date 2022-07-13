import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/services/quiz/quiz_service.dart';
import 'package:logger/logger.dart';

import './answer.dart';
import './question.dart';

const double ANSWER_TIME = 10000; //ms


class Quiz extends StatefulWidget {
  final Logger logger = Logger();

  final int trialNumber;
  final int quizNumber;

  Quiz({
    Key? key, required this.trialNumber, required this.quizNumber,
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
  bool isTimed = true;

  double countdown = 10000;

  Future<Map> getNextQuestion() async {
    final question = await QuizService.getNextQuestion(widget.quizNumber,
        widget.trialNumber);
    selectedAnswerIds.clear();
    submitted = false;

    if (!question.containsKey("trial_score")) {
      isTimed = question["question"]["is_timed"];
      if (isTimed) {
        startTimer();
      }
    }
    widget.logger.d(question.toString());
    return question;
  }

  submitAnswer(int question) async{
    Map answer = {"choices": selectedAnswerIds};
    widget.logger.d(answer.toString());
    submitted = await QuizService.answerQuestion(widget.quizNumber,
        widget.trialNumber, question, answer);
    if(submitted) {
      timer?.cancel();
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
      if(multiple) {
        if (selectedAnswerIds.contains(answer)) {
          selectedAnswerIds.remove(answer);
        } else {
          selectedAnswerIds.add(answer);
        }
        widget.logger.i("Selected answers:" + selectedAnswerIds.toString());
      }else{
        if(selectedAnswerIds.isEmpty){
          selectedAnswerIds.add(answer);
        }else{
          selectedAnswerIds[0]=answer;
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
        if(response.containsKey("trial_score")){
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Pontuação da tentativa: ${response["trial_score"]}"),
                ElevatedButton(
                  child: const Text("Voltar"),
                  onPressed:() {
                    Navigator.of(context).pop();
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
            Text("Pergunta ${trialQuestion["number"]}/8"),
            const SizedBox(height:5),
            isTimed ? LinearProgressIndicator(
              value: getTimePercentage(),
              semanticsLabel: 'Linear progress indicator',
            ) : const Text("Explorar o Campus (Pergunta sem tempo)"),
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
                              "https://live.staticflickr.com/65535/51942926652_b8d29f2cb5_z.jpg",
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
                  selectedAnswerIds);
            }).toList(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ----- Submit button -----
                ElevatedButton(
                  child: Text(submitted ? "Submetido" : "Submeter"),
                  onPressed: countdown <= 0 || selectedAnswerIds.isEmpty || submitted ? null : () {
                      submitAnswer(trialQuestion["number"]);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black45,
                    onPrimary: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                // ----- Next button -----
                ElevatedButton(
                  child: Text("Seguinte"),
                  onPressed: countdown > 0 && !submitted ?  () {
                    setState(() {
                      showDialog( context:context, builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Aviso"),
                          content: const Text("Deseja avançar sem responder?"),
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
                                setState(() {
                                  Navigator.of(context).pop();
                                  futureQuestion = getNextQuestion();
                                });
                              },
                            ),
                          ],
                        );
                      },);
                    });
                  } : () => setState(() {
                      futureQuestion = getNextQuestion();
                  }),
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