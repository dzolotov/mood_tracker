import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  
  // Keys for secure storage
  static const String _tokenKey = 'firebase_token';
  static const String _refreshTokenKey = 'firebase_refresh_token';
  static const String _userIdKey = 'firebase_user_id';
  static const String _emailKey = 'user_email';
  static const String _passwordKey = 'user_password'; // для автозаполнения
  
  // Save Firebase tokens
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  static Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  // Save user credentials (for auto-login)
  static Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _passwordKey, value: password);
  }
  
  static Future<Map<String, String?>> getCredentials() async {
    final email = await _storage.read(key: _emailKey);
    final password = await _storage.read(key: _passwordKey);
    return {'email': email, 'password': password};
  }
  
  // Save user ID
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }
  
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }
  
  // Clear all secure data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  // Clear specific data
  static Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
  
  static Future<void> clearCredentials() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
  }
  
  // Check if token exists
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null;
  }
  
  // Get all stored keys (for debugging)
  static Future<Map<String, String>> getAllData() async {
    return await _storage.readAll();
  }
  
  // Delete auth token
  Future<void> deleteAuthToken() async {
    await _storage.delete(key: _tokenKey);
  }
  
  // Delete refresh token (if exists)
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: 'refresh_token');
  }
  
  // Methods for cleanup integration test
  Future<void> saveEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }
  
  Future<void> savePassword(String password) async {
    await _storage.write(key: _passwordKey, value: password);
  }
  
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }
  
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}