import 'medicine_model.dart';
import 'next_appointment_model.dart';

class DashboardModel {
  final List<MedicineModel> morning;
  final List<MedicineModel> afternoon;
  final List<MedicineModel> evening;
  final List<MedicineModel> night;
  final List<NextAppointmentModel> nextAppointment;

  const DashboardModel({
    required this.morning,
    required this.afternoon,
    required this.evening,
    required this.night,
    required this.nextAppointment,
  });

  // Empty constructor for default state
  factory DashboardModel.empty() {
    return const DashboardModel(
      morning: [],
      afternoon: [],
      evening: [],
      night: [],
      nextAppointment: [],
    );
  }

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    try {
      return DashboardModel(
        morning: _parseMedicineList(json['Morning']),
        afternoon: _parseMedicineList(json['Afternoon']),
        evening: _parseMedicineList(json['Evening']),
        night: _parseMedicineList(json['Night']),
        nextAppointment: (json['next_appointment'] as List?)
            ?.map((e) => NextAppointmentModel.fromJson(e))
            .toList() ?? [],
      );
    } catch (e) {
      print('❌ Error parsing DashboardModel: $e');
      return DashboardModel.empty();
    }
  }

  // Helper method to safely parse medicine lists
  static List<MedicineModel> _parseMedicineList(dynamic data) {
    if (data == null) return [];
    
    if (data is! List) return [];
    
    try {
      return data
          .where((item) => item is Map<String, dynamic>)
          .map((item) => MedicineModel.fromJson(item as Map<String, dynamic>))
          .where((medicine) => medicine.medicineName.isNotEmpty)
          .toList();
    } catch (e) {
      print('❌ Error parsing medicine list: $e');
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Morning': morning.map((item) => item.toJson()).toList(),
      'Afternoon': afternoon.map((item) => item.toJson()).toList(),
      'Evening': evening.map((item) => item.toJson()).toList(),
      'Night': night.map((item) => item.toJson()).toList(),
      'next_appointment': nextAppointment.map((item) => item.toJson()).toList(),
    };
  }

  // Helper getters for UI
  bool get hasAnyMedicines => 
      morning.isNotEmpty || 
      afternoon.isNotEmpty || 
      evening.isNotEmpty || 
      night.isNotEmpty;

  int get totalMedicines => 
      morning.length + 
      afternoon.length + 
      evening.length + 
      night.length;

  @override
  String toString() {
    return 'DashboardModel(morning: ${morning.length}, afternoon: ${afternoon.length}, '
           'evening: ${evening.length}, night: ${night.length})';
  }
}
