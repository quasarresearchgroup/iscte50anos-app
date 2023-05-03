import 'package:iscte_spots/models/quiz/question.dart';

class NextQuestionFetchInfo {
  int? trial_score;
  Question? question;
  int? number;

  NextQuestionFetchInfo({this.trial_score, this.question, this.number});

  @override
  String toString() {
    return 'NextQuestionFetchInfo{trial_score: $trial_score, question: $question, number: $number}';
  }

  factory NextQuestionFetchInfo.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("trial_score")) {
      return NextQuestionFetchInfo(trial_score: json["trial_score"]);
    } else if (json.containsKey("question") && json.containsKey("number")) {
      return NextQuestionFetchInfo(
        question: Question.fromJson(json["question"]),
        number: json["number"],
      );
    } else {
      return NextQuestionFetchInfo();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "trial_score": trial_score,
      "question": question,
      "number": number,
    };
  }
}
