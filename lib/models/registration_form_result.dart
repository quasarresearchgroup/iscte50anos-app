class RegistrationFormResult {
  RegistrationFormResult({
    required this.name,
    required this.lastName,
    required this.password,
    required this.email,
    required this.district,
    required this.school,
  });
  final String name;
  final String lastName;
  final String password;
  final String email;
  final String district;
  final String school;

  @override
  String toString() {
    return 'RegistrationFormResult{name: $name, lastName: $lastName, password: $password, email: $email, district: $district, school: $school}';
  }

  factory RegistrationFormResult.fromMap(Map<String, dynamic> json) =>
      RegistrationFormResult(
        name: json["name"],
        lastName: json["lastName"],
        password: json["password"],
        email: json["email"],
        district: json["district"],
        school: json["school"],
      );

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "lastName": lastName,
      "password": password,
      "email": email,
      "district": district,
      "school": school,
    };
  }
}
