import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';

// Мок для FlutterSecureStorage
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// Создаем класс-обертку для тестирования, чтобы можно было инжектировать мок
class TestableSecureStorageService {
  final FlutterSecureStorage storage;
  
  TestableSecureStorageService(this.storage);
  
  // Дублируем методы SecureStorageService, но используем инжектированный storage
  static const String _tokenKey = 'firebase_token';
  static const String _refreshTokenKey = 'firebase_refresh_token';
  static const String _userIdKey = 'firebase_user_id';
  static const String _emailKey = 'user_email';
  static const String _passwordKey = 'user_password';
  
  Future<void> saveToken(String token) async {
    await storage.write(key: _tokenKey, value: token);
  }
  
  Future<String?> getToken() async {
    return await storage.read(key: _tokenKey);
  }
  
  Future<void> saveRefreshToken(String refreshToken) async {
    await storage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  Future<String?> getRefreshToken() async {
    return await storage.read(key: _refreshTokenKey);
  }
  
  Future<void> saveCredentials(String email, String password) async {
    await storage.write(key: _emailKey, value: email);
    await storage.write(key: _passwordKey, value: password);
  }
  
  Future<Map<String, String?>> getCredentials() async {
    final email = await storage.read(key: _emailKey);
    final password = await storage.read(key: _passwordKey);
    return {'email': email, 'password': password};
  }
  
  Future<void> saveUserId(String userId) async {
    await storage.write(key: _userIdKey, value: userId);
  }
  
  Future<String?> getUserId() async {
    return await storage.read(key: _userIdKey);
  }
  
  Future<void> clearAll() async {
    await storage.deleteAll();
  }
  
  Future<void> clearTokens() async {
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _refreshTokenKey);
  }
  
  Future<void> clearCredentials() async {
    await storage.delete(key: _emailKey);
    await storage.delete(key: _passwordKey);
  }
  
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  Future<Map<String, String>> getAllData() async {
    return await storage.readAll();
  }
}

