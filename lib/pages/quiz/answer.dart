import 'package:flutter/material.dart';

class Answer extends StatelessWidget {
  final Function(int, bool) selectHandler;

  final String answerText;
  final int answerId;

  final bool isMultipleChoice;
  final List<int> selectedAnswers;
  final int selectedId;

  const Answer(this.selectHandler, this.answerText, this.answerId,
      this.isMultipleChoice, this.selectedId, this.selectedAnswers,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        // width: double.infinity,
        height: 50,
        //padding: const EdgeInsets.all(5.0),
        child: !isMultipleChoice
            ? Card(
                child: RadioListTile(
                  title: Text(answerText),
                  dense: true,
                  value: answerId,
                  onChanged: (value) {
                    selectHandler(value as int, false);
                  },
                  groupValue: selectedAnswers.isEmpty ? -1 : selectedAnswers[0],
                ),
              )
            : Card(
                child: CheckboxListTile(
                  title: Text(answerText),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  onChanged: (bool? value) {
                    selectHandler(answerId, true);
                  },
                  value: selectedAnswers.contains(answerId),
              ))); //Container
  }
}
