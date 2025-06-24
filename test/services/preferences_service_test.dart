import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker_plus/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesService', () {
    late PreferencesService preferencesService;
    late DateTime beforeTest;

    // Функция для инициализации SharedPreferences с моком
    Future<void> initSharedPreferences([Map<String, Object>? values]) async {
      SharedPreferences.setMockInitialValues(values ?? {});
      beforeTest = DateTime.now();
      preferencesService = PreferencesService();
      // Даем время для загрузки настроек
      await Future.delayed(const Duration(milliseconds: 100));
    }

    tearDown(() {
      // Очищаем мок после каждого теста
      SharedPreferences.setMockInitialValues({});
    });

    test('should start with default values when no saved preferences', () async {
      await initSharedPreferences();

      expect(preferencesService.notificationsEnabled, true);
      expect(preferencesService.appOpenCount, 1); // Увеличивается при инициализации
      expect(preferencesService.favoriteActivities, []);
      expect(preferencesService.defaultMoodReminder, 20.0);
    });

    test('should load saved preferences', () async {
      final savedTime = DateTime(2024, 1, 1, 12, 0);
      await initSharedPreferences({
        'notifications_enabled': false,
        'app_open_count': 5,
        'last_opened': savedTime.toIso8601String(),
        'favorite_activities': ['work', 'exercise', 'reading'],
        'default_mood_reminder': 18.5,
      });

      expect(preferencesService.notificationsEnabled, false);
      expect(preferencesService.appOpenCount, 6); // 5 + 1
      expect(preferencesService.lastOpened, savedTime);
      expect(preferencesService.favoriteActivities, ['work', 'exercise', 'reading']);
      expect(preferencesService.defaultMoodReminder, 18.5);
    });

    test('should increment app open count on initialization', () async {
      await initSharedPreferences({'app_open_count': 10});

      expect(preferencesService.appOpenCount, 11);

      // Проверяем, что значение сохранено
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('app_open_count'), 11);
    });

    test('should save current time as last opened', () async {
      await initSharedPreferences();

      // Проверяем, что время сохранено
      final prefs = await SharedPreferences.getInstance();
      final savedTime = prefs.getString('last_opened');
      expect(savedTime, isNotNull);

      final parsedTime = DateTime.parse(savedTime!);
      expect(parsedTime.isAfter(beforeTest), true);
      expect(parsedTime.isBefore(DateTime.now().add(const Duration(seconds: 1))), true);
    });

    group('setNotificationsEnabled', () {
      test('should update and save notifications preference', () async {
        await initSharedPreferences();

        await preferencesService.setNotificationsEnabled(false);

        expect(preferencesService.notificationsEnabled, false);

        // Проверяем, что значение сохранено
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('notifications_enabled'), false);
      });

      test('should notify listeners when notifications preference changes', () async {
        await initSharedPreferences();

        bool notified = false;
        preferencesService.addListener(() => notified = true);

        await preferencesService.setNotificationsEnabled(false);

        expect(notified, true);
      });
    });

    group('updateFavoriteActivities', () {
      test('should update and save favorite activities', () async {
        await initSharedPreferences();

        final activities = ['coding', 'running', 'meditation'];
        await preferencesService.updateFavoriteActivities(activities);

        expect(preferencesService.favoriteActivities, activities);

        // Проверяем, что значение сохранено
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getStringList('favorite_activities'), activities);
      });

      test('should create a copy of activities list', () async {
        await initSharedPreferences();

        final activities = ['coding', 'running'];
        await preferencesService.updateFavoriteActivities(activities);

        // Изменяем исходный список
        activities.add('meditation');

        // Убеждаемся, что сохраненный список не изменился
        expect(preferencesService.favoriteActivities, ['coding', 'running']);
      });

      test('should notify listeners when activities change', () async {
        await initSharedPreferences();

        bool notified = false;
        preferencesService.addListener(() => notified = true);

        await preferencesService.updateFavoriteActivities(['coding']);

        expect(notified, true);
      });
    });

    group('setDefaultMoodReminder', () {
      test('should update and save mood reminder time', () async {
        await initSharedPreferences();

        await preferencesService.setDefaultMoodReminder(24.0);

        expect(preferencesService.defaultMoodReminder, 24.0);

        // Проверяем, что значение сохранено
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getDouble('default_mood_reminder'), 24.0);
      });

      test('should notify listeners when reminder time changes', () async {
        await initSharedPreferences();

        bool notified = false;
        preferencesService.addListener(() => notified = true);

        await preferencesService.setDefaultMoodReminder(16.5);

        expect(notified, true);
      });
    });

    group('hasUserOpenedAppBefore', () {
      test('should return false when no last_opened key exists', () async {
        await initSharedPreferences();
        
        // Очищаем last_opened, который был установлен при инициализации
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('last_opened');

        final result = await preferencesService.hasUserOpenedAppBefore();
        expect(result, false);
      });

      test('should return true when last_opened key exists', () async {
        await initSharedPreferences({'last_opened': '2024-01-01T12:00:00'});

        final result = await preferencesService.hasUserOpenedAppBefore();
        expect(result, true);
      });
    });

    group('getAllPreferenceKeys', () {
      test('should return all stored preference keys', () async {
        await initSharedPreferences({
          'notifications_enabled': true,
          'app_open_count': 1,
          'favorite_activities': ['work'],
        });

        final keys = await preferencesService.getAllPreferenceKeys();

        expect(keys.contains('notifications_enabled'), true);
        expect(keys.contains('app_open_count'), true);
        expect(keys.contains('favorite_activities'), true);
        expect(keys.contains('last_opened'), true); // Добавляется при инициализации
      });
    });

    group('clearAllPreferences', () {
      test('should clear all preferences and reset to defaults', () async {
        await initSharedPreferences({
          'notifications_enabled': false,
          'app_open_count': 10,
          'favorite_activities': ['work', 'exercise'],
          'default_mood_reminder': 15.0,
        });

        await preferencesService.clearAllPreferences();

        expect(preferencesService.notificationsEnabled, true);
        expect(preferencesService.appOpenCount, 0);
        expect(preferencesService.lastOpened, null);
        expect(preferencesService.favoriteActivities, []);
        expect(preferencesService.defaultMoodReminder, 20.0);

        // Проверяем, что SharedPreferences очищены
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();
        expect(keys.isEmpty, true);
      });

      test('should notify listeners when preferences are cleared', () async {
        await initSharedPreferences();

        bool notified = false;
        preferencesService.addListener(() => notified = true);

        await preferencesService.clearAllPreferences();

        expect(notified, true);
      });
    });

    group('reloadPreferences', () {
      test('should reload preferences from disk', () async {
        await initSharedPreferences({'app_open_count': 5});

        // Получаем прямой доступ к SharedPreferences и меняем значение
        final prefs = await SharedPreferences.getInstance();
        
        // Сначала изменяем значение в памяти сервиса
        await preferencesService.setNotificationsEnabled(false);
        
        // Затем изменяем значение напрямую в SharedPreferences
        await prefs.setBool('notifications_enabled', true);
        await prefs.setInt('app_open_count', 10);

        // Перезагружаем настройки
        await preferencesService.reloadPreferences();

        // Проверяем, что значения обновились из SharedPreferences
        expect(preferencesService.notificationsEnabled, true);
        expect(preferencesService.appOpenCount, 11); // 10 + 1 при перезагрузке
      });
    });

    group('persistence', () {
      test('should persist preferences across service instances', () async {
        // Первый экземпляр сервиса
        await initSharedPreferences();
        await preferencesService.setNotificationsEnabled(false);
        await preferencesService.updateFavoriteActivities(['coding', 'music']);
        await preferencesService.setDefaultMoodReminder(16.0);

        // Создаем новый экземпляр сервиса
        final newPreferencesService = PreferencesService();
        await Future.delayed(const Duration(milliseconds: 100));

        // Проверяем, что настройки загрузились правильно
        expect(newPreferencesService.notificationsEnabled, false);
        expect(newPreferencesService.favoriteActivities, ['coding', 'music']);
        expect(newPreferencesService.defaultMoodReminder, 16.0);
      });
    });
  });
}