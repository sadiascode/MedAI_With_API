import 'package:care_agent/features/profile/models/prescription_medicine_model.dart';
import 'package:care_agent/features/profile/models/medical_test_model.dart';
import 'package:care_agent/features/profile/models/patient_model.dart';

class PrescriptionModel {
  final int id;
  final int users;
  final int doctor;
  final String? prescriptionImage;
  final String? nextAppointmentDate;
  final PatientModel patient;
  final List<PrescriptionMedicineModel> medicines;
  final List<MedicalTestModel> medicalTests;

  const PrescriptionModel({
    required this.id,
    required this.users,
    required this.doctor,
    this.prescriptionImage,
    this.nextAppointmentDate,
    required this.patient,
    required this.medicines,
    required this.medicalTests,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    try {
      return PrescriptionModel(
        id: json['id'] as int? ?? 0,
        users: json['users'] as int? ?? 0,
        doctor: json['doctor'] as int? ?? 0,
        prescriptionImage: json['prescription_image'] as String?,
        nextAppointmentDate: json['next_appointment_date'] as String?,
        patient: PatientModel.fromJson(json['patient'] as Map<String, dynamic>? ?? {}),
        medicines: _parseMedicines(json['medicines'] as List<dynamic>?),
        medicalTests: _parseMedicalTests(json['medical_tests'] as List<dynamic>?),
      );
    } catch (e) {
      print('Error parsing PrescriptionModel: $e');
      return PrescriptionModel.empty();
    }
  }

  static List<PrescriptionMedicineModel> _parseMedicines(List<dynamic>? medicinesList) {
    if (medicinesList == null || medicinesList.isEmpty) {
      return [];
    }

    try {
      return medicinesList
          .map((medicine) => PrescriptionMedicineModel.fromJson(medicine as Map<String, dynamic>))
          .where((medicine) => medicine.name.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error parsing medicines list: $e');
      return [];
    }
  }

  static List<MedicalTestModel> _parseMedicalTests(List<dynamic>? testsList) {
    if (testsList == null || testsList.isEmpty) {
      return [];
    }

    try {
      return testsList
          .map((test) => MedicalTestModel.fromJson(test as Map<String, dynamic>))
          .where((test) => test.testName.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error parsing medical tests list: $e');
      return [];
    }
  }

  factory PrescriptionModel.empty() {
    return PrescriptionModel(
      id: 0,
      users: 0,
      doctor: 0,
      prescriptionImage: null,
      nextAppointmentDate: null,
      patient: PatientModel.empty(),
      medicines: [],
      medicalTests: [],
    );
  }

  // Helper getters
  bool get hasMedicines => medicines.isNotEmpty;
  bool get hasMedicalTests => medicalTests.isNotEmpty;
  bool get hasNextAppointment => nextAppointmentDate != null && nextAppointmentDate!.isNotEmpty;
  int get totalMedicines => medicines.length;

  // Get formatted next appointment date
  String get formattedNextAppointment {
    if (nextAppointmentDate == null || nextAppointmentDate!.isEmpty) {
      return 'Not scheduled';
    }
    
    try {
      final date = DateTime.parse(nextAppointmentDate!);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return nextAppointmentDate!;
    }
  }

  // Get prescription name for display
  String get prescriptionName => 'Prescription-$id';

  @override
  String toString() {
    return 'PrescriptionModel(id: $id, patient: ${patient.name}, medicines: $totalMedicines, tests: ${medicalTests.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrescriptionModel &&
        other.id == id &&
        other.users == users &&
        other.doctor == doctor &&
        other.prescriptionImage == prescriptionImage &&
        other.nextAppointmentDate == nextAppointmentDate &&
        other.patient == patient &&
        other.medicines.length == medicines.length &&
        other.medicalTests.length == medicalTests.length;
  }

  @override
  int get hashCode {
    return Object.hash(id, users, doctor, prescriptionImage, nextAppointmentDate, patient, medicines.length, medicalTests.length);
  }
}
