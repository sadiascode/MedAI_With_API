import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../app/urls.dart';
import '../models/dashboard_model.dart';

class DashboardService {
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

  static Future<DashboardModel> getDashboardData({DateTime? date}) async {
    try {
      // Build request URL
      final url = Urls.homeDashboard(date: date);
      
      print(' Fetching dashboard data from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print(' Dashboard API Response status: ${response.statusCode}');
      print('Dashboard API Response body: ${response.body}');

      // Handle different response codes
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          
          // Validate response structure
          if (responseData.isEmpty) {
            return DashboardModel.empty();
          }
          
          return DashboardModel.fromJson(responseData);
        } catch (parseError) {
          print(' JSON parsing error: $parseError');
          throw Exception('Failed to parse dashboard response: $parseError');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        return DashboardModel.empty(); // No data for this date
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to load dashboard data: ${response.statusCode} - $errorMessage');
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
