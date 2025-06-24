import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  static const String _usernameKey = 'username';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _correctPassword = 'password';
  
  String? _username;
  bool _isLoggedIn = false;
  
  String? get username => _username;
  bool get isLoggedIn => _isLoggedIn;
  
  AuthService() {
    _loadAuthState();
  }
  
  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString(_usernameKey);
    _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    notifyListeners();
  }
  
  Future<bool> login(String username, String password) async {
    if (password != _correctPassword) {
      return false;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    await prefs.setBool(_isLoggedInKey, true);
    
    _username = username;
    _isLoggedIn = true;
    notifyListeners();
    
    return true;
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.setBool(_isLoggedInKey, false);
    
    _username = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}