import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Callback = void Function(MethodCall call);

/// Mock implementation для Firebase Core
void setupFirebaseCoreMocks() {
  const MethodChannel channel = MethodChannel('plugins.flutter.io/firebase_core');
  
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Firebase#initializeCore':
          return [
            {
              'name': '[DEFAULT]',
              'options': {
                'apiKey': 'test-api-key',
                'appId': 'test-app-id',
                'messagingSenderId': 'test-sender-id',
                'projectId': 'test-project-id',
              },
              'pluginConstants': {},
            }
          ];
        case 'Firebase#initializeApp':
          return {
            'name': methodCall.arguments['appName'] ?? '[DEFAULT]',
            'options': methodCall.arguments['options'],
            'pluginConstants': {},
          };
        default:
          return null;
      }
    },
  );
}

/// Mock implementation для Firebase Auth
void setupFirebaseAuthMocks() {
  const MethodChannel channel = MethodChannel('plugins.flutter.io/firebase_auth');
  
  // Состояние мока
  final Map<String, Map<String, dynamic>> _users = {};
  String? _currentUserId;
  
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Auth#registerIdTokenListener':
          return {
            'token': 'mock-id-token',
            'user': _currentUserId != null ? _users[_currentUserId] : null,
          };
          
        case 'Auth#signInWithEmailAndPassword':
          final email = methodCall.arguments['email'];
          final password = methodCall.arguments['password'];
          
          // Найти пользователя по email
          for (final entry in _users.entries) {
            final userData = entry.value;
            if (userData['email'] == email && userData['password'] == password) {
              _currentUserId = entry.key;
              return {
                'user': {
                  'uid': userData['uid'],
                  'email': userData['email'],
                  'displayName': userData['displayName'],
                  'isAnonymous': false,
                  'emailVerified': userData['emailVerified'] ?? true,
                  'photoURL': userData['photoURL'],
                  'phoneNumber': userData['phoneNumber'],
                  'tenantId': null,
                  'refreshToken': 'mock-refresh-token',
                  'creationTimestamp': userData['creationTimestamp'] ?? DateTime.now().millisecondsSinceEpoch,
                  'lastSignInTimestamp': DateTime.now().millisecondsSinceEpoch,
                  'providerId': 'firebase',
                  'providerData': [],
                },
                'additionalUserInfo': {
                  'isNewUser': false,
                  'providerId': 'password',
                  'username': null,
                  'profile': null,
                },
              };
            }
          }
          
          // Если пользователь не найден или неверный пароль
          throw PlatformException(
            code: 'ERROR_USER_NOT_FOUND',
            message: 'There is no user record corresponding to this identifier.',
          );
          
        case 'Auth#createUserWithEmailAndPassword':
          final email = methodCall.arguments['email'];
          final password = methodCall.arguments['password'];
          
          // Проверить, что пользователь не существует
          for (final userData in _users.values) {
            if (userData['email'] == email) {
              throw PlatformException(
                code: 'ERROR_EMAIL_ALREADY_IN_USE',
                message: 'The email address is already in use by another account.',
              );
            }
          }
          
          // Создать нового пользователя
          final uid = 'mock-uid-${DateTime.now().millisecondsSinceEpoch}';
          _users[uid] = {
            'uid': uid,
            'email': email,
            'password': password, // В реальности пароль не хранится
            'displayName': null,
            'photoURL': null,
            'phoneNumber': null,
            'emailVerified': false,
            'creationTimestamp': DateTime.now().millisecondsSinceEpoch,
          };
          _currentUserId = uid;
          
          return {
            'user': {
              'uid': uid,
              'email': email,
              'displayName': null,
              'isAnonymous': false,
              'emailVerified': false,
              'photoURL': null,
              'phoneNumber': null,
              'tenantId': null,
              'refreshToken': 'mock-refresh-token',
              'creationTimestamp': DateTime.now().millisecondsSinceEpoch,
              'lastSignInTimestamp': DateTime.now().millisecondsSinceEpoch,
              'providerId': 'firebase',
              'providerData': [],
            },
            'additionalUserInfo': {
              'isNewUser': true,
              'providerId': 'password',
              'username': null,
              'profile': null,
            },
          };
          
        case 'Auth#signOut':
          _currentUserId = null;
          return null;
          
        case 'Auth#sendPasswordResetEmail':
          final email = methodCall.arguments['email'];
          
          // Проверить, что пользователь существует
          bool userExists = false;
          for (final userData in _users.values) {
            if (userData['email'] == email) {
              userExists = true;
              break;
            }
          }
          
          if (!userExists) {
            throw PlatformException(
              code: 'ERROR_USER_NOT_FOUND',
              message: 'There is no user record corresponding to this identifier.',
            );
          }
          
          return null;
          
        case 'Auth#updateProfile':
          if (_currentUserId == null) {
            throw PlatformException(
              code: 'ERROR_USER_NOT_SIGNED_IN',
              message: 'No user is currently signed in.',
            );
          }
          
          final displayName = methodCall.arguments['displayName'];
          final photoURL = methodCall.arguments['photoURL'];
          
          _users[_currentUserId]!['displayName'] = displayName;
          _users[_currentUserId]!['photoURL'] = photoURL;
          
          return null;
          
        case 'Auth#updateEmail':
          if (_currentUserId == null) {
            throw PlatformException(
              code: 'ERROR_USER_NOT_SIGNED_IN',
              message: 'No user is currently signed in.',
            );
          }
          
          final newEmail = methodCall.arguments['email'];
          
          // Проверить, что email не занят
          for (final entry in _users.entries) {
            if (entry.key != _currentUserId && entry.value['email'] == newEmail) {
              throw PlatformException(
                code: 'ERROR_EMAIL_ALREADY_IN_USE',
                message: 'The email address is already in use by another account.',
              );
            }
          }
          
          _users[_currentUserId]!['email'] = newEmail;
          return null;
          
        case 'Auth#updatePassword':
          if (_currentUserId == null) {
            throw PlatformException(
              code: 'ERROR_USER_NOT_SIGNED_IN',
              message: 'No user is currently signed in.',
            );
          }
          
          final newPassword = methodCall.arguments['password'];
          _users[_currentUserId]!['password'] = newPassword;
          
          return null;
          
        case 'Auth#delete':
          if (_currentUserId == null) {
            throw PlatformException(
              code: 'ERROR_USER_NOT_SIGNED_IN',
              message: 'No user is currently signed in.',
            );
          }
          
          _users.remove(_currentUserId);
          _currentUserId = null;
          
          return null;
          
        case 'Auth#reload':
          // Ничего не делаем для мока
          return null;
          
        case 'Auth#getIdToken':
          if (_currentUserId == null) {
            return null;
          }
          
          final forceRefresh = methodCall.arguments['forceRefresh'] ?? false;
          return {
            'token': forceRefresh ? 'refreshed-mock-token' : 'mock-id-token',
            'expirationTimestamp': DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch,
            'authTimestamp': DateTime.now().millisecondsSinceEpoch,
            'issuedAtTimestamp': DateTime.now().millisecondsSinceEpoch,
            'signInProvider': 'password',
            'signInSecondFactor': null,
            'claims': {
              'sub': _currentUserId,
              'email': _users[_currentUserId]!['email'],
              'email_verified': _users[_currentUserId]!['emailVerified'],
            },
          };
          
        case 'Auth#reauthenticateWithCredential':
          if (_currentUserId == null) {
            throw PlatformException(
              code: 'ERROR_USER_NOT_SIGNED_IN',
              message: 'No user is currently signed in.',
            );
          }
          
          final email = methodCall.arguments['email'];
          final password = methodCall.arguments['password'];
          
          final currentUser = _users[_currentUserId]!;
          if (currentUser['email'] != email || currentUser['password'] != password) {
            throw PlatformException(
              code: 'ERROR_WRONG_PASSWORD',
              message: 'The password is invalid or the user does not have a password.',
            );
          }
          
          return {
            'user': {
              'uid': currentUser['uid'],
              'email': currentUser['email'],
              'displayName': currentUser['displayName'],
              'isAnonymous': false,
              'emailVerified': currentUser['emailVerified'],
            },
            'additionalUserInfo': {
              'isNewUser': false,
              'providerId': 'password',
            },
          };
          
        default:
          throw PlatformException(
            code: 'UNIMPLEMENTED',
            message: 'Method ${methodCall.method} not implemented in mock',
          );
      }
    },
  );
}

