import 'package:iscte_spots/models/quiz/answer.dart';

enum QuestionType {
  singular,
  multiple,
}

class Question {
  String text;
  QuestionType type;
  String image_link;
  String? category;
  List<Answer> choices;
  bool isTimed;
  double time;

  Question({
    required this.text,
    required this.type,
    required this.image_link,
    this.category,
    required this.isTimed,
    required this.time,
    required this.choices,
  });

  @override
  String toString() {
    return 'Question{text: $text, type: $type, image_link: $image_link, category: $category, choices: $choices, isTimed: $isTimed, time: $time}';
  }

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        text: json["text"],
        type:
            json["type"] == "S" ? QuestionType.singular : QuestionType.multiple,
        image_link: json["image_link"],
        category: json["category"],
        isTimed: json["is_timed"],
        time: json["time"].toDouble(),
        choices: (json["choices"] as List<dynamic>)
            .map((e) => Answer.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() {
    return {
      "text": text,
      "type": type,
      "image_link": image_link,
      "category": category,
      "isTimed": isTimed,
      "time": time,
      "choices": choices,
    };
  }
}
