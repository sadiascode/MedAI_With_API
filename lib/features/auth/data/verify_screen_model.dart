class VerifyScreenModel {
  final String email;
  final String purpose;

  VerifyScreenModel({
    required this.email,
    this.purpose = 'password_reset',
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "purpose": purpose,
    };
  }

  factory VerifyScreenModel.fromJson(Map<String, dynamic> json) {
    return VerifyScreenModel(
      email: json['email'],
      purpose: json['purpose'] ?? 'password_reset',
    );
  }
}
