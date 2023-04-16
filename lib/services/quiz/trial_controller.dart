import 'dart:async';

import 'package:iscte_spots/models/quiz/trial.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

class TrialController {
  final Trial trial;
  final int quizNumber;
  final Set<int> _selectedAnswerIds = {};

  Set<int> get selectedAnswerIds => _selectedAnswerIds;

  TrialController({required this.quizNumber, required this.trial});

  void addAnswer(int answerid) {
    _selectedAnswerIds.add(answerid);
    LoggerService.instance.info("TrialController: $_selectedAnswerIds");
  }

  void addAllAnswers(Iterable<int> answerids) {
    _selectedAnswerIds.addAll(answerids);
    LoggerService.instance.info("TrialController: $_selectedAnswerIds");
  }

  void removeAnswer(int answerid) {
    _selectedAnswerIds.remove(answerid);
    LoggerService.instance.info("TrialController: $_selectedAnswerIds");
  }

  bool containsAnswer(int answerId) {
    return _selectedAnswerIds.contains(answerId);
  }

  bool answersIsEmpty() => _selectedAnswerIds.isEmpty;

  bool answersIsNotEmpty() => _selectedAnswerIds.isNotEmpty;
}
