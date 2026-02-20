class PrescriptionMedicineModel {
  final int id;
  final String name;
  final int howManyDay;
  final int stock;
  final MedicineTimeSlot? morning;
  final MedicineTimeSlot? afternoon;
  final MedicineTimeSlot? evening;
  final MedicineTimeSlot? night;

  const PrescriptionMedicineModel({
    required this.id,
    required this.name,
    required this.howManyDay,
    required this.stock,
    this.morning,
    this.afternoon,
    this.evening,
    this.night,
  });

  factory PrescriptionMedicineModel.fromJson(Map<String, dynamic> json) {
    try {
      return PrescriptionMedicineModel(
        id: json['id'] as int? ?? 0,
        name: (json['name'] as String?)?.trim() ?? '',
        howManyDay: json['how_many_day'] as int? ?? 0,
        stock: json['stock'] as int? ?? 0,
        morning: _parseTimeSlot(json['morning']),
        afternoon: _parseTimeSlot(json['afternoon']),
        evening: _parseTimeSlot(json['evening']),
        night: _parseTimeSlot(json['night']),
      );
    } catch (e) {
      print('Error parsing PrescriptionMedicineModel: $e');
      return PrescriptionMedicineModel.empty();
    }
  }

  static MedicineTimeSlot? _parseTimeSlot(dynamic timeSlotData) {
    if (timeSlotData == null) return null;
    
    try {
      return MedicineTimeSlot.fromJson(timeSlotData as Map<String, dynamic>);
    } catch (e) {
      print('Error parsing time slot: $e');
      return null;
    }
  }

  factory PrescriptionMedicineModel.empty() {
    return PrescriptionMedicineModel(
      id: 0,
      name: '',
      howManyDay: 0,
      stock: 0,
      morning: null,
      afternoon: null,
      evening: null,
      night: null,
    );
  }

  // Helper getters
  bool get hasAnyTimeSlot => morning != null || afternoon != null || evening != null || night != null;
  bool get hasMorning => morning != null;
  bool get hasAfternoon => afternoon != null;
  bool get hasEvening => evening != null;
  bool get hasNight => night != null;

  // Get formatted time slots for display
  String get morningDisplay => morning?.formattedTimeWithMeal ?? '';
  String get afternoonDisplay => afternoon?.formattedTimeWithMeal ?? '';
  String get eveningDisplay => evening?.formattedTimeWithMeal ?? '';
  String get nightDisplay => night?.formattedTimeWithMeal ?? '';

  // Get time only (without meal info)
  String get morningTime => morning?.formattedTime ?? '';
  String get afternoonTime => afternoon?.formattedTime ?? '';
  String get eveningTime => evening?.formattedTime ?? '';
  String get nightTime => night?.formattedTime ?? '';

  @override
  String toString() {
    return 'PrescriptionMedicineModel(id: $id, name: $name, days: $howManyDay)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrescriptionMedicineModel &&
        other.id == id &&
        other.name == name &&
        other.howManyDay == howManyDay &&
        other.stock == stock;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, howManyDay, stock);
  }
}

class MedicineTimeSlot {
  final String time;
  final bool beforeMeal;
  final bool afterMeal;

  const MedicineTimeSlot({
    required this.time,
    required this.beforeMeal,
    required this.afterMeal,
  });

  factory MedicineTimeSlot.fromJson(Map<String, dynamic> json) {
    try {
      return MedicineTimeSlot(
        time: json['time'] as String? ?? '',
        beforeMeal: _parseBool(json['before_meal']),
        afterMeal: _parseBool(json['after_meal']),
      );
    } catch (e) {
      print('Error parsing MedicineTimeSlot: $e');
      return MedicineTimeSlot(
        time: '',
        beforeMeal: false,
        afterMeal: false,
      );
    }
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    return false;
  }

  // Get formatted time (24h to 12h conversion)
  String get formattedTime {
    if (time.isEmpty) return '';
    
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '${displayHour.toString().padLeft(2, '0')}:${minute.padLeft(2, '0')} $period';
      }
      return time;
    } catch (e) {
      print('Error formatting time: $e');
      return time;
    }
  }

  // Get meal info according to requirements
  String get mealInfo {
    if (beforeMeal && afterMeal) {
      return 'Before & After Meal';
    } else if (beforeMeal) {
      return 'Before Meal';
    } else if (afterMeal) {
      return 'After Meal';
    } else {
      return '';
    }
  }

  // Get formatted time with meal info
  String get formattedTimeWithMeal {
    final formattedTimeStr = formattedTime;
    final mealInfoStr = mealInfo;
    
    if (formattedTimeStr.isEmpty) return '';
    if (mealInfoStr.isEmpty) return formattedTimeStr;
    
    return '$formattedTimeStr - $mealInfoStr';
  }

  @override
  String toString() {
    return 'MedicineTimeSlot(time: $time, beforeMeal: $beforeMeal, afterMeal: $afterMeal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicineTimeSlot &&
        other.time == time &&
        other.beforeMeal == beforeMeal &&
        other.afterMeal == afterMeal;
  }

  @override
  int get hashCode {
    return Object.hash(time, beforeMeal, afterMeal);
  }
}
