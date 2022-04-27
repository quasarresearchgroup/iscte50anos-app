class LoginFormResult {
  LoginFormResult({
    required this.username,
    required this.password,
  });
  final String username;
  final String password;

  @override
  String toString() {
    return 'LoginFormResult{username: $username, password: $password}';
  }

  factory LoginFormResult.fromMap(Map<String, dynamic> json) => LoginFormResult(
        username: json["username"],
        password: json["password"],
      );

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "password": password,
    };
  }
}
