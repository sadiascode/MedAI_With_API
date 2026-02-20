class Note {
  final int id;
  final String note;

  Note({
    required this.id,
    required this.note,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? 0,
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
    };
  }
}

class DoctorModel {
  final int id;
  final String name;
  final String sex;
  final String specialization;
  final String hospitalName;
  final String designation;
  final String? doctorEmail;
  final List<Note> notes;
  final List<int> prescriptions;
  final String? nextAppointmentDate;

  DoctorModel({
    required this.id,
    required this.name,
    required this.sex,
    required this.specialization,
    required this.hospitalName,
    required this.designation,
    this.doctorEmail,
    required this.notes,
    required this.prescriptions,
    this.nextAppointmentDate,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sex: json['sex'] ?? '',
      specialization: json['specialization'] ?? '',
      hospitalName: json['hospital_name'] ?? '',
      designation: json['designation'] ?? '',
      doctorEmail: json['doctor_email'],
      notes: (json['notes'] as List<dynamic>?)
          ?.map((note) => Note.fromJson(note))
          .toList() ?? [],
      prescriptions: (json['prescriptions'] as List<dynamic>?)
          ?.map((prescription) => prescription as int)
          .toList() ?? [],
      nextAppointmentDate: json['next_appointment_date'] as String?,
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
      'notes': notes.map((note) => note.toJson()).toList(),
      'prescriptions': prescriptions,
      'next_appointment_date': nextAppointmentDate,
    };
  }
}