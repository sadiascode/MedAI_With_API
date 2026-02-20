class MedicalTestModel {
  final int id;
  final String testName;

  const MedicalTestModel({
    required this.id,
    required this.testName,
  });

  factory MedicalTestModel.fromJson(Map<String, dynamic> json) {
    try {
      return MedicalTestModel(
        id: json['id'] as int? ?? 0,
        testName: (json['test_name'] as String?)?.trim() ?? '',
      );
    } catch (e) {
      print('Error parsing MedicalTestModel: $e');
      return MedicalTestModel.empty();
    }
  }

  factory MedicalTestModel.empty() {
    return MedicalTestModel(
      id: 0,
      testName: '',
    );
  }

  // Helper getters
  String get displayName => testName.isNotEmpty ? testName : 'Unknown Test';

  @override
  String toString() {
    return 'MedicalTestModel(id: $id, testName: $testName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicalTestModel &&
        other.id == id &&
        other.testName == testName;
  }

  @override
  int get hashCode {
    return Object.hash(id, testName);
  }
}
