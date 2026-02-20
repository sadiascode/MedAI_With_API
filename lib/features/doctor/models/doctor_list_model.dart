class DoctorListModel {
  final int id;
  final String name;
  final String sex;
  final String specialization;
  final String hospitalName;
  final String designation;
  final String? doctorEmail;

  DoctorListModel({
    required this.id,
    required this.name,
    required this.sex,
    required this.specialization,
    required this.hospitalName,
    required this.designation,
    this.doctorEmail,
  });

  factory DoctorListModel.fromJson(Map<String, dynamic> json) {
    return DoctorListModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sex: json['sex'] ?? '',
      specialization: json['specialization'] ?? '',
      hospitalName: json['hospital_name'] ?? '',
      designation: json['designation'] ?? '',
      doctorEmail: json['doctor_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sex': sex,
      'specialization': specialization,
      'hospital_name': hospitalName,
      'designation': designation,
      'doctor_email': doctorEmail,
    };
  }
}
