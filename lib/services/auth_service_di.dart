import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage_service.dart';

/// AuthService с поддержкой Dependency Injection для улучшенного тестирования
class AuthServiceDI extends ChangeNotifier {
  static const String _usernameKey = 'username';
  static const String _isLoggedInKey = 'is_logged_in';
  
  final FirebaseAuth _firebaseAuth;
  final SharedPreferences? _sharedPreferences;
  User? _user;
  String? _username;
  bool _isLoggedIn = false;
  String? _errorMessage;
  bool _isInitialized = false;
  
  // Getters
  User? get user => _user;
  String? get username => _username;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  String? get userEmail => _user?.email;
  String? get displayName => _user?.displayName ?? _username;
  bool get isInitialized => _isInitialized;
  
  /// Конструктор с поддержкой DI
  AuthServiceDI({
    FirebaseAuth? firebaseAuth,
    SharedPreferences? sharedPreferences,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _sharedPreferences = sharedPreferences {
    _initializeAuth();
  }
  
  /// Инициализация аутентификации
  Future<void> _initializeAuth() async {
    try {
      // Слушаем изменения состояния аутентификации
      _firebaseAuth.authStateChanges().listen((User? user) async {
        _user = user;
        _isLoggedIn = user != null;
        
        if (user != null) {
          // Сохраняем ID пользователя и токен в secure storage
          await SecureStorageService.saveUserId(user.uid);
          final idToken = await user.getIdToken();
          if (idToken != null) {
            await SecureStorageService.saveToken(idToken);
          }
          
          // Загружаем username из SharedPreferences
          final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
          _username = prefs.getString(_usernameKey) ?? user.email?.split('@')[0];
        }
        
        notifyListeners();
      });
      
      // Пытаемся восстановить сессию
      await _loadAuthState();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Ошибка инициализации: $e';
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  /// Загрузка сохраненного состояния аутентификации
  Future<void> _loadAuthState() async {
    try {
      final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
      _username = prefs.getString(_usernameKey);
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      // Если есть сохраненная сессия, пытаемся автоматически войти
      if (_isLoggedIn) {
        final credentials = await SecureStorageService.getCredentials();
        if (credentials['email'] != null && credentials['password'] != null) {
          await loginWithEmail(
            credentials['email']!,
            credentials['password']!,
            saveCredentials: false,
          );
        }
      }
    } catch (e) {
      // Игнорируем ошибки при загрузке состояния
      _isLoggedIn = false;
    }
  }
  
  /// Вход с email и паролем
  Future<bool> loginWithEmail(
    String email,
    String password, {
    bool saveCredentials = false,
  }) async {
    try {
      _errorMessage = null;
      
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _user = credential.user;
        _username = email.split('@')[0];
        _isLoggedIn = true;

        // Сохраняем данные в SharedPreferences
        final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
        await prefs.setString(_usernameKey, _username!);
        await prefs.setBool(_isLoggedInKey, true);

        // Сохраняем учетные данные если нужно
        if (saveCredentials) {
          await SecureStorageService.saveCredentials(email, password);
        }

        // Сохраняем токены
        final idToken = await _user!.getIdToken();
        if (idToken != null) {
          await SecureStorageService.saveToken(idToken);
        }
        await SecureStorageService.saveUserId(_user!.uid);
        
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = 'Произошла ошибка: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Регистрация нового пользователя
  Future<bool> register(String email, String password) async {
    try {
      _errorMessage = null;
      
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _user = credential.user;
        _username = email.split('@')[0];
        _isLoggedIn = true;

        // Сохраняем данные
        final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
        await prefs.setString(_usernameKey, _username!);
        await prefs.setBool(_isLoggedInKey, true);

        // Сохраняем токены
        final idToken = await _user!.getIdToken();
        if (idToken != null) {
          await SecureStorageService.saveToken(idToken);
        }
        await SecureStorageService.saveUserId(_user!.uid);
        
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = 'Произошла ошибка: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Выход из системы
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _user = null;
      _username = null;
      _isLoggedIn = false;
      _errorMessage = null;

      // Очищаем сохраненные данные
      final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
      await prefs.remove(_usernameKey);
      await prefs.remove(_isLoggedInKey);

      // Очищаем secure storage
      await SecureStorageService.clearAll();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Ошибка при выходе: $e';
      notifyListeners();
    }
  }
  
  /// Сброс пароля
  Future<bool> resetPassword(String email) async {
    try {
      _errorMessage = null;
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = 'Ошибка сброса пароля: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Обновление отображаемого имени
  Future<bool> updateDisplayName(String displayName) async {
    try {
      _errorMessage = null;
      
      if (_user != null) {
        await _user!.updateDisplayName(displayName);
        await _user!.reload();
        _user = _firebaseAuth.currentUser;
        
        // Сохраняем в SharedPreferences
        final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
        await prefs.setString(_usernameKey, displayName);
        _username = displayName;
        
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = 'Ошибка обновления имени: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Обновление email
  Future<bool> updateEmail(String newEmail) async {
    try {
      _errorMessage = null;
      
      if (_user != null) {
        await _user!.verifyBeforeUpdateEmail(newEmail);
        _errorMessage = 'Проверьте почту $newEmail для подтверждения изменения';
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = 'Ошибка обновления email: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Повторная аутентификация
  Future<bool> reauthenticate(String password) async {
    try {
      _errorMessage = null;
      
      if (_user != null && _user!.email != null) {
        final credential = EmailAuthProvider.credential(
          email: _user!.email!,
          password: password,
        );
        
        await _user!.reauthenticateWithCredential(credential);
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = 'Ошибка аутентификации: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Удаление аккаунта
  Future<bool> deleteAccount(String password) async {
    try {
      _errorMessage = null;
      
      // Сначала повторно аутентифицируемся
      if (!await reauthenticate(password)) {
        return false;
      }
      
      // Удаляем аккаунт
      await _user?.delete();
      
      // Очищаем все данные
      await logout();
      
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
      return false;
    } catch (e) {
      _errorMessage = 'Ошибка удаления аккаунта: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Получение ID токена
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await _user?.getIdToken(forceRefresh);
    } catch (e) {
      _errorMessage = 'Ошибка получения токена: $e';
      notifyListeners();
      return null;
    }
  }
  
  /// Простой вход (legacy метод для совместимости)
  Future<bool> login(String username, String password) async {
    // Предполагаем, что username это email
    return await loginWithEmail(username, password);
  }
  
  /// Очистка сообщения об ошибке
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Обработка исключений Firebase Auth
  void _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        _errorMessage = 'Пользователь с таким email не найден';
        break;
      case 'wrong-password':
        _errorMessage = 'Неверный пароль';
        break;
      case 'invalid-email':
        _errorMessage = 'Неверный формат email';
        break;
      case 'user-disabled':
        _errorMessage = 'Учетная запись отключена';
        break;
      case 'weak-password':
        _errorMessage = 'Пароль слишком слабый';
        break;
      case 'email-already-in-use':
        _errorMessage = 'Email уже используется';
        break;
      case 'requires-recent-login':
        _errorMessage = 'Требуется повторная аутентификация';
        break;
      default:
        _errorMessage = 'Ошибка аутентификации: ${e.message}';
    }
    notifyListeners();
  }
  
}