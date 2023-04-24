import 'dart:async';

import 'package:iscte_spots/models/quiz/trial.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

class TrialController {
  final Trial trial;
  final int quizNumber;
  final Map<int, Set<int>> _selectedAnswers = {};

  Map<int, Set<int>> get selectedAnswerMap => _selectedAnswers;

  TrialController({required this.quizNumber, required this.trial});

  Map<String, dynamic> asnwersToJson() => {
        "answers": _selectedAnswers.keys
            .map(
              (int key) => {
                "question_id": key,
                "choices": _selectedAnswers[key]?.toList(),
              },
            )
            .toList()
      };

  void addAnswer(int answerId, int questionId) {
    //_selectedAnswers.putIfAbsent(questionId, () => []);
    if (_selectedAnswers[questionId] != null) {
      _selectedAnswers[questionId]!.add(answerId);
    } else {
      _selectedAnswers[questionId] = {answerId};
    }

    LoggerService.instance.info("TrialController: $_selectedAnswers");
  }

  void addAllAnswers(Iterable<int> answerIds, int questionId) {
    if (_selectedAnswers[questionId] != null) {
      _selectedAnswers[questionId]!.addAll(answerIds);
    } else {
      _selectedAnswers[questionId] = {...answerIds};
    }
    LoggerService.instance.info("TrialController: $_selectedAnswers");
  }

  void removeAnswer(int answerId, int questionId) {
    if (_selectedAnswers[questionId] != null) {
      _selectedAnswers[questionId]!.remove(answerId);
    }
    LoggerService.instance.info("TrialController: $_selectedAnswers");
  }

  bool containsAnswer(int answerId, int questionId) {
    if (_selectedAnswers[questionId] == null) return false;
    return _selectedAnswers[questionId]!.contains(answerId);
  }

  bool answersIsEmpty() => _selectedAnswers.isEmpty;

  bool answersIsNotEmpty() => _selectedAnswers.isNotEmpty;
}
