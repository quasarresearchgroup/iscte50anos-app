import 'package:flutter/material.dart';

class QuestionTextWidget extends StatelessWidget {
  final String questionText;

  const QuestionTextWidget(this.questionText, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      child: Text(
        questionText,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ), //Text
    ); //Container
  }
}
