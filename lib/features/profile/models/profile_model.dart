class ProfileModel {
  final String? profilePicture;
  final String fullName;
  final String email;
  final String? address;
  final int? age;
  final String? healthCondition;
  final String? wakeupTime;
  final String? breakfastTime;
  final String? lunchTime;
  final String? dinnerTime;

  ProfileModel({
    this.profilePicture,
    required this.fullName,
    required this.email,
    this.address,
    this.age,
    this.healthCondition,
    this.wakeupTime,
    this.breakfastTime,
    this.lunchTime,
    this.dinnerTime,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProfileModel(
        profilePicture: json['profile_picture'] as String?,
        fullName: json['full_name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        address: json['address'] as String?,
        age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
        healthCondition: json['health_condition'] as String?,
        wakeupTime: json['wakeup_time'] as String?,
        breakfastTime: json['breakfast_time'] as String?,
        lunchTime: json['lunch_time'] as String?,
        dinnerTime: json['dinner_time'] as String?,
      );
    } catch (e) {
      // Return empty model on parsing error
      return ProfileModel(
        fullName: '',
        email: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_picture': profilePicture,
      'full_name': fullName,
      'email': email,
      'address': address,
      'age': age,
      'health_condition': healthCondition,
      'wakeup_time': wakeupTime,
      'breakfast_time': breakfastTime,
      'lunch_time': lunchTime,
      'dinner_time': dinnerTime,
    };
  }

  ProfileModel copyWith({
    String? profilePicture,
    String? fullName,
    String? email,
    String? address,
    int? age,
    String? healthCondition,
    String? wakeupTime,
    String? breakfastTime,
    String? lunchTime,
    String? dinnerTime,
  }) {
    return ProfileModel(
      profilePicture: profilePicture ?? this.profilePicture,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      address: address ?? this.address,
      age: age ?? this.age,
      healthCondition: healthCondition ?? this.healthCondition,
      wakeupTime: wakeupTime ?? this.wakeupTime,
      breakfastTime: breakfastTime ?? this.breakfastTime,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerTime: dinnerTime ?? this.dinnerTime,
    );
  }
}
