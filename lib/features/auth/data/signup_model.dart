class SignupMode {
  final String email;
  final String fullName;
  final String password;

  SignupMode({
    required this.email,
    required this.fullName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "full_name": fullName,
      "password": password,
    };
  }
}