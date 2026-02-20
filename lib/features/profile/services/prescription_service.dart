import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../app/urls.dart';
import '../models/prescription_model.dart';

class PrescriptionService {
  static final box = GetStorage();

  static Map<String, String> _getAuthHeaders() {
    final token = box.read('access_token');
    print(
      'Retrieved token: ${token != null ? "Bearer ${token.substring(0, 10)}..." : "No token found"}',
    );

    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<List<PrescriptionModel>> getAllPrescriptions() async {
    try {
      final url = Urls.Get_all_prescriptions;
      
      print(' Fetching all prescriptions from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print(' Prescriptions API Response status: ${response.statusCode}');
      print(' Prescriptions API Response body: ${response.body}');

      // Handle different response codes
      if (response.statusCode == 200) {
        try {
          final List<dynamic> responseData = json.decode(response.body);
          
          // Validate response structure
          if (responseData.isEmpty) {
            return [];
          }
          
          return responseData
              .map((item) => PrescriptionModel.fromJson(item as Map<String, dynamic>))
              .where((prescription) => prescription.id > 0)
              .toList();
        } catch (parseError) {
          print(' JSON parsing error: $parseError');
          throw Exception('Failed to parse prescriptions response: $parseError');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        return []; // No prescriptions found
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to load prescriptions: ${response.statusCode} - $errorMessage');
      }
    } on http.ClientException catch (e) {
      print(' Network error: $e');
      throw Exception('Network connection failed: ${e.message}');
    } on FormatException catch (e) {
      print(' Format error: $e');
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      print(' Unexpected error: $e');
      throw Exception('Unexpected error occurred: $e');
    }
  }

  static Future<PrescriptionModel> getPrescriptionById(int prescriptionId) async {
    try {
      final url = '${Urls.Get_all_prescriptions}$prescriptionId/';
      
      print(' Fetching prescription details from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print(' Prescription Detail API Response status: ${response.statusCode}');
      print(' Prescription Detail API Response body: ${response.body}');

      // Handle different response codes
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          
          // Validate response structure
          if (responseData.isEmpty) {
            return PrescriptionModel.empty();
          }
          
          return PrescriptionModel.fromJson(responseData);
        } catch (parseError) {
          print(' JSON parsing error: $parseError');
          throw Exception('Failed to parse prescription response: $parseError');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Prescription not found');
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to load prescription: ${response.statusCode} - $errorMessage');
      }
    } on http.ClientException catch (e) {
      print(' Network error: $e');
      throw Exception('Network connection failed: ${e.message}');
    } on FormatException catch (e) {
      print(' Format error: $e');
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      print(' Unexpected error: $e');
      throw Exception('Unexpected error occurred: $e');
    }
  }

  static Future<bool> deletePrescription(int id) async {
    try {
      final url = Urls.deletePrescription(id);
      
      print(' Deleting prescription from: $url');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('️ Delete prescription response status: ${response.statusCode}');
      print(' Delete prescription response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print(' Prescription deleted successfully');
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Prescription not found');
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to delete prescription: ${response.statusCode} - $errorMessage');
      }
    } on http.ClientException catch (e) {
      print(' Network error: $e');
      throw Exception('Network connection failed: ${e.message}');
    } on FormatException catch (e) {
      print(' Format error: $e');
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      print(' Unexpected error: $e');
      throw Exception('Unexpected error occurred: $e');
    }
  }

  static String _extractErrorMessage(http.Response response) {
    try {
      final Map<String, dynamic> errorData = json.decode(response.body);
      return errorData['message'] ?? 
             errorData['error'] ?? 
             errorData['detail'] ?? 
             'Unknown error';
    } catch (_) {
      return response.body.isNotEmpty ? response.body : 'No error details';
    }
  }
}
