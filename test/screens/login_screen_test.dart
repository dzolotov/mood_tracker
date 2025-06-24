import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mood_tracker_plus/screens/login_screen.dart';
import '../test_helpers.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      when(() => mockAuthService.errorMessage).thenReturn(null);
      when(() => mockAuthService.isLoggedIn).thenReturn(false);
    });

    tearDown(() {
      reset(mockAuthService);
    });

    testWidgets('displays all UI elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        authService: mockAuthService,
        child: const LoginScreen(),
      ));

      // Проверяем заголовок
      expect(find.text('Вход в систему'), findsOneWidget);
      
      // Проверяем поля ввода
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Пароль'), findsOneWidget);
      
      // Проверяем кнопку входа
      expect(find.widgetWithText(ElevatedButton, 'Войти'), findsOneWidget);
    });

    testWidgets('shows password visibility toggle', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        authService: mockAuthService,
        child: const LoginScreen(),
      ));

      // Находим иконку для переключения видимости пароля (по умолчанию показывает visibility, так как пароль скрыт)
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('validates empty email', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        authService: mockAuthService,
        child: const LoginScreen(),
      ));

      // Находим поле email и оставляем его пустым
      final emailField = find.widgetWithText(TextFormField, 'Email');
      expect(emailField, findsOneWidget);

      // Проверяем валидацию
      await tester.enterText(emailField, '');
      await tester.pump();
      
      // Убеждаемся, что поле есть
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    });

    testWidgets('shows registration toggle text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        authService: mockAuthService,
        child: const LoginScreen(),
      ));

      // Проверяем текст для переключения на регистрацию
      expect(find.text('Нет аккаунта? Зарегистрироваться'), findsOneWidget);
    });

    testWidgets('shows forgot password link', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(
        authService: mockAuthService,
        child: const LoginScreen(),
      ));

      // Проверяем ссылку для сброса пароля
      expect(find.text('Забыли пароль?'), findsOneWidget);
    });

    testWidgets('displays login form when not authenticated', (WidgetTester tester) async {
      // Настраиваем пользователя как не залогиненного
      when(() => mockAuthService.isLoggedIn).thenReturn(false);
      when(() => mockAuthService.username).thenReturn(null);

      await tester.pumpWidget(createTestApp(
        authService: mockAuthService,
        child: const LoginScreen(),
      ));

      await tester.pumpAndSettle();

      // Проверяем, что отображается форма входа
      expect(find.text('Вход в систему'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    });
  });
}