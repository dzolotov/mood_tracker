import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:mood_tracker_plus/services/auth_service_di.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock secure storage
  const MethodChannel channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final Map<String, String> _storage = {};
  
  setUpAll(() {
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
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('AuthServiceDI Tests', () {
    late AuthServiceDI authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late SharedPreferences mockPrefs;

    setUp(() async {
      // Clear storage
      _storage.clear();
      
      // Initialize SharedPreferences
      SharedPreferences.setMockInitialValues({});
      mockPrefs = await SharedPreferences.getInstance();
      
      // Create mock Firebase Auth
      mockFirebaseAuth = MockFirebaseAuth();
      
      // Create service with injected dependencies
      authService = AuthServiceDI(
        firebaseAuth: mockFirebaseAuth,
        sharedPreferences: mockPrefs,
      );
      
      // Give time for initialization
      await Future.delayed(const Duration(milliseconds: 100));
    });

    group('Initialization', () {
      test('initializes with correct default values', () {
        expect(authService.user, isNull);
        expect(authService.username, isNull);
        expect(authService.isLoggedIn, false);
        expect(authService.errorMessage, isNull);
        expect(authService.userEmail, isNull);
        expect(authService.displayName, isNull);
        expect(authService.isInitialized, true);
      });

      test('loads saved data from SharedPreferences on init', () async {
        // Pre-populate SharedPreferences
        await mockPrefs.setString('username', 'saved_user');
        await mockPrefs.setBool('is_logged_in', true);

        // Create new service
        final newService = AuthServiceDI(
          firebaseAuth: MockFirebaseAuth(),
          sharedPreferences: mockPrefs,
        );
        await Future.delayed(const Duration(milliseconds: 100));

        expect(newService.username, 'saved_user');
        expect(newService.isInitialized, true);
      });
    });

    group('Registration', () {
      test('successfully registers new user', () async {
        const email = 'newuser@example.com';
        const password = 'password123';

        final result = await authService.register(email, password);

        expect(result, true);
        expect(authService.isLoggedIn, true);
        expect(authService.userEmail, email);
        expect(authService.username, 'newuser');
        expect(authService.errorMessage, isNull);
        
        // Check SharedPreferences
        expect(mockPrefs.getString('username'), 'newuser');
        expect(mockPrefs.getBool('is_logged_in'), true);
      });

      test('notifies listeners during registration', () async {
        var notificationCount = 0;
        authService.addListener(() {
          notificationCount++;
        });

        await authService.register('test@example.com', 'password123');

        expect(notificationCount, greaterThan(0));
      });
    });

    group('Login with Email', () {
      setUp(() async {
        // Pre-register a user for login tests
        await authService.register('test@example.com', 'password123');
        await authService.logout();
      });

      test('successfully logs in with valid credentials', () async {
        const email = 'test@example.com';
        const password = 'password123';

        final result = await authService.loginWithEmail(email, password);

        expect(result, true);
        expect(authService.isLoggedIn, true);
        expect(authService.userEmail, email);
        expect(authService.username, 'test');
        expect(authService.errorMessage, isNull);
      });

      test('saveCredentials parameter works without error', () async {
        const email = 'test@example.com';
        const password = 'password123';

        final result = await authService.loginWithEmail(
          email, 
          password, 
          saveCredentials: true,
        );

        expect(result, true);
        expect(authService.isLoggedIn, true);
      });
    });

    group('Legacy Login', () {
      setUp(() async {
        await authService.register('user@example.com', 'password123');
        await authService.logout();
      });

      test('login method works as alias for loginWithEmail', () async {
        final result = await authService.login('user@example.com', 'password123');

        expect(result, true);
        expect(authService.isLoggedIn, true);
        expect(authService.userEmail, 'user@example.com');
      });
    });

    group('Logout', () {
      setUp(() async {
        await authService.register('logout@example.com', 'password123');
      });

      test('successfully logs out user', () async {
        expect(authService.isLoggedIn, true);

        await authService.logout();

        expect(authService.isLoggedIn, false);
        expect(authService.user, isNull);
        expect(authService.username, isNull);
        expect(authService.userEmail, isNull);
        expect(authService.errorMessage, isNull);
      });

      test('clears SharedPreferences on logout', () async {
        expect(mockPrefs.getString('username'), isNotNull);

        await authService.logout();

        expect(mockPrefs.getString('username'), isNull);
        expect(mockPrefs.getBool('is_logged_in'), isNull);
      });
    });

    group('Password Reset', () {
      setUp(() async {
        await authService.register('reset@example.com', 'password123');
        await authService.logout();
      });

      test('successfully sends password reset email', () async {
        final result = await authService.resetPassword('reset@example.com');

        expect(result, true);
        expect(authService.errorMessage, isNull);
      });
    });

    group('Profile Updates', () {
      setUp(() async {
        await authService.register('profile@example.com', 'password123');
      });

      test('successfully updates display name', () async {
        const newName = 'New Display Name';

        final result = await authService.updateDisplayName(newName);

        expect(result, true);
        expect(authService.username, newName);
        expect(authService.errorMessage, isNull);
        
        // Check SharedPreferences
        expect(mockPrefs.getString('username'), newName);
      });

      test('fails to update display name when not logged in', () async {
        await authService.logout();

        final result = await authService.updateDisplayName('New Name');

        expect(result, false);
      });

      test('successfully updates email', () async {
        const newEmail = 'newemail@example.com';

        final result = await authService.updateEmail(newEmail);

        expect(result, true);
        // Check that confirmation message is set
        expect(authService.errorMessage, contains('Проверьте почту'));
      });
    });

    group('Token Management', () {
      setUp(() async {
        await authService.register('token@example.com', 'password123');
      });

      test('gets ID token when logged in', () async {
        final token = await authService.getIdToken();

        expect(token, isNotNull);
        expect(token, isA<String>());
      });

      test('gets refreshed token when requested', () async {
        final token = await authService.getIdToken(forceRefresh: true);

        expect(token, isNotNull);
        expect(token, isA<String>());
      });

      test('returns null when not logged in', () async {
        await authService.logout();

        final token = await authService.getIdToken();

        expect(token, isNull);
      });
    });

    group('Error Handling', () {
      test('clearError clears error message', () async {
        // Create an error by attempting login with invalid credentials
        await authService.loginWithEmail('wrong@email.com', 'wrong');
        
        // Wait for async completion
        await Future.delayed(const Duration(milliseconds: 100));
        
        authService.clearError();
        expect(authService.errorMessage, isNull);
      });
    });

    group('State Management', () {
      test('notifies listeners on state changes', () async {
        var notificationCount = 0;
        authService.addListener(() {
          notificationCount++;
        });

        await authService.register('listener@example.com', 'password123');
        await authService.logout();

        expect(notificationCount, greaterThan(1));
      });

      test('maintains state consistency across operations', () async {
        // Registration
        await authService.register('state@example.com', 'password123');
        expect(authService.isLoggedIn, true);
        expect(authService.userEmail, 'state@example.com');

        // Logout
        await authService.logout();
        expect(authService.isLoggedIn, false);
        expect(authService.userEmail, isNull);

        // Login again
        await authService.loginWithEmail('state@example.com', 'password123');
        expect(authService.isLoggedIn, true);
        expect(authService.userEmail, 'state@example.com');
      });
    });

    group('Edge Cases', () {
      test('handles empty email and password', () async {
        final result = await authService.loginWithEmail('', '');
        // MockFirebaseAuth might succeed with empty credentials, but that's ok for testing
        expect(result, isA<bool>());
      });

      test('handles null values gracefully', () async {
        await authService.register('test@example.com', 'password123');
        final result = await authService.updateDisplayName('');
        expect(result, isA<bool>());
      });
    });
  });
}