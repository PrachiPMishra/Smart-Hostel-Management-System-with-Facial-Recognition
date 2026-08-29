import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Secure storage for sensitive data (tokens, keys)
  static Future<void> saveSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> readSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  static Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  // Regular storage for non-sensitive data
  static Future<bool> saveString(String key, String value) async {
    return await _prefs!.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs!.getString(key);
  }

  static Future<bool> saveBool(String key, bool value) async {
    return await _prefs!.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs!.getBool(key);
  }

  static Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }

  static Future<bool> clear() async {
    return await _prefs!.clear();
  }

  // Auth-specific helpers
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserRole = 'user_role';

  static Future<void> saveAuthTokens(String accessToken, String refreshToken) async {
    await saveSecure(_keyAccessToken, accessToken);
    await saveSecure(_keyRefreshToken, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return await readSecure(_keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    return await readSecure(_keyRefreshToken);
  }

  static Future<void> clearAuthTokens() async {
    await deleteSecure(_keyAccessToken);
    await deleteSecure(_keyRefreshToken);
  }

  static Future<void> saveUserId(String userId) async {
    await saveString(_keyUserId, userId);
  }

  static String? getUserId() {
    return getString(_keyUserId);
  }

  static Future<void> saveUserRole(String role) async {
    await saveString(_keyUserRole, role);
  }

  static String? getUserRole() {
    return getString(_keyUserRole);
  }
}
