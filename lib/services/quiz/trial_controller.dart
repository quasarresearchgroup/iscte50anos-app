import 'package:iscte_spots/models/quiz/trial.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

class TrialController {
  final Trial trial;
  final int quizNumber;
  final Map<int, Set<int>> _selectedAnswers = {};

  Map<int, Set<int>> get selectedAnswerMap => _selectedAnswers;

  TrialController({required this.quizNumber, required this.trial});

  Map<String, dynamic> asnwersToJson() {
    Map<String, List<Map<String, dynamic>>> json;
    json = {"answers": []};

    for (var key in _selectedAnswers.keys) {
      if (_selectedAnswers[key] != null && _selectedAnswers[key]!.isNotEmpty) {
        json["answers"]?.add({
          "question_id": key,
          "choices": _selectedAnswers[key]?.toList(),
        });
      }
    }
    return json;
  }

  void addAnswer(int answerId, int questionId) {
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
