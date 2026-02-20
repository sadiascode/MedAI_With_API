class MedicineModel {
  final String medicineName;
  final String time;
  final bool beforeMeal;
  final bool afterMeal;

  const MedicineModel({
    required this.medicineName,
    required this.time,
    required this.beforeMeal,
    required this.afterMeal,
  });

  // Empty constructor
  factory MedicineModel.empty() {
    return const MedicineModel(
      medicineName: '',
      time: '',
      beforeMeal: false,
      afterMeal: false,
    );
  }

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    try {
      // Validate and sanitize input
      final medicineName = _sanitizeString(json['medicine_name'] ?? '');
      final time = _sanitizeString(json['time'] ?? '');
      final beforeMeal = _parseBool(json['before_meal']);
      final afterMeal = _parseBool(json['after_meal']);

      // Validate required fields
      if (medicineName.isEmpty) {
        print(' MedicineModel: medicine_name is empty');
        return MedicineModel.empty();
      }

      if (time.isEmpty) {
        print(' MedicineModel: time is empty');
        return MedicineModel.empty();
      }

      return MedicineModel(
        medicineName: medicineName,
        time: time,
        beforeMeal: beforeMeal,
        afterMeal: afterMeal,
      );
    } catch (e) {
      print(' Error parsing MedicineModel: $e');
      return MedicineModel.empty();
    }
  }

  // Helper methods for data sanitization
  static String _sanitizeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    return value.toString().trim();
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    if (value is int) return value == 1;
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_name': medicineName,
      'time': time,
      'before_meal': beforeMeal,
      'after_meal': afterMeal,
    };
  }

  // Convert "09:30:00" to "09:30 AM" with better error handling
  String get formattedTime {
    try {
      if (time.isEmpty) return 'Time not set';

      final parts = time.split(':');
      if (parts.length < 2) return time;

      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = int.tryParse(parts[1]) ?? 0;
      
      String period = hour >= 12 ? 'PM' : 'AM';
      hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      print(' Error formatting time: $e');
      return time; // Return original time if formatting fails
    }
  }

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

  // Validation helpers
  bool get isValid => medicineName.isNotEmpty && time.isNotEmpty;
  
  @override
  String toString() {
    return 'MedicineModel(name: $medicineName, time: $time, beforeMeal: $beforeMeal, afterMeal: $afterMeal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicineModel &&
           other.medicineName == medicineName &&
           other.time == time &&
           other.beforeMeal == beforeMeal &&
           other.afterMeal == afterMeal;
  }

  @override
  int get hashCode {
    return medicineName.hashCode ^
           time.hashCode ^
           beforeMeal.hashCode ^
           afterMeal.hashCode;
  }
}
