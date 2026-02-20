import 'dart:convert';

class ChatPrescriptionModel {
  final int? conversationId;
  final String? response;
  final String? messageType;
  final String? createdAt;
  final List<PrescriptionData> data;

  ChatPrescriptionModel({
    this.conversationId,
    this.response,
    this.messageType,
    this.createdAt,
    List<PrescriptionData>? data,
  }) : data = data ?? [];

  factory ChatPrescriptionModel.fromJson(Map<String, dynamic> json) {
    try {
      return ChatPrescriptionModel(
        conversationId: json['conversation_id'] as int?,
        response: json['response'] as String?,
        messageType: json['message_type'] as String?,
        createdAt: json['created_at'] as String?,
        data: (json['data'] as List<dynamic>?)
            ?.map((item) => PrescriptionData.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      print('Error parsing ChatPrescriptionResponse: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'response': response,
      'message_type': messageType,
      'created_at': createdAt,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'ChatPrescriptionResponse(conversationId: $conversationId, response: $response, messageType: $messageType, createdAt: $createdAt, data: ${data.length} items)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatPrescriptionModel &&
        other.conversationId == conversationId &&
        other.response == response &&
        other.messageType == messageType &&
        other.createdAt == createdAt &&
        other.data.length == data.length;
  }

  @override
  int get hashCode {
    return conversationId.hashCode ^
        response.hashCode ^
        messageType.hashCode ^
        createdAt.hashCode ^
        data.length.hashCode;
  }
}

class PrescriptionData {
  final int? id;
  final int? users;
  final int? doctor;
  final ImageModel? prescriptionImage;
  final String? nextAppointmentDate;
  final Patient? patient;
  final List<Medicine> medicines;
  final List<dynamic> medicalTests;

  PrescriptionData({
    this.id,
    this.users,
    this.doctor,
    this.prescriptionImage,
    this.nextAppointmentDate,
    this.patient,
    List<Medicine>? medicines,
    List<dynamic>? medicalTests,
  }) : medicines = medicines ?? [],
       medicalTests = medicalTests ?? [];

  factory PrescriptionData.fromJson(Map<String, dynamic> json) {
    try {
      return PrescriptionData(
        id: json['id'] as int?,
        users: json['users'] as int?,
        doctor: json['doctor'] as int?,
        prescriptionImage: json['prescription_image'] != null
            ? ImageModel.fromJson(json['prescription_image'] as Map<String, dynamic>)
            : null,
        nextAppointmentDate: json['next_appointment_date'] as String?,
        patient: json['patient'] != null
            ? Patient.fromJson(json['patient'] as Map<String, dynamic>)
            : null,
        medicines: (json['medicines'] as List<dynamic>?)
            ?.map((item) => Medicine.fromJson(item as Map<String, dynamic>))
            .toList() ?? [],
        medicalTests: json['medical_tests'] as List<dynamic>? ?? [],
      );
    } catch (e) {
      print('Error parsing PrescriptionData: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'users': users,
      'doctor': doctor,
      'prescription_image': prescriptionImage?.toJson(),
      'next_appointment_date': nextAppointmentDate,
      'patient': patient?.toJson(),
      'medicines': medicines.map((item) => item.toJson()).toList(),
      'medical_tests': medicalTests,
    };
  }

  @override
  String toString() {
    return 'PrescriptionData(id: $id, users: $users, doctor: $doctor, patient: ${patient?.name}, medicines: ${medicines.length} items)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrescriptionData &&
        other.id == id &&
        other.users == users &&
        other.doctor == doctor &&
        other.prescriptionImage == prescriptionImage &&
        other.nextAppointmentDate == nextAppointmentDate &&
        other.patient == patient &&
        other.medicines.length == medicines.length;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        users.hashCode ^
        doctor.hashCode ^
        prescriptionImage.hashCode ^
        nextAppointmentDate.hashCode ^
        patient.hashCode ^
        medicines.length.hashCode;
  }
}

class Patient {
  final String name;
  final int age;
  final String sex;
  final String healthIssues;

  Patient({
    required this.name,
    required this.age,
    required this.sex,
    required this.healthIssues,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    try {
      return Patient(
        name: json['name'] as String? ?? '',
        age: json['age'] as int? ?? 0,
        sex: json['sex'] as String? ?? '',
        healthIssues: json['health_issues'] as String? ?? '',
      );
    } catch (e) {
      print('Error parsing Patient: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'sex': sex,
      'health_issues': healthIssues,
    };
  }

  @override
  String toString() {
    return 'Patient(name: $name, age: $age, sex: $sex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient &&
        other.name == name &&
        other.age == age &&
        other.sex == sex &&
        other.healthIssues == healthIssues;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        age.hashCode ^
        sex.hashCode ^
        healthIssues.hashCode;
  }
}

class Medicine {
  final int? id;
  final String name;
  final int? howManyDay;
  final int? stock;
  final MedicineTime? morning;
  final MedicineTime? afternoon;
  final MedicineTime? evening;
  final MedicineTime? night;

  Medicine({
    this.id,
    required this.name,
    this.howManyDay,
    this.stock,
    this.morning,
    this.afternoon,
    this.evening,
    this.night,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    try {
      return Medicine(
        id: json['id'] as int?,
        name: json['name'] as String? ?? '',
        howManyDay: json['how_many_day'] as int?,
        stock: json['stock'] as int?,
        morning: json['morning'] != null
            ? MedicineTime.fromJson(json['morning'] as Map<String, dynamic>)
            : null,
        afternoon: json['afternoon'] != null
            ? MedicineTime.fromJson(json['afternoon'] as Map<String, dynamic>)
            : null,
        evening: json['evening'] != null
            ? MedicineTime.fromJson(json['evening'] as Map<String, dynamic>)
            : null,
        night: json['night'] != null
            ? MedicineTime.fromJson(json['night'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      print('Error parsing Medicine: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'how_many_day': howManyDay,
      'stock': stock,
      'morning': morning?.toJson(),
      'afternoon': afternoon?.toJson(),
      'evening': evening?.toJson(),
      'night': night?.toJson(),
    };
  }

  @override
  String toString() {
    return 'Medicine(name: $name, days: $howManyDay)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medicine &&
        other.id == id &&
        other.name == name &&
        other.howManyDay == howManyDay &&
        other.stock == stock &&
        other.morning == morning &&
        other.afternoon == afternoon &&
        other.evening == evening &&
        other.night == night;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        howManyDay.hashCode ^
        stock.hashCode ^
        morning.hashCode ^
        afternoon.hashCode ^
        evening.hashCode ^
        night.hashCode;
  }
}

class MedicineTime {
  final String? time;
  final bool beforeMeal;
  final bool afterMeal;

  MedicineTime({
    this.time,
    this.beforeMeal = false,
    this.afterMeal = false,
  });

  factory MedicineTime.fromJson(Map<String, dynamic> json) {
    try {
      return MedicineTime(
        time: json['time'] as String?,
        beforeMeal: json['before_meal'] as bool? ?? false,
        afterMeal: json['after_meal'] as bool? ?? false,
      );
    } catch (e) {
      print('Error parsing MedicineTime: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'before_meal': beforeMeal,
      'after_meal': afterMeal,
    };
  }

  @override
  String toString() {
    return 'MedicineTime(time: $time, beforeMeal: $beforeMeal, afterMeal: $afterMeal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicineTime &&
        other.time == time &&
        other.beforeMeal == beforeMeal &&
        other.afterMeal == afterMeal;
  }

  @override
  int get hashCode {
    return time.hashCode ^
        beforeMeal.hashCode ^
        afterMeal.hashCode;
  }
}

class ImageModel {
  final String? url;
  final String? filename;
  final String? mimeType;
  final int? size;

  ImageModel({
    this.url,
    this.filename,
    this.mimeType,
    this.size,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    try {
      return ImageModel(
        url: json['url'] as String?,
        filename: json['filename'] as String?,
        mimeType: json['mime_type'] as String?,
        size: json['size'] as int?,
      );
    } catch (e) {
      print('Error parsing ImageModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'filename': filename,
      'mime_type': mimeType,
      'size': size,
    };
  }

  @override
  String toString() {
    return 'ImageModel(url: $url, filename: $filename)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageModel &&
        other.url == url &&
        other.filename == filename &&
        other.mimeType == mimeType &&
        other.size == size;
  }

  @override
  int get hashCode {
    return url.hashCode ^
        filename.hashCode ^
        mimeType.hashCode ^
        size.hashCode;
  }
}
