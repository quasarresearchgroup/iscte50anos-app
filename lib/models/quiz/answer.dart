class Answer {
  String text;
  int id;

  Answer({
    required this.text,
    required this.id,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        text: json["text"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() {
    return {
      "text": text,
      "id": id,
    };
  }
}
