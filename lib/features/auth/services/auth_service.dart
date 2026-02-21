import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../app/urls.dart';
import '../data/signup_model.dart';

class AuthService {
  // Static properties for current user session
  // In a real app, these would be managed dynamically
  static int currentUserId = 0;
  static String currentToken = '';
  static bool isLoggedIn = false;

  /// Initialize user session (call after successful login)
  static void initializeUserSession(int userId, String token) {
    currentUserId = userId;
    currentToken = token;
    isLoggedIn = true;
    
    // Persist to local storage
    final box = GetStorage();
    box.write('user_id', userId);
    box.write('access_token', token);
    
    print('✅ User session initialized and persisted: ID=$userId');
  }

  /// Try to restore session from local storage
  static bool tryAutoLogin() {
    final box = GetStorage();
    final int? savedUserId = box.read('user_id');
    final String? savedToken = box.read('access_token');

    if (savedUserId != null && savedUserId != 0 && savedToken != null && savedToken.isNotEmpty) {
      currentUserId = savedUserId;
      currentToken = savedToken;
      isLoggedIn = true;
      print('♻️ Persistent session restored: ID=$savedUserId');
      return true;
    }
    return false;
  }

  /// Clear user session (call after logout)
  static void clearUserSession() {
    currentUserId = 0;
    currentToken = '';
    isLoggedIn = false;
    
    // Clear local storage
    final box = GetStorage();
    box.remove('user_id');
    box.remove('access_token');
    
    print('🔒 User session cleared and persistence removed');
  }

  /// Get current user ID
  static int getCurrentUserId() {
    return currentUserId;
  }

  /// Get current auth token
  static String getCurrentToken() {
    return currentToken;
  }

  /// Check if user is logged in
  static bool isUserLoggedIn() {
    return isLoggedIn;
  }

  static Future<Map<String, dynamic>> signup(SignupMode signupData) async {
    try {
      final response = await http.post(
        Uri.parse(Urls.Signup),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(signupData.toJson()),
      );

      // Handle different response scenarios
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Success response
        return {
          'success': true,
          'message': 'User registered successfully',
          'data': jsonDecode(response.body),
        };
      } else if (response.statusCode == 400) {
        // Validation error or duplicate email
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Validation failed',
          'errors': errorData['errors'] ?? {},
        };
      } else if (response.statusCode == 409) {
        // Email already exists
        return {
          'success': false,
          'message': 'Email already exists',
          'errors': {'email': 'This email is already registered'},
        };
      } else {
        // Server error
        return {
          'success': false,
          'message': 'Server error occurred. Please try again later.',
          'errors': {},
        };
      }
    } catch (e) {
      // Network or parsing error
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
        'errors': {},
      };
    }
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }
}
