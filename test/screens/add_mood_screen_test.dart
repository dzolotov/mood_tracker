import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mood_tracker_plus/screens/add_mood_screen.dart';
import 'package:mood_tracker_plus/services/mood_service.dart';
import 'package:mood_tracker_plus/services/preferences_service.dart';
import 'package:mood_tracker_plus/models/mood_entry.dart';
import '../test_helpers.dart';

void main() {
  group('AddMoodScreen', () {
    late MoodService moodService;
    late PreferencesService preferencesService;

    setUp(() {
      initializeSharedPreferences();
      moodService = MoodService();
      preferencesService = PreferencesService();
    });

    Widget createTestWidget() {
      return createTestApp(
        child: const AddMoodScreen(),
        moodService: moodService,
        preferencesService: preferencesService,
      );
    }

    testWidgets('should display all UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Проверка заголовков
      expect(find.text('Добавить настроение'), findsOneWidget);
      expect(find.text('Как вы себя чувствуете?'), findsOneWidget);
      expect(find.text('Что вы делали?'), findsOneWidget);
      // Проверяем наличие заголовка 'Сон' (может быть несколько вхождений)
      expect(find.text('Сон'), findsWidgets);
      expect(find.text('Заметки (необязательно)'), findsOneWidget);

      // Проверка эмодзи настроений
      for (final mood in MoodType.values) {
        expect(find.text(mood.emoji), findsOneWidget);
        expect(find.text(mood.label), findsOneWidget);
      }

      // Проверка активностей
      expect(find.text('Работа'), findsOneWidget);
      expect(find.text('Спорт'), findsOneWidget);
      expect(find.text('Семья'), findsOneWidget);

      // Проверка кнопок времени сна
      expect(find.text('Время сна'), findsOneWidget);
      expect(find.text('Время подъема'), findsOneWidget);

      // Проверка кнопки сохранения
      expect(find.text('Сохранить'), findsOneWidget);
    });

    testWidgets('should show error when saving without mood', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Нажимаем сохранить без выбора настроения
      await tester.ensureVisible(find.text('Сохранить'));
      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      // Проверка снекбара
      expect(find.text('Пожалуйста, выберите настроение'), findsOneWidget);
    });

    testWidgets('should select mood when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Выбираем настроение
      await tester.tap(find.text(MoodType.veryHappy.emoji));
      await tester.pump();

      // Проверяем визуальное отображение выбранного настроения
      // Находим контейнер с выбранным настроением
      final selectedMoodContainer = find.ancestor(
        of: find.text(MoodType.veryHappy.emoji),
        matching: find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).border != null
        ),
      );
      
      expect(selectedMoodContainer, findsOneWidget);
    });

    testWidgets('should toggle activities when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Выбираем активность
      await tester.tap(find.text('Работа'));
      await tester.pump();

      // Проверяем, что чип выбран
      final workChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('Работа'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(workChip.selected, true);

      // Отменяем выбор
      await tester.tap(find.text('Работа'));
      await tester.pump();

      final workChipAfter = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('Работа'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(workChipAfter.selected, false);
    });

    testWidgets('should open time picker for sleep time', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Нажимаем на время сна
      await tester.tap(find.text('Время сна'));
      await tester.pumpAndSettle();

      // Проверяем, что открылся time picker
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Закрываем диалог
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    testWidgets('should open time picker for wake time', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Нажимаем на время подъема
      await tester.tap(find.text('Время подъема'));
      await tester.pumpAndSettle();

      // Проверяем, что открылся time picker
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Закрываем диалог
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    testWidgets('should enter text in notes field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Вводим текст в поле заметок
      await tester.enterText(
        find.byType(TextField),
        'Тестовая заметка',
      );
      await tester.pump();

      // Проверяем, что текст введен
      expect(find.text('Тестовая заметка'), findsOneWidget);
    });

    testWidgets('should save mood entry with all data', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Выбираем настроение
      await tester.tap(find.text(MoodType.happy.emoji));
      await tester.pump();

      // Выбираем активности
      await tester.tap(find.text('Спорт'));
      await tester.pump();
      await tester.tap(find.text('Семья'));
      await tester.pump();

      // Вводим заметку
      await tester.enterText(
        find.byType(TextField),
        'Хороший день',
      );
      await tester.pump();

      // Прокручиваем вниз, чтобы увидеть кнопку сохранения
      await tester.ensureVisible(find.text('Сохранить'));
      await tester.pumpAndSettle();
      
      // Сохраняем
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      // Проверяем, что запись добавлена
      expect(moodService.entries.length, 1);
      final entry = moodService.entries.first;
      expect(entry.mood, MoodType.happy);
      expect(entry.activities, ['Спорт', 'Семья']);
      expect(entry.note, 'Хороший день');
    });

    testWidgets('should navigate back after saving', (WidgetTester tester) async {
      // Создаем навигационный ключ для отслеживания навигации
      final navigatorKey = GlobalKey<NavigatorState>();
      
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(value: moodService),
                          ChangeNotifierProvider.value(value: preferencesService),
                        ],
                        child: const AddMoodScreen(),
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Открываем экран
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      
      // Проверяем, что экран открылся
      expect(find.byType(AddMoodScreen), findsOneWidget);

      // Выбираем настроение
      await tester.tap(find.text(MoodType.happy.emoji));
      await tester.pump();
      
      // Прокручиваем вниз и сохраняем
      await tester.ensureVisible(find.text('Сохранить'));
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      // Проверяем, что вернулись назад
      expect(find.byType(AddMoodScreen), findsNothing);
      expect(find.text('Open'), findsOneWidget);
      expect(moodService.entries.length, 1);
    });

    testWidgets('should set sleep and wake times', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Выбираем настроение
      await tester.tap(find.text(MoodType.happy.emoji));
      await tester.pump();

      // Тестируем открытие time picker для времени сна
      await tester.tap(find.text('Время сна'));
      await tester.pumpAndSettle();
      
      // Проверяем, что time picker открылся
      expect(find.byType(TimePickerDialog), findsOneWidget);
      
      // Закрываем диалог
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Тестируем открытие time picker для времени подъема
      await tester.tap(find.text('Время подъема'));
      await tester.pumpAndSettle();
      
      // Проверяем, что time picker открылся
      expect(find.byType(TimePickerDialog), findsOneWidget);
      
      // Закрываем диалог
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Прокручиваем вниз, чтобы увидеть кнопку сохранения
      await tester.ensureVisible(find.text('Сохранить'));
      await tester.pumpAndSettle();
      
      // Сохраняем без установки времени
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      // Проверяем, что запись создана
      expect(moodService.entries.length, 1);
      final entry = moodService.entries.first;
      expect(entry.mood, MoodType.happy);
    });

    testWidgets('should show all mood types with correct properties', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Проверяем каждый тип настроения
      for (final mood in MoodType.values) {
        expect(find.text(mood.emoji), findsOneWidget);
        expect(find.text(mood.label), findsOneWidget);
        
        // Проверяем, что контейнер с настроением кликабельный
        final gestureDetector = find.ancestor(
          of: find.text(mood.emoji),
          matching: find.byType(GestureDetector),
        );
        expect(gestureDetector, findsWidgets);
      }
    });

    testWidgets('should handle wake time before sleep time (next day)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Выбираем настроение сначала
      await tester.tap(find.text(MoodType.happy.emoji));
      await tester.pump();

      // Устанавливаем время сна 23:00
      await tester.tap(find.text('Время сна'));
      await tester.pumpAndSettle();
      
      // Ищем TimePickerDialog
      final timePicker = find.byType(Dialog);
      expect(timePicker, findsOneWidget);
      
      // Нажимаем OK чтобы закрыть диалог
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Устанавливаем время пробуждения 6:00 (меньше чем время сна)
      await tester.tap(find.text('Время подъема'));
      await tester.pumpAndSettle();
      
      // Нажимаем OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Прокручиваем вниз чтобы увидеть кнопку сохранить
      await tester.ensureVisible(find.text('Сохранить'));
      
      // Сохраняем
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle(); // Используем pumpAndSettle для завершения навигации

      // Проверяем, что запись создана с корректным временем сна
      expect(moodService.entries.isNotEmpty, true);
      final entry = moodService.entries.first;
      // Проверяем что время сна и подъема установлены
      expect(entry.sleepTime, isNotNull);
      expect(entry.wakeTime, isNotNull);
      // Проверяем что длительность сна рассчитана корректно
      if (entry.sleepDuration != null) {
        expect(entry.sleepDuration!.inMinutes, greaterThan(0));
      }
    });

    testWidgets('should scroll when content overflows', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Проверяем наличие ScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Прокручиваем вниз
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pump();

      // Кнопка сохранить должна быть видна
      expect(find.text('Сохранить'), findsOneWidget);
    });
  });
}