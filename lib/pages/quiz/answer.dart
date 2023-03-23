import 'package:flutter/material.dart';

class Answer extends StatelessWidget {
  final Function(int, bool) selectHandler;

  final String answerText;
  final int answerId;

  final bool isMultipleChoice;
  final bool enabled;
  final List<int> selectedAnswers;

  const Answer(this.selectHandler, this.answerText, this.answerId,
      this.isMultipleChoice, this.selectedAnswers, this.enabled,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return !isMultipleChoice
        ? Card(
            child: RadioListTile(
              key: ValueKey(answerId),
              title: Text(answerText),
              dense: true,
              value: answerId,
              onChanged: enabled
                  ? null
                  : (value) {
                      selectHandler(value as int, false);
                    },
              groupValue: selectedAnswers.isEmpty ? -1 : selectedAnswers[0],
              visualDensity: const VisualDensity(horizontal: -4),
            ),
          )
        : Card(
            child: CheckboxListTile(
              key: ValueKey(answerId),
              title: Text(answerText),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              onChanged: enabled
                  ? null
                  : (bool? value) {
                      selectHandler(answerId, true);
                    },
              value: selectedAnswers.contains(answerId),
              visualDensity: const VisualDensity(horizontal: -4),
            ),
          ); //Container
  }
}
