class SignupOtp {
  final String email;
  final String otp;
  final String purpose;

  SignupOtp({
    required this.email,
    required this.otp,
    this.purpose = 'signup',
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "otp": otp,
      "purpose": purpose,
    };
  }
}
