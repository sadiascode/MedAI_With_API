class DeleteAccountRequestModel {
  final String password;

  DeleteAccountRequestModel({
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "password": password,
    };
  }

  factory DeleteAccountRequestModel.fromJson(Map<String, dynamic> json) {
    return DeleteAccountRequestModel(
      password: json['password'] ?? '',
    );
  }
}
