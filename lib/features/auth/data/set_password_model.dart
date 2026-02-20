class SetPasswordModel {
  final String email;
  final String newPassword;
  final String confirmPassword;

  SetPasswordModel({
    required this.email,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "new_password": newPassword,
      "confirm_password": confirmPassword,
    };
  }

  factory SetPasswordModel.fromJson(Map<String, dynamic> json) {
    return SetPasswordModel(
      email: json['email'],
      newPassword: json['new_password'],
      confirmPassword: json['confirm_password'],
    );
  }
}
