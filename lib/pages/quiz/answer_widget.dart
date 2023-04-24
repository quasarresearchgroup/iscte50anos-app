import 'package:flutter/material.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class AnswerWidget extends StatelessWidget {
  final Function(int, bool) selectHandler;

  final String answerText;
  final int answerId;

  final bool isMultipleChoice;
  final bool disabled;
  final Iterable<int> selectedAnswers;

  const AnswerWidget({
    required this.selectHandler,
    required this.answerText,
    required this.answerId,
    required this.isMultipleChoice,
    required this.selectedAnswers,
    required this.disabled,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return !isMultipleChoice
        ? Card(
            child: RadioListTile<int>(
              key: ValueKey(answerId),
              title: Text(answerText),
              activeColor: IscteTheme.iscteColor,
              dense: true,
              toggleable: true,
              value: answerId,
              onChanged:
                  disabled ? null : (_) => selectHandler(answerId, false),
              groupValue: selectedAnswers.isEmpty
                  ? null
                  : selectedAnswers.contains(answerId)
                      ? answerId
                      : null,
              visualDensity: const VisualDensity(horizontal: -4),
            ),
          )
        : Card(
            child: CheckboxListTile(
              key: ValueKey(answerId),
              title: Text(answerText),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              onChanged: disabled
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
