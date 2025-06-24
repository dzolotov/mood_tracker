import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mood_tracker_plus/screens/mood_history_screen.dart';
import 'package:mood_tracker_plus/services/mood_service.dart';
import 'package:mood_tracker_plus/models/mood_entry.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../test_helpers.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru', null);
  });
  group('MoodHistoryScreen', () {
    late MoodService moodService;

    setUp(() {
      initializeSharedPreferences();
      moodService = MoodService();
    });

    Widget createTestWidget() {
      return createTestApp(
        child: Scaffold(
          body: const MoodHistoryScreen(),
        ),
        moodService: moodService,
      );
    }

    testWidgets('should show empty state when no entries', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Проверка пустого состояния
      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.text('История пуста'), findsOneWidget);
      expect(find.text('Добавьте свое первое настроение'), findsOneWidget);
    });

    testWidgets('should display entries when they exist', (WidgetTester tester) async {
      // Добавляем записи
      final now = DateTime.now();
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.veryHappy,
        timestamp: now,
        note: 'Отличный день!',
        activities: ['Спорт', 'Семья'],
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '2',
        mood: MoodType.happy,
        timestamp: now.subtract(const Duration(hours: 3)),
        activities: ['Работа'],
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка отображения записей
      expect(find.text(MoodType.veryHappy.emoji), findsOneWidget);
      expect(find.text(MoodType.veryHappy.label), findsOneWidget);
      expect(find.text(MoodType.happy.emoji), findsOneWidget);
      expect(find.text(MoodType.happy.label), findsOneWidget);
      
      // Проверка заметки
      expect(find.text('Отличный день!'), findsOneWidget);
      
      // Проверка активностей
      expect(find.text('Спорт'), findsOneWidget);
      expect(find.text('Семья'), findsOneWidget);
      expect(find.text('Работа'), findsOneWidget);
    });

    testWidgets('should group entries by date', (WidgetTester tester) async {
      // Добавляем записи за разные дни
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.veryHappy,
        timestamp: today,
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '2',
        mood: MoodType.happy,
        timestamp: yesterday,
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка группировки по датам
      final todayFormatted = DateFormat('dd MMMM yyyy', 'ru').format(today);
      final yesterdayFormatted = DateFormat('dd MMMM yyyy', 'ru').format(yesterday);
      
      expect(find.text(todayFormatted), findsOneWidget);
      expect(find.text(yesterdayFormatted), findsOneWidget);
    });

    testWidgets('should display entries in reverse chronological order', (WidgetTester tester) async {
      // Добавляем записи в разном порядке
      final now = DateTime.now();
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.sad,
        timestamp: now.subtract(const Duration(hours: 2)),
      ));
      moodService.addMoodEntry(MoodEntry(
        id: '2',
        mood: MoodType.veryHappy,
        timestamp: now,
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверяем порядок - новые записи сверху
      final cards = find.byType(Card);
      expect(cards, findsNWidgets(2));
      
      // Первая карточка должна содержать excellent (более новая)
      final firstCard = cards.first;
      expect(
        find.descendant(of: firstCard, matching: find.text(MoodType.veryHappy.emoji)),
        findsOneWidget,
      );
    });

    testWidgets('should display time for each entry', (WidgetTester tester) async {
      final now = DateTime.now();
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.happy,
        timestamp: DateTime(now.year, now.month, now.day, 14, 30),
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка отображения времени
      expect(find.text('14:30'), findsOneWidget);
    });

    testWidgets('should display sleep duration when available', (WidgetTester tester) async {
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
        sleepDuration: const Duration(hours: 7, minutes: 30),
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка отображения продолжительности сна
      expect(find.byIcon(Icons.bedtime), findsOneWidget);
      expect(find.text('Сон: 7ч 30мин'), findsOneWidget);
    });

    testWidgets('should show delete button for each entry', (WidgetTester tester) async {
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка кнопки удаления
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog', (WidgetTester tester) async {
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget());

      // Нажимаем кнопку удаления
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Проверка диалога подтверждения
      expect(find.text('Удалить запись?'), findsOneWidget);
      expect(find.text('Это действие нельзя отменить'), findsOneWidget);
      expect(find.text('Отмена'), findsOneWidget);
      expect(find.text('Удалить'), findsOneWidget);
    });

    testWidgets('should delete entry when confirmed', (WidgetTester tester) async {
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget());

      // Нажимаем кнопку удаления
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Подтверждаем удаление
      await tester.tap(find.text('Удалить'));
      await tester.pumpAndSettle();

      // Проверяем, что запись удалена
      expect(moodService.entries.length, 0);
      expect(find.text('История пуста'), findsOneWidget);
    });

    testWidgets('should cancel deletion when cancelled', (WidgetTester tester) async {
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget());

      // Нажимаем кнопку удаления
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Отменяем удаление
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      // Проверяем, что запись не удалена
      expect(moodService.entries.length, 1);
      expect(find.text(MoodType.happy.emoji), findsOneWidget);
    });

    testWidgets('should display multiple activities as chips', (WidgetTester tester) async {
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
        activities: ['Спорт', 'Работа', 'Отдых'],
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка отображения активностей как чипов
      expect(find.byType(Chip), findsNWidgets(3));
      expect(find.text('Спорт'), findsOneWidget);
      expect(find.text('Работа'), findsOneWidget);
      expect(find.text('Отдых'), findsOneWidget);
    });

    testWidgets('should truncate long notes', (WidgetTester tester) async {
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
        note: 'Это очень длинная заметка, которая должна быть обрезана, потому что она слишком длинная для отображения в карточке истории. Продолжаем писать текст, чтобы точно превысить лимит.',
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка, что заметка отображается с ограничением
      final noteWidget = tester.widget<Text>(
        find.byWidgetPredicate((widget) => 
          widget is Text && 
          widget.data != null &&
          widget.data!.startsWith('Это очень длинная заметка')
        ),
      );
      expect(noteWidget.maxLines, 2);
      expect(noteWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should use mood color for entry decoration', (WidgetTester tester) async {
      moodService.addMoodEntry(MoodEntry(
        id: '1',
        mood: MoodType.veryHappy,
        timestamp: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget());

      // Проверка использования цвета настроения
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration
          ),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, MoodType.veryHappy.color.withAlpha((0.2 * 255).round()));
    });

    testWidgets('should be scrollable with many entries', (WidgetTester tester) async {
      // Добавляем много записей
      for (int i = 0; i < 20; i++) {
        moodService.addMoodEntry(MoodEntry(
          id: i.toString(),
          mood: MoodType.values[i % MoodType.values.length],
          timestamp: DateTime.now().subtract(Duration(hours: i)),
        ));
      }

      await tester.pumpWidget(createTestWidget());

      // Проверка наличия прокручиваемого виджета
      expect(find.byType(Scrollable), findsWidgets);

      // Попытка прокрутки - находим первую карточку и прокручиваем
      await tester.drag(find.byType(Card).first, const Offset(0, -300));
      await tester.pump();

      // Проверка, что прокрутка работает
      expect(find.byType(Card), findsWidgets);
    });
  });
}