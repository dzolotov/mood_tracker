import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mood_tracker_plus/screens/statistics_screen.dart';
import 'package:mood_tracker_plus/services/mood_service.dart';
import 'package:mood_tracker_plus/models/mood_entry.dart';
import '../test_helpers.dart';

void main() {
  group('StatisticsScreen', () {
    late MoodService moodService;

    setUp(() {
      initializeSharedPreferences();
      moodService = MoodService();
    });

    Widget createTestWidget() {
      return createTestApp(
        child: Scaffold(
          body: const StatisticsScreen(),
        ),
        moodService: moodService,
      );
    }

    testWidgets('should show empty state when no entries', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Проверка пустого состояния
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.text('Нет данных для статистики'), findsOneWidget);
      expect(find.text('Начните отслеживать свое настроение'), findsOneWidget);
    });

    testWidgets('should show statistics when entries exist', (WidgetTester tester) async {
      // Добавляем записи
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.veryHappy,
        timestamp: DateTime.now(),
        activities: ['Спорт', 'Семья'],
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '2',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
        activities: ['Работа', 'Спорт'],
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '3',
        mood: MoodType.veryHappy,
        timestamp: DateTime.now(),
        activities: ['Отдых'],
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка заголовков
      expect(find.text('Общая статистика'), findsOneWidget);
      expect(find.text('Распределение настроений'), findsOneWidget);
      expect(find.text('Топ активностей'), findsOneWidget);

      // Проверка общей статистики
      expect(find.text('Всего записей'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Средний уровень настроения'), findsOneWidget);
      expect(find.text('Наиболее частое настроение'), findsOneWidget);
    });

    testWidgets('should calculate mood distribution correctly', (WidgetTester tester) async {
      // Добавляем записи с разными настроениями
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.veryHappy,
        timestamp: DateTime.now(),
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '2',
        mood: MoodType.veryHappy,
        timestamp: DateTime.now(),
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '3',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '4',
        mood: MoodType.neutral,
        timestamp: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка распределения
      expect(find.text('2 (50.0%)'), findsOneWidget); // veryHappy
      expect(find.text('1 (25.0%)'), findsNWidgets(2)); // happy и neutral
      expect(find.text('0 (0.0%)'), findsNWidgets(2)); // sad и verySad

      // Проверка наличия эмодзи для всех настроений
      for (final mood in MoodType.values) {
        expect(find.text(mood.emoji), findsOneWidget);
        expect(find.text(mood.label), findsOneWidget);
      }
    });

    testWidgets('should show progress bars for mood distribution', (WidgetTester tester) async {
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.veryHappy,
        timestamp: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка наличия прогресс-баров
      expect(find.byType(LinearProgressIndicator), findsNWidgets(MoodType.values.length));
    });

    testWidgets('should calculate top activities correctly', (WidgetTester tester) async {
      // Добавляем записи с активностями
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
        activities: ['Спорт', 'Семья', 'Работа'],
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '2',
        mood: MoodType.veryHappy,
        timestamp: DateTime.now(),
        activities: ['Спорт', 'Отдых'],
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '3',
        mood: MoodType.neutral,
        timestamp: DateTime.now(),
        activities: ['Работа', 'Спорт'],
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка топ активностей
      expect(find.text('Топ активностей'), findsOneWidget);
      expect(find.text('Спорт'), findsOneWidget);
      expect(find.text('3 раз'), findsOneWidget); // Спорт встречается 3 раза
      expect(find.text('Работа'), findsOneWidget);
      expect(find.text('2 раз'), findsOneWidget); // Работа встречается 2 раза
    });

    testWidgets('should not show activities section when no activities', (WidgetTester tester) async {
      // Добавляем записи без активностей
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
        activities: [],
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка отсутствия секции активностей
      expect(find.text('Топ активностей'), findsNothing);
    });

    testWidgets('should show average mood with one decimal', (WidgetTester tester) async {
      // Добавляем записи для среднего значения
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.veryHappy, // value = 5
        timestamp: DateTime.now(),
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '2',
        mood: MoodType.happy, // value = 4
        timestamp: DateTime.now(),
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '3',
        mood: MoodType.neutral, // value = 3
        timestamp: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget());

      // Среднее: (5 + 4 + 3) / 3 = 4.0
      expect(find.text('4.0'), findsOneWidget);
    });

    testWidgets('should show most frequent mood with emoji and label', (WidgetTester tester) async {
      // Добавляем записи с преобладающим настроением
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.happy,
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

      // Проверка наиболее частого настроения
      expect(find.text('${MoodType.happy.emoji} ${MoodType.happy.label}'), findsOneWidget);
    });

    testWidgets('should limit top activities to 5', (WidgetTester tester) async {
      // Добавляем запись с множеством активностей
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
        activities: [
          'Активность1',
          'Активность2',
          'Активность3',
          'Активность4',
          'Активность5',
          'Активность6',
          'Активность7',
        ],
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка, что показано только 5 активностей
      expect(find.text('1 раз'), findsNWidgets(5));
      expect(find.text('Активность6'), findsNothing);
      expect(find.text('Активность7'), findsNothing);
    });

    testWidgets('should be scrollable', (WidgetTester tester) async {
      // Добавляем много записей
      for (int i = 0; i < 10; i++) {
        moodService.addMoodEntry(MoodEntry(
          id: i.toString(),
          mood: MoodType.values[i % MoodType.values.length],
          timestamp: DateTime.now(),
          activities: ['Activity$i'],
        ));
      }

      await tester.pumpWidget(createTestWidget());

      // Проверка наличия ListView
      expect(find.byType(ListView), findsOneWidget);

      // Попытка прокрутки
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      // Проверка, что прокрутка работает
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('should use theme colors for UI elements', (WidgetTester tester) async {
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.veryHappy,
        timestamp: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка использования темы
      final titleLargeTexts = tester.widgetList<Text>(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            widget.style?.fontSize == Theme.of(tester.element(find.byType(StatisticsScreen))).textTheme.titleLarge?.fontSize),
      );
      expect(titleLargeTexts.isNotEmpty, true);
    });
  });
}