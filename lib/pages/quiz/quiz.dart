import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

import './answer.dart';
import './question.dart';

class Quiz extends StatefulWidget {
  final List<Map<String, Object>> questions;
  final int questionIndex;
  final Function answerQuestion;
  final Logger logger = Logger();

  final List<String> selectedAnswers = [];
  String selectedAnswer = "";

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

  final double time = 30000;
  double countdown = 30000;

  double getTimePercentage() {
    return countdown / time;
  }

  startTimer() {
    timer?.cancel();
    countdown = time;
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        countdown -= 10;
        if (countdown <= 0) {
          timer.cancel();
        }
      });
    });
  }

  selectAnswer(String answer, bool multiple) {
    setState(() {
      if (multiple) {
        if (widget.selectedAnswers.contains(answer)) {
          widget.selectedAnswers.remove(answer);
        } else {
          widget.selectedAnswers.add(answer);
        }
      } else {
        widget.selectedAnswer = answer;
      }
      !multiple
          ? widget.logger.i("Selected answer:" + widget.selectedAnswer)
          : widget.logger
              .i("Selected answers:" + widget.selectedAnswers.toString());
    });
  }

  @override
  initState() {
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: getTimePercentage(),
          semanticsLabel: 'Linear progress indicator',
          backgroundColor: Colors.white,
        ),
        Question(
          widget.questions[widget.questionIndex]['questionText'].toString(),
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
                      widget.questions[widget.questionIndex]['imageUrl']
                          .toString(),
                      scale: 0.5),
                )),
              ),
            ),
          ),
        ),

        ...(widget.questions[widget.questionIndex]['answers']
                as List<Map<String, Object>>)
            .map((answer) {
          return Answer(
              selectAnswer,
              answer['text'].toString(),
              answer['text'].toString(),
              widget.questions[widget.questionIndex]["isMultipleChoice"]
                  as bool,
              widget.selectedAnswer,
              widget.selectedAnswers);
        }).toList(),

        ElevatedButton(
          child: Text(AppLocalizations.of(context)!.advance),
          onPressed: () {
            widget.answerQuestion(1);
            startTimer();
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.black45,
            onPrimary: Colors.white,
          ),
        )
      ],
    ); //Column
  }
}
