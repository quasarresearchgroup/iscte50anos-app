class RegistrationFormResult {
  RegistrationFormResult({
    required this.username,
    required this.name,
    required this.lastName,
    required this.password,
    required this.passwordConfirmation,
    required this.email,
    required this.affiliationType,
    required this.affiliationName,
  });
  final String username;
  final String name;
  final String lastName;
  final String password;
  final String passwordConfirmation;
  final String email;
  final String affiliationType;
  final String affiliationName;

  @override
  String toString() {
    return 'RegistrationFormResult{name: $name, lastName: $lastName, password: $password, email: $email, district: $affiliationType, school: $affiliationName}';
  }

  factory RegistrationFormResult.fromMap(Map<String, dynamic> json) =>
      RegistrationFormResult(
        username: json["username"],
        name: json["name"],
        lastName: json["lastName"],
        password: json["password"],
        passwordConfirmation: json["passwordConfirmation"],
        email: json["email"],
        affiliationType: json["affiliation_type"],
        affiliationName: json["affiliation_name"],
      );

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "name": name,
      "lastName": lastName,
      "password": password,
      "passwordConfirmation": passwordConfirmation,
      "email": email,
      "affiliation_type": affiliationType,
      "affiliation_name": affiliationName,
    };
  }
}
