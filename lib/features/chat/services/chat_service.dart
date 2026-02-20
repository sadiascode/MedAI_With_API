import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../app/urls.dart';
import '../models/chat_model.dart';

final chatBox = GetStorage();
final chatToken = chatBox.read('access_token');

class ChatService {
  static Map<String, String> _getAuthHeaders() {
    final token = chatBox.read('access_token');
    print(
      'Retrieved token: ${token != null ? "Bearer ${token.substring(0, 10)}..." : "No token found"}',
    );

    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<ChatModel> sendMessage(String text, int userId, {String? token}) async {
    try {
      final Map<String, dynamic> requestBody = {
        "text": text,
        "user_id": userId,
        "reply_mode": "text"
      };

      final url = Urls.Chat_Bot;
      
      print(' Sending chat message to: $url');
      print(' Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: _getAuthHeaders(),
        body: jsonEncode(requestBody),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print(' Chat API Response status: ${response.statusCode}');
      print(' Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          
          if (responseData.isEmpty) {
            print(' Empty response from chat API');
            throw Exception('Empty response from server');
          }
          
          final chatResponse = ChatModel.fromJson(responseData);
          print(' Chat message sent successfully');
          return chatResponse;
        } catch (parseError) {
          print(' JSON parsing error: $parseError');
          throw Exception('Failed to parse chat response: $parseError');
        }
      } else if (response.statusCode == 401) {
        print(' Authentication failed');
        throw Exception('Authentication failed');
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to send message: ${response.statusCode} - $errorMessage');
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
             errorData['response'] ??
             'Unknown error';
    } catch (_) {
      return response.body.isNotEmpty ? response.body : 'No error details';
    }
  }
}