/// Mock implementation для Secure Storage
void setupSecureStorageMocks() {
  const MethodChannel channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final Map<String, String> _storage = {};
  
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'write':
          final key = methodCall.arguments['key'] as String;
          final value = methodCall.arguments['value'] as String;
          _storage[key] = value;
          return null;
          
        case 'read':
          final key = methodCall.arguments['key'] as String;
          return _storage[key];
          
        case 'delete':
          final key = methodCall.arguments['key'] as String;
          _storage.remove(key);
          return null;
          
        case 'deleteAll':
          _storage.clear();
          return null;
          
        case 'readAll':
          return Map<String, String>.from(_storage);
          
        default:
          return null;
      }
    },
  );
}

/// Настройка всех моков Firebase
void setupFirebaseMocks() {
  setupFirebaseCoreMocks();
  setupFirebaseAuthMocks();
  setupSecureStorageMocks();
}

/// Очистка всех моков
void clearFirebaseMocks() {
  const coreChannel = MethodChannel('plugins.flutter.io/firebase_core');
  const authChannel = MethodChannel('plugins.flutter.io/firebase_auth');
  const storageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(coreChannel, null);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(authChannel, null);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(storageChannel, null);
}

/// Утилита для создания тестового пользователя
void createMockUser({
  required String email,
  required String password,
  String? displayName,
  bool emailVerified = true,
}) {
  // Этот метод будет использоваться в тестах для предустановки пользователей
  // Реализация через прямой доступ к internal state мока
}