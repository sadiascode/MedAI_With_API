import 'package:get_storage/get_storage.dart';

class TokenStorageService {
  static final _box = GetStorage();

  /// Store access token
  static Future<void> storeAccessToken(String token) async {
    await _box.write('access_token', token);
    print('Access token stored');
  }

  /// Store refresh token
  static Future<void> storeRefreshToken(String token) async {
    await _box.write('refresh_token', token);
    print('Refresh token stored');
  }

  /// Get stored access token
  static Future<String?> getStoredToken() async {
    final token = _box.read('access_token');
    print(' Retrieved access token: ${token != null ? 'Found' : 'Not found'}');
    return token;
  }

  /// Get stored refresh token
  static Future<String?> getStoredRefreshToken() async {
    return _box.read('refresh_token');
  }

  /// Clear all tokens
  static Future<void> clearTokens() async {
    await _box.remove('access_token');
    await _box.remove('refresh_token');
    print('🗑 All tokens cleared');
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    final token = _box.read('access_token');
    return token != null && token.isNotEmpty;
  }
}
