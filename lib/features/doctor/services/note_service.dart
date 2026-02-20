import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../app/urls.dart';
import '../models/note_model.dart';

class NoteService {
  static final box = GetStorage();

  static Map<String, String> _getAuthHeaders() {
    final token = box.read('access_token');
    print('Retrieved token: ${token != null ? "Bearer ${token.substring(0, 10)}..." : "No token found"}');

    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<bool> addNote({
    required int doctorId,
    required String note,
  }) async {
    try {
      final noteModel = NoteModel(note: note);

      print('Adding note for doctor $doctorId: ${noteModel.toJson()}');

      final response = await http.post(
        Uri.parse(Urls.addNote(doctorId)),
        headers: _getAuthHeaders(),
        body: jsonEncode(noteModel.toJson()),
      );

      print('Add note response status: ${response.statusCode}');
      print('Add note response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Note added successfully');
        return true;
      } else {
        String errorMessage = 'Failed to add note';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['note'] != null) {
            errorMessage = errorData['note'];
          } else if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          errorMessage = response.body.isNotEmpty ? response.body : 'Something went wrong';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error adding note: $e');
      throw Exception('Network error: $e');
    }
  }
}
