import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../app/urls.dart';
import '../models/doctor_list_model.dart';
import '../models/doctor_model.dart';

final box = GetStorage();

class DoctorApiService {
  static Future<List<DoctorListModel>> getDoctorList() async {
    try {
      final token = box.read('access_token'); // ✅ FIX

      final response = await http.get(
        Uri.parse(Urls.Doctor_list),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => DoctorListModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load doctor list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching doctor list: $e');
    }
  }

  static Future<DoctorModel> getSingleDoctor(int id) async {
    try {
      final token = box.read('access_token'); // ✅ FIX

      final response = await http.get(
        Uri.parse(Urls.singleDoctor(id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return DoctorModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load doctor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching doctor: $e');
    }
  }

  static Future<Map<String, dynamic>> addDoctor({
    required String name,
    required String sex,
    required String specialization,
    required String hospitalName,
    required String designation,
    required String doctorEmail,
  }) async {
    try {
      final token = box.read('access_token');

      final Map<String, dynamic> doctorData = {
        "name": name,
        "sex": sex,
        "specialization": specialization,
        "hospital_name": hospitalName,
        "designation": designation,
        "doctor_email": doctorEmail,
      };

      final response = await http.post(
        Uri.parse(Urls.Add_doctor),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(doctorData),
      );

      print('Add Doctor Response status: ${response.statusCode}');
      print('Add Doctor Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Doctor added successfully: $data');
        return data;
      } else {
        String errorMessage = 'Failed to add doctor';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['name'] != null) {
            errorMessage = errorData['name'];
          } else if (errorData['doctor_email'] != null) {
            errorMessage = errorData['doctor_email'];
          } else if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          errorMessage = response.body.isNotEmpty
              ? response.body
              : 'Something went wrong';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Add Doctor Error: $e');
      throw Exception('Network error: $e');
    }
  }
}