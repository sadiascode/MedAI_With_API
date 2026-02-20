class VerifyModel {
  final String email;
  final String otp;
  final String purpose;

  VerifyModel({
    required this.email,
    required this.otp,
    this.purpose = 'password_reset',
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "otp": otp,
      "purpose": purpose,
    };
  }

  factory VerifyModel.fromJson(Map<String, dynamic> json) {
    return VerifyModel(
      email: json['email'],
      otp: json['otp'],
      purpose: json['purpose'] ?? 'password_reset',
    );
  }
}
