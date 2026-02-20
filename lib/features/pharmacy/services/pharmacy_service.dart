import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../../../app/urls.dart';
import '../models/pharmacy_model.dart';

class PharmacyService {
  static final box = GetStorage();

  static Map<String, String> _getAuthHeaders() {
    final token = box.read('access_token');
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<List<PharmacyModel>> fetchPharmacies() async {
    try {
      final response = await http.get(
        Uri.parse(Urls.Medicine_list),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData
            .map((item) => PharmacyModel.fromJson(item as Map<String, dynamic>))
            .where((pharmacy) => pharmacy.pharmacy_name.isNotEmpty)
            .toList();
      } else {
        throw Exception('Failed to load pharmacies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Creates a new pharmacy via POST request
  /// Returns the created pharmacy on success
  /// Throws Exception on failure
  static Future<PharmacyModel> addPharmacy({
    required String pharmacyName,
    required String pharmacyAddress,
    required String websiteUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Urls.Add_pharmacy),
        headers: _getAuthHeaders(),
        body: json.encode({
          'pharmacy_name': pharmacyName,
          'Pharmacy_Address': pharmacyAddress,
          'website_link': websiteUrl,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return PharmacyModel.fromJson(responseData);
      } else if (response.statusCode == 400) {
        throw Exception('Invalid data provided');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to add pharmacy: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      throw Exception('Error adding pharmacy: $e');
    }
  }
}
