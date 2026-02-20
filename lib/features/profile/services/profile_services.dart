import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../app/urls.dart';
import '../models/profile_model.dart';
import '../models/delete_account_request_model.dart';
import '../models/change_password_model.dart';

class ProfileService {
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

  static Future<ProfileModel> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse(Urls.profile),
        headers: _getAuthHeaders(),
      );

      print('Profile API response status: ${response.statusCode}');
      print('Profile API response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Profile data parsed: $data');
        return ProfileModel.fromJson(data);
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading profile: $e');
    }
  }

  static Future<ProfileModel> updateProfile({
    required ProfileModel profile,
    String? imagePath,
  }) async {
    try {
      final request = http.MultipartRequest('PUT', Uri.parse(Urls.update_profile));
      
      // Add authorization header
      final token = box.read('access_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Prepare profile data with proper formatting
      final Map<String, String> profileData = {
        'full_name': profile.fullName,
        'email': profile.email,
        if (profile.address != null) 'address': profile.address!,
        if (profile.age != null) 'age': profile.age.toString(),
        if (profile.healthCondition != null) 'health_condition': profile.healthCondition!,
        if (profile.wakeupTime != null) 
          'wakeup_time': _formatTime(profile.wakeupTime!),
        if (profile.breakfastTime != null) 
          'breakfast_time': _formatTime(profile.breakfastTime!),
        if (profile.lunchTime != null) 
          'lunch_time': _formatTime(profile.lunchTime!),
        if (profile.dinnerTime != null) 
          'dinner_time': _formatTime(profile.dinnerTime!),
      };
      
      // Add fields to request
      profileData.forEach((key, value) {
        request.fields[key] = value;
      });
      
      // Add image file if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        final imageFile = await http.MultipartFile.fromPath(
          'profile_picture',
          imagePath,
        );
        request.files.add(imageFile);
      }
      
      print('Sending to API: ${request.fields}');
      print('Sending image: $imagePath');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Update profile response status: ${response.statusCode}');
      print('Update profile response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Profile updated successfully: $data');
        return ProfileModel.fromJson(data);
      } else {
        String errorMessage = 'Failed to update profile';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
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
      print('Update Profile Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Helper method to format time to HH:mm:ss
  static String _formatTime(String timeString) {
    try {
      // Try parsing different time formats
      List<String> formats = ['HH:mm:ss', 'HH:mm', 'h:mm a', 'h:mm:ss a'];
      
      for (String format in formats) {
        try {
          final time = DateFormat(format).parse(timeString);
          return DateFormat('HH:mm:ss').format(time);
        } catch (e) {
          continue;
        }
      }
      
      // If parsing fails, return original string or default format
      if (timeString.contains(':')) {
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hours = parts[0].padLeft(2, '0');
          final minutes = parts[1].padLeft(2, '0');
          final seconds = parts.length > 2 ? parts[2].padLeft(2, '0') : '00';
          return '$hours:$minutes:$seconds';
        }
      }
      
      // Return default format if all parsing fails
      return '08:00:00';
    } catch (e) {
      return '08:00:00';
    }
  }

  // Helper method to convert 24-hour time to 12-hour AM/PM format for UI
  static String formatTimeForUI(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return 'Not provided';
    }
    
    try {
      // Parse the time string
      List<String> formats = ['HH:mm:ss', 'HH:mm', 'h:mm a', 'h:mm:ss a'];
      DateTime? parsedTime;
      
      for (String format in formats) {
        try {
          parsedTime = DateFormat(format).parse(timeString);
          break;
        } catch (e) {
          continue;
        }
      }
      
      if (parsedTime == null) {
        // Try manual parsing
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          parsedTime = DateTime(2024, 1, 1, hour % 24, minute);
        }
      }
      
      if (parsedTime != null) {
        return DateFormat('h:mm a').format(parsedTime);
      }
      
      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  static Future<String?> getLocalImagePath() async {
    return box.read('profile_image_path');
  }

  static Future<void> signOut() async {
    try {
      // Call logout API first
      final token = box.read('access_token');
      final refreshToken = box.read('refresh_token');

      if (token != null && token.isNotEmpty) {
        final logoutData = {
          'refresh': refreshToken ?? '',
        };

        final response = await http.post(
          Uri.parse(Urls.Log_Out),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(logoutData),
        );

        print('Logout API Response status: ${response.statusCode}');
        print('Logout API Response body: ${response.body}');
      }

      // Clear stored tokens
      await box.remove('access_token');
      await box.remove('refresh_token');
      print('User signed out successfully');
    } catch (e) {
      print('Error during logout: $e');
      // Still clear tokens even if API call fails
      await box.remove('access_token');
      await box.remove('refresh_token');
      throw Exception('Error signing out: $e');
    }
  }

  static Future<String> uploadProfilePicture(String imagePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Urls.profile}picture/'),
      );

      final imageFile = await http.MultipartFile.fromPath(
        'profile_picture',
        imagePath,
      );

      request.files.add(imageFile);

      // Add authorization header if token exists
      final token = box.read('access_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Content-Type'] = 'multipart/form-data';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['profile_picture'] ?? '';
      } else {
        throw Exception(
          'Failed to upload profile picture: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error uploading profile picture: $e');
    }
  }

  static Future<bool> deleteAccount(String password) async {
    try {
      // Check if token exists before making request
      final token = box.read('access_token');
      print(' Raw token from storage: "$token"');
      print(' Token is null: ${token == null}');
      print(' Token is empty: ${token?.isEmpty ?? true}');
      print(' Token length: ${token?.length ?? 0}');
      
      if (token == null || token.isEmpty) {
        print(' No access token found - user not authenticated');
        throw Exception('Authentication required: Please log in again');
      }

      // Use correct endpoint for deleting user's own account
      final deleteUrl = Urls.delete_account;
      final deleteRequest = DeleteAccountRequestModel(password: password);

      print(' Delete Account Request URL: $deleteUrl');
      print(' Request body: ${deleteRequest.toJson()}');
      print(' Full Authorization header: "Authorization: Bearer $token"');

      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(deleteRequest.toJson()),
      );

      print(' Delete Account Response status: ${response.statusCode}');
      print(' Delete Account Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print(' Account deleted successfully');
        return true;
      } else if (response.statusCode == 401) {
        print(' Authentication failed - token expired or invalid');
        throw Exception('Session expired: Please log in again');
      } else if (response.statusCode == 403) {
        print(' Permission denied - insufficient privileges');
        throw Exception('Permission denied: You do not have permission to delete this account');
      } else {
        // Extract backend error message from response.body
        String errorMessage = 'Failed to delete account';
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['message'] != null) {
            errorMessage = responseData['message'];
          } else if (responseData['error'] != null) {
            errorMessage = responseData['error'];
          } else if (responseData['detail'] != null) {
            errorMessage = responseData['detail'];
          } else if (responseData['non_field_errors'] != null) {
            errorMessage = responseData['non_field_errors'][0];
          }
        } catch (e) {
          print(' Error parsing response: $e');
          errorMessage = 'Server error: ${response.statusCode}';
        }
        
        print(' Delete Account Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print(' Network error during delete: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final changeRequest = ChangePasswordModel(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final response = await http.post(
        Uri.parse(Urls.Change_Password),
        headers: _getAuthHeaders(),
        body: jsonEncode(changeRequest.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        String errorMessage = 'Failed to change password';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['current_password'] != null) {
            errorMessage = errorData['current_password'];
          } else if (errorData['new_password'] != null) {
            errorMessage = errorData['new_password'];
          } else if (errorData['confirm_password'] != null) {
            errorMessage = errorData['confirm_password'];
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
      throw Exception('Network error: $e');
    }
  }
}