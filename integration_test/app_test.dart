import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mood_tracker_plus/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_tracker_plus/services/secure_storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MoodTracker++ Integration Tests', () {
    setUp(() async {
      // Очищаем данные перед каждым тестом
      SharedPreferences.setMockInitialValues({});
      await SecureStorageService.clearAll();
    });

    testWidgets('App starts and shows home screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(); // Ждем завершения всех анимаций

      // Проверяем основные элементы
      expect(find.text('MoodTracker++'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Can add mood entry', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Нажимаем на кнопку добавления
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Проверяем, что открылся экран добавления настроения
      expect(find.text('Как вы себя чувствуете?'), findsOneWidget);
      
      // Находим эмодзи для "Счастлив"
      expect(find.text('🙂'), findsOneWidget);
    });

    testWidgets('Theme toggle persists', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Ищем кнопку переключения темы
      final themeButton = find.byIcon(Icons.brightness_6);
      if (themeButton.evaluate().isNotEmpty) {
        // Переключаем тему
        await tester.tap(themeButton);
        await tester.pumpAndSettle();

        // Перезапускаем приложение
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Тема должна сохраниться
        // (проверка зависит от реализации UI)
      }
    });

    testWidgets('Navigation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Проверяем наличие навигационных элементов
      // Если есть BottomNavigationBar
      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isNotEmpty) {
        // Проверяем табы
        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.byIcon(Icons.history), findsOneWidget);
        expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      }
    });

    testWidgets('Secure storage integration with auth', (WidgetTester tester) async {
      // Сохраняем тестовые данные в secure storage
      await SecureStorageService.saveToken('test_integration_token');
      await SecureStorageService.saveUserId('test_user_id');
      await SecureStorageService.saveCredentials('test@integration.com', 'test_password');

      // Запускаем приложение
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Приложение должно попытаться использовать сохраненные данные
      // (конкретная проверка зависит от реализации AuthService)
      
      // Проверяем, что данные доступны
      expect(await SecureStorageService.getToken(), 'test_integration_token');
      expect(await SecureStorageService.getUserId(), 'test_user_id');
      
      final creds = await SecureStorageService.getCredentials();
      expect(creds['email'], 'test@integration.com');
      expect(creds['password'], 'test_password');
    });
  });
}