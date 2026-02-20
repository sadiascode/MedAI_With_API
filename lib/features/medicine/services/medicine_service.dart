import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../app/urls.dart';
import '../models/medicine_model.dart';

class MedicineService {
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

  static Future<List<MedicineModel>> fetchMedicines() async {
    try {
      final url = Urls.All_Medicine;
      
      print('🔍 Fetching medicines from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('📊 Medicines API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> responseData = json.decode(response.body);
          
          if (responseData.isEmpty) {
            print('📝 No medicines found in response');
            return [];
          }
          
          final medicines = responseData
              .map((item) => MedicineModel.fromJson(item as Map<String, dynamic>))
              .where((medicine) => medicine.id > 0 && medicine.name.isNotEmpty)
              .toList();
          
          print('✅ Successfully parsed ${medicines.length} medicines');
          return medicines;
        } catch (parseError) {
          print('❌ JSON parsing error: $parseError');
          throw Exception('Failed to parse medicines response: $parseError');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        print('📝 No medicines found (404)');
        return [];
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to load medicines: ${response.statusCode} - $errorMessage');
      }
    } on http.ClientException catch (e) {
      print('🌐 Network error: $e');
      throw Exception('Network connection failed: ${e.message}');
    } on FormatException catch (e) {
      print('📝 Format error: $e');
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      print('💥 Unexpected error: $e');
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
