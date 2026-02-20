import 'package:get_storage/get_storage.dart';

/// Centralized storage service for all app data
class AppStorageService {
  static final _box = GetStorage();

  // Token related methods - delegate to TokenStorageService
  static Future<void> storeAccessToken(String token) async {
    await _box.write('access_token', token);
    print('Access token stored');
  }

  static Future<void> storeRefreshToken(String token) async {
    await _box.write('refresh_token', token);
    print(' Refresh token stored');
  }

  static Future<String?> getStoredToken() async {
    final token = _box.read('access_token');
    print('Retrieved access token: ${token != null ? 'Found' : 'Not found'}');
    return token;
  }

  static Future<String?> getStoredRefreshToken() async {
    return _box.read('refresh_token');
  }

  static Future<void> clearTokens() async {
    await _box.remove('access_token');
    await _box.remove('refresh_token');
    print('All tokens cleared');
  }

  static bool isLoggedIn() {
    final token = _box.read('access_token');
    return token != null && token.isNotEmpty;
  }

  // Profile image storage
  static Future<void> storeProfileImagePath(String path) async {
    await _box.write('profile_image_path', path);
    print('Profile image path stored');
  }

  static Future<String?> getProfileImagePath() async {
    return _box.read('profile_image_path');
  }

  static Future<void> clearProfileImagePath() async {
    await _box.remove('profile_image_path');
    print(' Profile image path cleared');
  }

  // User preferences
  static Future<void> storeUserPreference(String key, dynamic value) async {
    await _box.write('user_pref_$key', value);
  }

  static Future<dynamic> getUserPreference(String key) async {
    return _box.read('user_pref_$key');
  }

  static Future<void> clearUserPreference(String key) async {
    await _box.remove('user_pref_$key');
  }

  // App settings
  static Future<void> storeAppSetting(String key, dynamic value) async {
    await _box.write('app_setting_$key', value);
  }

  static Future<dynamic> getAppSetting(String key) async {
    return _box.read('app_setting_$key');
  }

  // Clear all app data (except tokens)
  static Future<void> clearAppData() async {
    await _box.remove('profile_image_path');
    // Add other app data keys here as needed
    print(' App data cleared');
  }

  // Clear everything (for logout/reset)
  static Future<void> clearAll() async {
    await _box.erase();
    print(' All storage cleared');
  }
}
