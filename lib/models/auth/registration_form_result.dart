class RegistrationFormResult {
  RegistrationFormResult({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.passwordConfirmation,
    required this.email,
    this.affiliationType = "",
    this.affiliationName = "",
  });
  final String username;
  final String firstName;
  final String lastName;
  final String password;
  final String passwordConfirmation;
  final String email;
  final String? affiliationType;
  final String? affiliationName;

  @override
  String toString() {
    return 'RegistrationFormResult{username: $username, first_name: $firstName, last_name: $lastName, password: $password, password_confirmation: $passwordConfirmation, email: $email, affiliation_type: $affiliationType, affiliation_name: $affiliationName}';
  }

  factory RegistrationFormResult.fromMap(Map<String, dynamic> json) =>
      RegistrationFormResult(
        username: json["username"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        password: json["password"],
        passwordConfirmation: json["password_confirmation"],
        email: json["email"],
        affiliationType: json["affiliation_type"],
        affiliationName: json["affiliation_name"],
      );

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "first_name": firstName,
      "last_name": lastName,
      "password": password,
      "password_confirmation": passwordConfirmation,
      "email": email,
      "affiliation_type": affiliationType,
      "affiliation_name": affiliationName,
    };
  }
}
