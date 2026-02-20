class VerifySignupModel {
  final String email;
  final String purpose;

  VerifySignupModel({
    required this.email,
    this.purpose = 'signup',
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "purpose": purpose,
    };
  }

  factory VerifySignupModel.fromJson(Map<String, dynamic> json) {
    return VerifySignupModel(
      email: json['email'],
      purpose: json['purpose'] ?? 'signup',
    );
  }
}
