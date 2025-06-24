import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mood_tracker_plus/screens/home_screen.dart';
import 'package:mood_tracker_plus/screens/add_mood_screen.dart';
import 'package:mood_tracker_plus/screens/mood_history_screen.dart';
import 'package:mood_tracker_plus/screens/statistics_screen.dart';
import 'package:mood_tracker_plus/screens/profile_screen.dart';
import 'package:mood_tracker_plus/services/mood_service.dart';
import 'package:mood_tracker_plus/services/theme_service.dart';
import 'package:mood_tracker_plus/services/preferences_service.dart';
import 'package:mood_tracker_plus/services/auth_service.dart';
import 'package:mood_tracker_plus/models/mood_entry.dart';
import '../test_helpers.dart';

void main() {
  group('HomeScreen', () {
    late MoodService moodService;
    late ThemeService themeService;
    late PreferencesService preferencesService;
    late AuthService authService;

    setUp(() {
      initializeSharedPreferences();
      moodService = MoodService();
      themeService = ThemeService();
      preferencesService = PreferencesService();
      authService = AuthService();
    });

    Widget createTestWidget() {
      return createTestApp(
        child: const HomeScreen(),
        moodService: moodService,
        themeService: themeService,
        preferencesService: preferencesService,
        authService: authService,
      );
    }

    testWidgets('should display app title and navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Проверка заголовка
      expect(find.text('MoodTracker++'), findsOneWidget);

      // Проверка навигации
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Главная'), findsOneWidget);
      expect(find.text('История'), findsOneWidget);
      // 'Статистика' может встречаться в навигации и на дашборде
      expect(find.text('Статистика'), findsWidgets);
      expect(find.text('Профиль'), findsOneWidget);

      // Проверка FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display theme toggle button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Проверка кнопки переключения темы
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });


    testWidgets('should toggle theme when button pressed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Изначально светлая тема
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);

      // Переключаем тему
      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pump();

      // Проверяем, что иконка изменилась
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(themeService.isDarkMode, true);
    });

    testWidgets('should show dashboard on first tab', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Проверка отображения дашборда
      expect(find.text('Как вы себя чувствуете сегодня?'), findsOneWidget);
      expect(find.byType(MoodDashboard), findsOneWidget);
    });

    testWidgets('should navigate to history screen', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Переключаемся на историю
      await tester.tap(find.text('История'));
      await tester.pumpAndSettle();

      // Проверка отображения экрана истории
      expect(find.byType(MoodHistoryScreen), findsOneWidget);
      // FAB должен исчезнуть
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('should navigate to statistics screen', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Переключаемся на статистику (находим в навигации)
      final statisticsNavItem = find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Статистика'),
      );
      await tester.tap(statisticsNavItem);
      await tester.pumpAndSettle();

      // Проверка отображения экрана статистики
      expect(find.byType(StatisticsScreen), findsOneWidget);
      // FAB должен исчезнуть
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('should navigate to profile screen', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Переключаемся на профиль
      await tester.tap(find.text('Профиль'));
      await tester.pumpAndSettle();

      // Проверка отображения экрана профиля
      expect(find.byType(ProfileScreen), findsOneWidget);
      // FAB должен исчезнуть
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('should navigate to add mood screen when FAB pressed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Нажимаем FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Проверка открытия экрана добавления настроения
      expect(find.byType(AddMoodScreen), findsOneWidget);
    });

    testWidgets('should show empty state in dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Проверка пустого состояния
      expect(find.text('Вы еще не записали настроение сегодня'), findsOneWidget);
      expect(find.text('Всего записей: 0'), findsOneWidget);
      expect(find.text('Средний уровень настроения: 0.0'), findsOneWidget);
    });

    testWidgets('should show today entries in dashboard', (WidgetTester tester) async {
      // Добавляем записи
      final now = DateTime.now();
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.veryHappy,
        timestamp: now,
        note: 'Отличный день!',
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '2',
        mood: MoodType.happy,
        timestamp: now.subtract(const Duration(hours: 2)),
      ));
      // Вчерашняя запись не должна отображаться
      moodService.addMoodEntry(MoodEntry(
        id: '3',
        mood: MoodType.sad,
        timestamp: now.subtract(const Duration(days: 1)),
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка отображения сегодняшних записей
      expect(find.text(MoodType.veryHappy.emoji), findsOneWidget);
      expect(find.text(MoodType.veryHappy.label), findsOneWidget);
      expect(find.text(MoodType.happy.emoji), findsOneWidget);
      expect(find.text(MoodType.happy.label), findsOneWidget);
      
      // Вчерашняя запись не должна отображаться
      expect(find.text(MoodType.sad.emoji), findsNothing);

      // Проверка иконки заметки
      expect(find.byIcon(Icons.note), findsOneWidget);
    });

    testWidgets('should display correct statistics in dashboard', (WidgetTester tester) async {
      // Добавляем записи
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.veryHappy,
        timestamp: DateTime.now(),
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '2',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '3',
        mood: MoodType.veryHappy,
        timestamp: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка статистики
      expect(find.text('Всего записей: 3'), findsOneWidget);
      expect(find.text('Средний уровень настроения: 4.7'), findsOneWidget);
      expect(find.text('Наиболее частое настроение: ${MoodType.veryHappy.emoji} ${MoodType.veryHappy.label}'), findsOneWidget);
    });

    testWidgets('should format time correctly in dashboard', (WidgetTester tester) async {
      // Добавляем запись с конкретным временем сегодня
      final now = DateTime.now();
      final time = DateTime(now.year, now.month, now.day, 9, 5);
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.happy,
        timestamp: time,
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка форматирования времени (с ведущим нулем)
      expect(find.text('9:05'), findsOneWidget);
    });

    testWidgets('should maintain navigation state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Переключаемся на историю
      await tester.tap(find.text('История'));
      await tester.pumpAndSettle();

      // Проверяем, что выбран правильный индекс
      final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, 1);

      // Переключаемся на статистику
      await tester.tap(find.text('Статистика'));
      await tester.pumpAndSettle();

      // Проверяем индекс
      final bottomNav2 = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav2.currentIndex, 2);
    });

    testWidgets('should show FAB only on main screen', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // На главной есть FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Переключаемся на историю
      await tester.tap(find.text('История'));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsNothing);

      // Возвращаемся на главную
      await tester.tap(find.text('Главная'));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should use proper styling for cards', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Проверка наличия карточек
      expect(find.byType(Card), findsNWidgets(2));

      // Проверка отступов
      final padding = find.byType(Padding);
      expect(padding, findsWidgets);
    });

    testWidgets('should handle empty most frequent mood', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // При пустом сервисе не должно быть текста о наиболее частом настроении
      expect(find.textContaining('Наиболее частое настроение:'), findsNothing);
    });
  });
}