import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../app/urls.dart';
import '../models/chat_model.dart';
import '../models/chat_history_model.dart';

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
      final url = Urls.Chat_Bot;
      print(' Sending text chat message (JSON) to: $url');
      print(' User ID: $userId, Text: $text');

      final Map<String, dynamic> requestBody = {
        "text": text,
        "user_id": userId,
        "reply_mode": "text"
      };

      final response = await http.post(
        Uri.parse(url),
        headers: _getAuthHeaders(), // This already includes Application/JSON
        body: jsonEncode(requestBody),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print(' Chat API Response status: ${response.statusCode}');
      print(' Chat API Response body: ${response.body}');

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
    } catch (e) {
      print(' Unexpected error: $e');
      throw Exception('Unexpected error occurred: $e');
    }
  }

  static Future<Map<String, dynamic>> sendPrescriptionImage({
    required File imageFile,
    required int userId,
  }) async {
    try {
      final url = Urls.Chat_Bot;
      print(' Sending prescription image to: $url');
      print(' User ID: $userId, File path: ${imageFile.path}');

      final request = http.MultipartRequest('POST', Uri.parse(url));
      
      // Add authentication headers
      final headers = _getAuthHeaders();
      headers.remove('Content-Type'); // Multipart handles its own content type
      request.headers.addAll(headers);

      // Add fields matching Postman
      request.fields['user_id'] = userId.toString();
      request.fields['reply_mode'] = 'text';

      // Add file matching Postman field name 'file'
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      print(' Request fields: ${request.fields}');
      print(' Request files: ${request.files.map((f) => f.field).toList()}');

      final streamedResponse = await request.send().timeout(
        Duration(seconds: 60),
        onTimeout: () => throw Exception('Request timeout'),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print(' Prescription AI API Response status: ${response.statusCode}');
      print(' Prescription AI API Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          return responseData;
        } catch (e) {
          print(' JSON parsing error: $e');
          throw Exception('Failed to parse prescription response: $e');
        }
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to analyze prescription: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print(' Unexpected error in sendPrescriptionImage: $e');
      throw Exception('Unexpected error occurred: $e');
    }
  }

  static Future<ChatHistoryModel> getChatHistory({int? userId}) async {
    try {
      String url = Urls.Chat_History;
      if (userId != null && userId != 0) {
        url = "$url?user_id=$userId";
      }
      print(' Fetching chat history from: $url');

      final headers = _getAuthHeaders();
      print(' History Headers: $headers');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print(' History API Response status: ${response.statusCode}');
      print(' History API Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return ChatHistoryModel.fromJson(responseData);
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to fetch history: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      print(' Error fetching history: $e');
      throw Exception('Unexpected error occurred while fetching history: $e');
    }
  }

  static String _extractErrorMessage(http.Response response) {
    try {
      if (response.body.isEmpty) return 'No response body from server';
      final Map<String, dynamic> errorData = json.decode(response.body);
      return errorData['message'] ?? 
             errorData['error'] ?? 
             errorData['detail'] ?? 
             errorData['response'] ??
             'Unknown error (${response.statusCode})';
    } catch (e) {
      print(' Error extracting error message: $e');
      return response.body.isNotEmpty ? response.body : 'Status ${response.statusCode}';
    }
  }
}