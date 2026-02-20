class NextAppointmentModel {
  final String doctorName;
  final String appointmentDate;

  const NextAppointmentModel({
    required this.doctorName,
    required this.appointmentDate,
  });

  factory NextAppointmentModel.fromJson(Map<String, dynamic> json) {
    try {
      return NextAppointmentModel(
        doctorName: json['doctor_name'] as String? ?? '',
        appointmentDate: json['appointment_date'] as String? ?? '',
      );
    } catch (e) {
      // Return empty model on parsing error
      return const NextAppointmentModel(
        doctorName: '',
        appointmentDate: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_name': doctorName,
      'appointment_date': appointmentDate,
    };
  }

  @override
  String toString() {
    return 'NextAppointmentModel(doctorName: $doctorName, appointmentDate: $appointmentDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NextAppointmentModel &&
        other.doctorName == doctorName &&
        other.appointmentDate == appointmentDate;
  }

  @override
  int get hashCode {
    return doctorName.hashCode ^ appointmentDate.hashCode;
  }
}
