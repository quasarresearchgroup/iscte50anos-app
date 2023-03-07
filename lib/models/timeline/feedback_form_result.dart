class FeedbackFormResult {
  FeedbackFormResult({
    required this.email,
    required this.name,
    required this.description,
    this.year,
  });

  final String email;
  final String name;
  final String description;
  final int? year;

  @override
  String toString() {
    return 'FeedbackFormResult{email: $email, name: $name, description: $description, year: $year}';
  }

  factory FeedbackFormResult.fromJson(Map<String, dynamic> json) =>
      FeedbackFormResult(
        email: json["email"],
        name: json["name"],
        description: json["description"],
        year: json["year"],
      );

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "name": name,
      "description": description,
      "year": year,
    };
  }
}
