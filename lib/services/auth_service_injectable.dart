import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage_service.dart';

/// AuthService с поддержкой Dependency Injection для тестирования
class AuthServiceInjectable extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  User? _user;
  String? _username;
  bool _isLoggedIn = false;
  String? _errorMessage;

  // SharedPreferences keys
  static const String _usernameKey = 'username';
  static const String _isLoggedInKey = 'is_logged_in';

  User? get user => _user;
  String? get username => _username;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  String? get userEmail => _user?.email;
  String? get displayName => _user?.displayName;

  /// Конструктор с возможностью инжекции FirebaseAuth для тестирования
  AuthServiceInjectable({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _initializeAuth();
  }

  /// Инициализация сервиса
  Future<void> _initializeAuth() async {
    try {
      // Слушаем изменения состояния аутентификации
      _firebaseAuth.authStateChanges().listen((User? user) async {
        _user = user;
        _isLoggedIn = user != null;
        
        if (user != null) {
          // Сохраняем токен в secure storage
          final idToken = await user.getIdToken();
          if (idToken != null) {
            await SecureStorageService.saveToken(idToken);
          }
          await SecureStorageService.saveUserId(user.uid);
        }
        
        notifyListeners();
      });

      // Загружаем сохраненные данные
      await _loadSavedData();

      // Пытаемся автоматический вход
      await _attemptAutoLogin();
    } catch (e) {
      _errorMessage = 'Ошибка инициализации: Firebase не настроен';
      notifyListeners();
    }
  }

  /// Загрузка сохраненных данных
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString(_usernameKey);
    _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Попытка автоматического входа
  Future<void> _attemptAutoLogin() async {
    try {
      final credentials = await SecureStorageService.getCredentials();
      if (credentials['email'] != null && credentials['password'] != null) {
        await loginWithEmail(
          credentials['email']!,
          credentials['password']!,
          saveCredentials: false,
        );
      }
    } catch (e) {
      // Игнорируем ошибки автовхода
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

        // Сохраняем данные
        final prefs = await SharedPreferences.getInstance();
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
        final prefs = await SharedPreferences.getInstance();
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
      final prefs = await SharedPreferences.getInstance();
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
  Future<void> resetPassword(String email) async {
    try {
      _errorMessage = null;
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      _errorMessage = 'Произошла ошибка: $e';
      notifyListeners();
    }
  }

  /// Обновление отображаемого имени
  Future<void> updateDisplayName(String displayName) async {
    try {
      _errorMessage = null;
      await _user?.updateDisplayName(displayName);
      await _user?.reload();
      _user = _firebaseAuth.currentUser;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Ошибка обновления имени: $e';
      notifyListeners();
    }
  }

  /// Обновление email
  Future<void> updateEmail(String newEmail) async {
    try {
      _errorMessage = null;
      await _user?.updateEmail(newEmail);
      _username = newEmail.split('@')[0];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, _username!);
      
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      _errorMessage = 'Ошибка обновления email: $e';
      notifyListeners();
    }
  }

  /// Повторная аутентификация
  Future<bool> reauthenticate(String password) async {
    try {
      _errorMessage = null;
      if (_user?.email == null) return false;
      
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: password,
      );
      
      await _user!.reauthenticateWithCredential(credential);
      return true;
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

  @override
  void dispose() {
    super.dispose();
  }
}