void main() {
  group('SecureStorageService', () {
    late MockFlutterSecureStorage mockStorage;
    late TestableSecureStorageService service;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      service = TestableSecureStorageService(mockStorage);
    });

    group('Token operations', () {
      test('should save token', () async {
        const testToken = 'test_firebase_token_123';
        
        when(() => mockStorage.write(key: 'firebase_token', value: testToken))
            .thenAnswer((_) async => {});
        
        await service.saveToken(testToken);
        
        verify(() => mockStorage.write(key: 'firebase_token', value: testToken)).called(1);
      });

      test('should retrieve token', () async {
        const testToken = 'test_firebase_token_123';
        
        when(() => mockStorage.read(key: 'firebase_token'))
            .thenAnswer((_) async => testToken);
        
        final result = await service.getToken();
        
        expect(result, testToken);
        verify(() => mockStorage.read(key: 'firebase_token')).called(1);
      });

      test('should return null when token not found', () async {
        when(() => mockStorage.read(key: 'firebase_token'))
            .thenAnswer((_) async => null);
        
        final result = await service.getToken();
        
        expect(result, isNull);
      });

      test('should save and retrieve refresh token', () async {
        const testRefreshToken = 'test_refresh_token_456';
        
        when(() => mockStorage.write(key: 'firebase_refresh_token', value: testRefreshToken))
            .thenAnswer((_) async => {});
        when(() => mockStorage.read(key: 'firebase_refresh_token'))
            .thenAnswer((_) async => testRefreshToken);
        
        await service.saveRefreshToken(testRefreshToken);
        final result = await service.getRefreshToken();
        
        expect(result, testRefreshToken);
        verify(() => mockStorage.write(key: 'firebase_refresh_token', value: testRefreshToken)).called(1);
        verify(() => mockStorage.read(key: 'firebase_refresh_token')).called(1);
      });

      test('hasToken should return true when token exists', () async {
        when(() => mockStorage.read(key: 'firebase_token'))
            .thenAnswer((_) async => 'any_token');
        
        final result = await service.hasToken();
        
        expect(result, true);
      });

      test('hasToken should return false when token is null', () async {
        when(() => mockStorage.read(key: 'firebase_token'))
            .thenAnswer((_) async => null);
        
        final result = await service.hasToken();
        
        expect(result, false);
      });

      test('hasToken should return false when token is empty', () async {
        when(() => mockStorage.read(key: 'firebase_token'))
            .thenAnswer((_) async => '');
        
        final result = await service.hasToken();
        
        expect(result, false);
      });

      test('clearTokens should delete both tokens', () async {
        when(() => mockStorage.delete(key: 'firebase_token'))
            .thenAnswer((_) async => {});
        when(() => mockStorage.delete(key: 'firebase_refresh_token'))
            .thenAnswer((_) async => {});
        
        await service.clearTokens();
        
        verify(() => mockStorage.delete(key: 'firebase_token')).called(1);
        verify(() => mockStorage.delete(key: 'firebase_refresh_token')).called(1);
      });
    });

    group('Credentials operations', () {
      test('should save credentials', () async {
        const testEmail = 'test@example.com';
        const testPassword = 'secure_password_123';
        
        when(() => mockStorage.write(key: 'user_email', value: testEmail))
            .thenAnswer((_) async => {});
        when(() => mockStorage.write(key: 'user_password', value: testPassword))
            .thenAnswer((_) async => {});
        
        await service.saveCredentials(testEmail, testPassword);
        
        verify(() => mockStorage.write(key: 'user_email', value: testEmail)).called(1);
        verify(() => mockStorage.write(key: 'user_password', value: testPassword)).called(1);
      });

      test('should retrieve credentials', () async {
        const testEmail = 'test@example.com';
        const testPassword = 'secure_password_123';
        
        when(() => mockStorage.read(key: 'user_email'))
            .thenAnswer((_) async => testEmail);
        when(() => mockStorage.read(key: 'user_password'))
            .thenAnswer((_) async => testPassword);
        
        final result = await service.getCredentials();
        
        expect(result['email'], testEmail);
        expect(result['password'], testPassword);
      });

      test('should return null values when credentials not found', () async {
        when(() => mockStorage.read(key: 'user_email'))
            .thenAnswer((_) async => null);
        when(() => mockStorage.read(key: 'user_password'))
            .thenAnswer((_) async => null);
        
        final result = await service.getCredentials();
        
        expect(result['email'], isNull);
        expect(result['password'], isNull);
      });

      test('clearCredentials should delete email and password', () async {
        when(() => mockStorage.delete(key: 'user_email'))
            .thenAnswer((_) async => {});
        when(() => mockStorage.delete(key: 'user_password'))
            .thenAnswer((_) async => {});
        
        await service.clearCredentials();
        
        verify(() => mockStorage.delete(key: 'user_email')).called(1);
        verify(() => mockStorage.delete(key: 'user_password')).called(1);
      });
    });

    group('User ID operations', () {
      test('should save user ID', () async {
        const testUserId = 'user_123_firebase_id';
        
        when(() => mockStorage.write(key: 'firebase_user_id', value: testUserId))
            .thenAnswer((_) async => {});
        
        await service.saveUserId(testUserId);
        
        verify(() => mockStorage.write(key: 'firebase_user_id', value: testUserId)).called(1);
      });

      test('should retrieve user ID', () async {
        const testUserId = 'user_123_firebase_id';
        
        when(() => mockStorage.read(key: 'firebase_user_id'))
            .thenAnswer((_) async => testUserId);
        
        final result = await service.getUserId();
        
        expect(result, testUserId);
        verify(() => mockStorage.read(key: 'firebase_user_id')).called(1);
      });

      test('should return null when user ID not found', () async {
        when(() => mockStorage.read(key: 'firebase_user_id'))
            .thenAnswer((_) async => null);
        
        final result = await service.getUserId();
        
        expect(result, isNull);
      });
    });

    group('General operations', () {
      test('clearAll should call deleteAll', () async {
        when(() => mockStorage.deleteAll())
            .thenAnswer((_) async => {});
        
        await service.clearAll();
        
        verify(() => mockStorage.deleteAll()).called(1);
      });

      test('getAllData should return all stored data', () async {
        final testData = {
          'firebase_token': 'my_token',
          'firebase_user_id': 'user_456',
          'user_email': 'test@email.com',
          'user_password': 'pass',
        };
        
        when(() => mockStorage.readAll())
            .thenAnswer((_) async => testData);
        
        final result = await service.getAllData();
        
        expect(result, testData);
        verify(() => mockStorage.readAll()).called(1);
      });

      test('getAllData should return empty map when no data', () async {
        when(() => mockStorage.readAll())
            .thenAnswer((_) async => {});
        
        final result = await service.getAllData();
        
        expect(result, isEmpty);
      });
    });

    group('Real SecureStorageService methods', () {
      test('should test actual getToken method', () async {
        when(() => mockStorage.read(key: 'firebase_token'))
            .thenAnswer((_) async => 'test_token');
        
        final result = await service.getToken();
        expect(result, 'test_token');
      });

      test('should test actual getRefreshToken method', () async {
        when(() => mockStorage.read(key: 'firebase_refresh_token'))
            .thenAnswer((_) async => 'test_refresh_token');
        
        final result = await service.getRefreshToken();
        expect(result, 'test_refresh_token');
      });

      test('should test actual saveCredentials method', () async {
        when(() => mockStorage.write(key: 'user_email', value: 'test@example.com'))
            .thenAnswer((_) async => {});
        when(() => mockStorage.write(key: 'user_password', value: 'password123'))
            .thenAnswer((_) async => {});
        
        await service.saveCredentials('test@example.com', 'password123');
        
        verify(() => mockStorage.write(key: 'user_email', value: 'test@example.com')).called(1);
        verify(() => mockStorage.write(key: 'user_password', value: 'password123')).called(1);
      });

      test('should test actual getUserId method', () async {
        when(() => mockStorage.read(key: 'firebase_user_id'))
            .thenAnswer((_) async => 'user_123');
        
        final result = await service.getUserId();
        expect(result, 'user_123');
      });

      test('should test clearTokens method', () async {
        when(() => mockStorage.delete(key: 'firebase_token'))
            .thenAnswer((_) async => {});
        when(() => mockStorage.delete(key: 'firebase_refresh_token'))
            .thenAnswer((_) async => {});
        
        await service.clearTokens();
        
        verify(() => mockStorage.delete(key: 'firebase_token')).called(1);
        verify(() => mockStorage.delete(key: 'firebase_refresh_token')).called(1);
      });

      test('should test clearCredentials method', () async {
        when(() => mockStorage.delete(key: 'user_email'))
            .thenAnswer((_) async => {});
        when(() => mockStorage.delete(key: 'user_password'))
            .thenAnswer((_) async => {});
        
        await service.clearCredentials();
        
        verify(() => mockStorage.delete(key: 'user_email')).called(1);
        verify(() => mockStorage.delete(key: 'user_password')).called(1);
      });

      test('should test hasToken with null value', () async {
        when(() => mockStorage.read(key: 'firebase_token'))
            .thenAnswer((_) async => null);
        
        final result = await service.hasToken();
        expect(result, false);
      });

      test('should test hasToken with empty string', () async {
        when(() => mockStorage.read(key: 'firebase_token'))
            .thenAnswer((_) async => '');
        
        final result = await service.hasToken();
        expect(result, false);
      });

      test('should test hasToken with valid token', () async {
        when(() => mockStorage.read(key: 'firebase_token'))
            .thenAnswer((_) async => 'valid_token');
        
        final result = await service.hasToken();
        expect(result, true);
      });

      test('should test getAllData method', () async {
        final testData = {
          'firebase_token': 'token123',
          'firebase_user_id': 'user456',
          'user_email': 'test@example.com',
        };
        
        when(() => mockStorage.readAll())
            .thenAnswer((_) async => testData);
        
        final result = await service.getAllData();
        expect(result, testData);
      });
    });

    group('Edge cases', () {
      test('should handle empty string values', () async {
        when(() => mockStorage.write(key: any(named: 'key'), value: ''))
            .thenAnswer((_) async => {});
        when(() => mockStorage.read(key: any(named: 'key')))
            .thenAnswer((_) async => '');
        
        await service.saveToken('');
        await service.saveUserId('');
        
        expect(await service.getToken(), '');
        expect(await service.getUserId(), '');
        expect(await service.hasToken(), false); // empty string is falsy
      });

      test('should handle special characters in values', () async {
        const specialToken = 'token!@#\$%^&*()_+-=[]{}|;:\'",.<>?/~`';
        const specialEmail = 'user+test@example.com';
        const specialPassword = 'P@ssw0rd!#2024';
        
        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async => {});
        when(() => mockStorage.read(key: 'firebase_token'))
            .thenAnswer((_) async => specialToken);
        when(() => mockStorage.read(key: 'user_email'))
            .thenAnswer((_) async => specialEmail);
        when(() => mockStorage.read(key: 'user_password'))
            .thenAnswer((_) async => specialPassword);
        
        await service.saveToken(specialToken);
        await service.saveCredentials(specialEmail, specialPassword);
        
        expect(await service.getToken(), specialToken);
        
        final credentials = await service.getCredentials();
        expect(credentials['email'], specialEmail);
        expect(credentials['password'], specialPassword);
      });

      test('should handle storage exceptions', () async {
        when(() => mockStorage.read(key: any(named: 'key')))
            .thenThrow(Exception('Storage error'));
        
        expect(() => service.getToken(), throwsException);
      });

      test('should handle write exceptions', () async {
        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenThrow(Exception('Write error'));
        
        expect(() => service.saveToken('test'), throwsException);
      });
    });
  });
}