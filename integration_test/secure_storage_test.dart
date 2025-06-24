import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mood_tracker_plus/services/secure_storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorageService Integration Tests', () {
    setUp(() async {
      // Очищаем хранилище перед каждым тестом
      await SecureStorageService.clearAll();
    });

    tearDown(() async {
      // Очищаем после каждого теста
      await SecureStorageService.clearAll();
    });

    testWidgets('Token operations', (WidgetTester tester) async {
      // Save and retrieve token
      const testToken = 'integration_test_token_123';
      await SecureStorageService.saveToken(testToken);
      
      final retrievedToken = await SecureStorageService.getToken();
      expect(retrievedToken, testToken);

      // Check hasToken
      expect(await SecureStorageService.hasToken(), true);

      // Clear tokens
      await SecureStorageService.clearTokens();
      expect(await SecureStorageService.getToken(), null);
      expect(await SecureStorageService.hasToken(), false);
    });

    testWidgets('Refresh token operations', (WidgetTester tester) async {
      const testRefreshToken = 'refresh_token_456';
      
      await SecureStorageService.saveRefreshToken(testRefreshToken);
      final retrievedToken = await SecureStorageService.getRefreshToken();
      
      expect(retrievedToken, testRefreshToken);
    });

    testWidgets('Credentials operations', (WidgetTester tester) async {
      const testEmail = 'integration@test.com';
      const testPassword = 'secure_password_789';
      
      // Save credentials
      await SecureStorageService.saveCredentials(testEmail, testPassword);
      
      // Retrieve credentials
      final credentials = await SecureStorageService.getCredentials();
      expect(credentials['email'], testEmail);
      expect(credentials['password'], testPassword);

      // Clear credentials
      await SecureStorageService.clearCredentials();
      final clearedCredentials = await SecureStorageService.getCredentials();
      expect(clearedCredentials['email'], null);
      expect(clearedCredentials['password'], null);
    });

    testWidgets('User ID operations', (WidgetTester tester) async {
      const testUserId = 'firebase_user_id_integration';
      
      await SecureStorageService.saveUserId(testUserId);
      final retrievedUserId = await SecureStorageService.getUserId();
      
      expect(retrievedUserId, testUserId);
    });

    testWidgets('Clear all data', (WidgetTester tester) async {
      // Save various data
      await SecureStorageService.saveToken('token_to_clear');
      await SecureStorageService.saveRefreshToken('refresh_to_clear');
      await SecureStorageService.saveUserId('user_to_clear');
      await SecureStorageService.saveCredentials('email@clear.com', 'pass_to_clear');
      
      // Verify data exists
      expect(await SecureStorageService.hasToken(), true);
      
      // Clear all
      await SecureStorageService.clearAll();
      
      // Verify all data is cleared
      expect(await SecureStorageService.getToken(), null);
      expect(await SecureStorageService.getRefreshToken(), null);
      expect(await SecureStorageService.getUserId(), null);
      
      final credentials = await SecureStorageService.getCredentials();
      expect(credentials['email'], null);
      expect(credentials['password'], null);
    });

    testWidgets('Get all data', (WidgetTester tester) async {
      // Save various data
      await SecureStorageService.saveToken('all_data_token');
      await SecureStorageService.saveUserId('all_data_user');
      await SecureStorageService.saveCredentials('all@data.com', 'all_data_pass');
      
      // Get all data
      final allData = await SecureStorageService.getAllData();
      
      expect(allData['firebase_token'], 'all_data_token');
      expect(allData['firebase_user_id'], 'all_data_user');
      expect(allData['user_email'], 'all@data.com');
      expect(allData['user_password'], 'all_data_pass');
    });

    testWidgets('Data persistence across operations', (WidgetTester tester) async {
      // Save data
      await SecureStorageService.saveToken('persistent_token');
      await SecureStorageService.saveUserId('persistent_user');
      
      // Verify persistence
      expect(await SecureStorageService.getToken(), 'persistent_token');
      expect(await SecureStorageService.getUserId(), 'persistent_user');
      
      // Save more data
      await SecureStorageService.saveCredentials('persist@test.com', 'persist_pass');
      
      // Verify all data still exists
      expect(await SecureStorageService.getToken(), 'persistent_token');
      expect(await SecureStorageService.getUserId(), 'persistent_user');
      
      final creds = await SecureStorageService.getCredentials();
      expect(creds['email'], 'persist@test.com');
    });

    testWidgets('Overwrite existing values', (WidgetTester tester) async {
      // Save initial values
      await SecureStorageService.saveToken('first_token');
      await SecureStorageService.saveUserId('first_user');
      
      // Overwrite with new values
      await SecureStorageService.saveToken('second_token');
      await SecureStorageService.saveUserId('second_user');
      
      // Verify new values
      expect(await SecureStorageService.getToken(), 'second_token');
      expect(await SecureStorageService.getUserId(), 'second_user');
    });

    testWidgets('Handle special characters', (WidgetTester tester) async {
      const specialToken = 'token!@#\$%^&*()_+-=[]{}|;:\'",.<>?/~`';
      const specialEmail = 'user+test@example.com';
      const specialPassword = 'P@ssw0rd!#2024';
      
      await SecureStorageService.saveToken(specialToken);
      await SecureStorageService.saveCredentials(specialEmail, specialPassword);
      
      expect(await SecureStorageService.getToken(), specialToken);
      
      final credentials = await SecureStorageService.getCredentials();
      expect(credentials['email'], specialEmail);
      expect(credentials['password'], specialPassword);
    });

    testWidgets('Handle empty strings', (WidgetTester tester) async {
      await SecureStorageService.saveToken('');
      await SecureStorageService.saveUserId('');
      
      expect(await SecureStorageService.getToken(), '');
      expect(await SecureStorageService.getUserId(), '');
      expect(await SecureStorageService.hasToken(), false); // empty string is falsy
    });
  });
}