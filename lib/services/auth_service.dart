import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage_service.dart';

class AuthService extends ChangeNotifier {
  static const String _usernameKey = 'username';
  static const String _isLoggedInKey = 'is_logged_in';
  
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;
  String? _username;
  bool _isLoggedIn = false;
  String? _errorMessage;
  
  User? get user => _user;
  String? get username => _username;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  String? get userEmail => _user?.email;
  String? get displayName => _user?.displayName ?? _username;
  
  AuthService() {
    _initializeAuth();
  }
  
  Future<void> _initializeAuth() async {
    try {
      // Listen to auth state changes
      _firebaseAuth.authStateChanges().listen((User? user) async {
        _user = user;
        _isLoggedIn = user != null;
        
        if (user != null) {
          // Save user ID and token in secure storage
          await SecureStorageService.saveUserId(user.uid);
          final idToken = await user.getIdToken();
          if (idToken != null) {
            await SecureStorageService.saveToken(idToken);
          }
          
          // Load username from SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          _username = prefs.getString(_usernameKey) ?? user.email?.split('@')[0];
        }
        
        notifyListeners();
      });
      
      // Try to restore session
      await _loadAuthState();
    } catch (e) {
      debugPrint('Firebase Auth initialization error: $e');
      // Continue without Firebase - fall back to local auth
      _errorMessage = 'Firebase не настроен. Используется локальная авторизация.';
      notifyListeners();
    }
  }
  
  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString(_usernameKey);
    _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    
    // Check if we have stored credentials for auto-login
    if (!_isLoggedIn && await SecureStorageService.hasToken()) {
      final credentials = await SecureStorageService.getCredentials();
      if (credentials['email'] != null && credentials['password'] != null) {
        await loginWithEmail(credentials['email']!, credentials['password']!, saveCredentials: false);
      }
    }
    
    notifyListeners();
  }
  
  // Email/Password Authentication
  Future<bool> loginWithEmail(String email, String password, {bool saveCredentials = true}) async {
    try {
      _errorMessage = null;
      
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        _user = credential.user;
        _isLoggedIn = true;
        
        // Save credentials in secure storage if requested
        if (saveCredentials) {
          await SecureStorageService.saveCredentials(email, password);
        }
        
        // Save username (email prefix) in SharedPreferences
        final username = email.split('@')[0];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_usernameKey, username);
        await prefs.setBool(_isLoggedInKey, true);
        
        _username = username;
        
        // Save tokens
        final idToken = await credential.user!.getIdToken();
        if (idToken != null) {
          await SecureStorageService.saveToken(idToken);
        }
        
        notifyListeners();
        return true;
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Пользователь не найден';
          break;
        case 'wrong-password':
          _errorMessage = 'Неверный пароль';
          break;
        case 'invalid-email':
          _errorMessage = 'Неверный формат email';
          break;
        case 'user-disabled':
          _errorMessage = 'Пользователь заблокирован';
          break;
        default:
          _errorMessage = 'Ошибка входа: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Неизвестная ошибка: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Register new user
  Future<bool> register(String email, String password) async {
    try {
      _errorMessage = null;
      
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Auto login after registration
        return await loginWithEmail(email, password);
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          _errorMessage = 'Пароль слишком простой';
          break;
        case 'email-already-in-use':
          _errorMessage = 'Email уже используется';
          break;
        case 'invalid-email':
          _errorMessage = 'Неверный формат email';
          break;
        default:
          _errorMessage = 'Ошибка регистрации: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Неизвестная ошибка: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Legacy login method (for backward compatibility)
  Future<bool> login(String username, String password) async {
    // Convert username to email format if needed
    String email = username;
    if (!username.contains('@')) {
      email = '$username@moodtracker.app';
    }
    
    return await loginWithEmail(email, password);
  }
  
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    
    // Clear stored data
    await SecureStorageService.clearAll();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.setBool(_isLoggedInKey, false);
    
    _user = null;
    _username = null;
    _isLoggedIn = false;
    _errorMessage = null;
    
    notifyListeners();
  }
  
  // Get fresh ID token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    if (_user != null) {
      return await _user!.getIdToken(forceRefresh);
    }
    return null;
  }
  
  // Password reset
  Future<bool> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _errorMessage = 'Ошибка сброса пароля: $e';
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Update user display name
  Future<bool> updateDisplayName(String displayName) async {
    try {
      if (_user != null) {
        await _user!.updateDisplayName(displayName);
        await _user!.reload();
        _user = _firebaseAuth.currentUser;
        
        // Save in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_usernameKey, displayName);
        _username = displayName;
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Ошибка обновления имени: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Update user email
  Future<bool> updateEmail(String newEmail) async {
    try {
      if (_user != null) {
        // Use verifyBeforeUpdateEmail for better security
        await _user!.verifyBeforeUpdateEmail(newEmail);
        _errorMessage = 'Проверьте почту $newEmail для подтверждения изменения';
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Ошибка обновления email: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Re-authenticate user before sensitive operations
  Future<bool> reauthenticate(String password) async {
    try {
      if (_user != null && _user!.email != null) {
        final credential = EmailAuthProvider.credential(
          email: _user!.email!,
          password: password,
        );
        
        await _user!.reauthenticateWithCredential(credential);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Ошибка аутентификации: $e';
      notifyListeners();
      return false;
    }
  }
  
  // Delete user account
  Future<bool> deleteAccount(String password) async {
    try {
      if (_user != null) {
        // Re-authenticate first
        final reauth = await reauthenticate(password);
        if (!reauth) return false;
        
        // Delete user
        await _user!.delete();
        
        // Clear all stored data
        await SecureStorageService.clearAll();
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        _user = null;
        _username = null;
        _isLoggedIn = false;
        _errorMessage = null;
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Ошибка удаления аккаунта: $e';
      notifyListeners();
      return false;
    }
  }
}