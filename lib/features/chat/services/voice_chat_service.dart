import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../../../app/urls.dart';
import '../models/chat_model.dart';

final chatBox = GetStorage();

class VoiceChatService {
  static Map<String, String> _getAuthHeaders() {
    final token = chatBox.read('access_token');
    print('Retrieved token: ${token != null ? "Bearer ${token.substring(0, 10)}..." : "No token found"}');

    final headers = <String, String>{};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<ChatModel> sendVoiceMessage({
    required String audioPath,
    required int userId,
  }) async {
    try {

      final audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found: $audioPath');
      }


      final fileSize = await audioFile.length();
      if (fileSize == 0) {
        throw Exception('Audio file is empty: $audioPath');
      }

      print(' Sending voice message: $audioPath (${fileSize} bytes)');


      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Urls.Chat_Bot),
      );


      request.headers.addAll(_getAuthHeaders());


      request.fields['user_id'] = userId.toString();
      request.fields['reply_mode'] = 'voice';


      final audioFileBytes = await audioFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'audio',
        audioFileBytes,
        filename: path.basename(audioPath),
      );
      request.files.add(multipartFile);

      print(' Request fields: ${request.fields}');
      print(' Request files: ${request.files.map((f) => f.field + ": " + (f.filename ?? "no filename")).join(", ")}');


      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print(' Voice API Response status: ${response.statusCode}');
      print(' Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          
          if (responseData.isEmpty) {
            print(' Empty response from voice API');
            throw Exception('Empty response from server');
          }
          
          final voiceResponse = ChatModel.fromJson(responseData);
          print(' Voice message sent successfully');
          return voiceResponse;
        } catch (parseError) {
          print(' JSON parsing error: $parseError');
          throw Exception('Failed to parse voice response: $parseError');
        }
      } else if (response.statusCode == 401) {
        print(' Authentication failed');
        throw Exception('Authentication failed');
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to send voice message: ${response.statusCode} - $errorMessage');
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

  static Future<void> cleanupTempFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print(' Cleaned up temporary file: $filePath');
      }
    } catch (e) {
      print(' Failed to cleanup temporary file: $e');
    }
  }
}
