class PatientModel {
  final int id;
  final String name;
  final int? age;
  final String? sex;
  final String? healthIssues;

  const PatientModel({
    required this.id,
    required this.name,
    this.age,
    this.sex,
    this.healthIssues,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    try {
      return PatientModel(
        id: json['id'] as int? ?? 0,
        name: (json['name'] as String?)?.trim() ?? '',
        age: json['age'] as int?,
        sex: (json['sex'] as String?)?.trim(),
        healthIssues: (json['health_issues'] as String?)?.trim(),
      );
    } catch (e) {
      print('Error parsing PatientModel: $e');
      return PatientModel.empty();
    }
  }

  factory PatientModel.empty() {
    return PatientModel(
      id: 0,
      name: '',
      age: null,
      sex: null,
      healthIssues: null,
    );
  }

  // Helper getters
  String get displayName => name.isNotEmpty ? name : 'Unknown Patient';
  String get displayAge => age?.toString() ?? 'Not specified';
  String get displaySex => sex?.isNotEmpty == true ? sex! : 'Not specified';
  String get displayHealthIssues => healthIssues?.isNotEmpty == true ? healthIssues! : 'None specified';

  @override
  String toString() {
    return 'PatientModel(id: $id, name: $name, age: $age, sex: $sex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PatientModel &&
        other.id == id &&
        other.name == name &&
        other.age == age &&
        other.sex == sex &&
        other.healthIssues == healthIssues;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, age, sex, healthIssues);
  }
}
