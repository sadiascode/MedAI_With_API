class ForgetModel {
  final String email;
  final String purpose;

  ForgetModel({
    required this.email,
    this.purpose = 'password_reset',
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "purpose": purpose,
    };
  }
}