import 'package:iscte_spots/models/quiz/question.dart';

class Trial {
  ///Number of the trial
  int number;

  ///Number of questions inside each trial of a quiz
  int quiz_size;
  List<TrialQuestion> questions;

  Trial(
      {required this.number, required this.quiz_size, required this.questions});

  @override
  String toString() {
    return 'Trial{number: $number, quiz_size: $quiz_size, questions: $questions}';
  }

  factory Trial.fromJson(Map<String, dynamic> json) => Trial(
        number: json["number"],
        quiz_size: json["quiz_size"],
        questions: (json["questions"] as List<dynamic>)
            .map((e) => TrialQuestion.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() {
    return {
      "number": number,
      "quiz_size": quiz_size,
      "questions": questions.map((e) => e.toJson()).toList(),
    };
  }
}

class TrialQuestion {
  int number;
  Question question;

  TrialQuestion({required this.number, required this.question});

  @override
  String toString() {
    return 'TrialQuestion{number: $number, question: $question}';
  }

  factory TrialQuestion.fromJson(Map<String, dynamic> json) => TrialQuestion(
        number: json["number"],
        question: Question.fromJson(json["question"]),
      );

  Map<String, dynamic> toJson() {
    return {
      "number": number,
      "question": question.toJson(),
    };
  }
}
