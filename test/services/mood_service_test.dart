import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mood_tracker_plus/models/mood_entry.dart';
import 'package:mood_tracker_plus/services/mood_service.dart';
import 'package:mood_tracker_plus/services/database_service.dart';
import 'package:mood_tracker_plus/services/realm_service.dart';

// Моки для тестирования
class MockDatabaseService extends Mock implements DatabaseService {}
class MockRealmService extends Mock implements RealmService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('MoodService', () {
    late MoodService moodService;
    late MockDatabaseService mockDatabaseService;
    late MockRealmService mockRealmService;
    late MoodEntry testEntry;
    late Directory tempDir;

    setUpAll(() async {
      // Создаем временную директорию для тестовых баз данных
      tempDir = await Directory.systemTemp.createTemp('mood_service_test_');
      
      // Мокируем path_provider plugin
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getApplicationDocumentsDirectory':
            case 'getApplicationSupportDirectory':
            case 'getTemporaryDirectory':
              return tempDir.path;
            default:
              return null;
          }
        },
      );
      
      // Инициализируем реальные сервисы базы данных для интеграционных тестов
      await DatabaseService.initialize();
      await RealmService.initialize();
    });

    tearDownAll(() async {
      // Очищаем ресурсы
      DatabaseService.instance.dispose();
      RealmService.instance.dispose();
      
      // Очищаем мок path_provider
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
      
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    setUp(() async {
      moodService = MoodService();
      mockDatabaseService = MockDatabaseService();
      mockRealmService = MockRealmService();
      
      // Очищаем данные в реальных базах перед каждым тестом
      await DatabaseService.instance.clearAllData();
      await RealmService.instance.clearAllData();
      
      testEntry = MoodEntry(
        id: 'test-1',
        mood: MoodType.happy,
        timestamp: DateTime(2024, 1, 1, 12, 0),
        note: 'Test note',
        activities: ['work', 'reading'],
        sleepDuration: const Duration(hours: 8),
      );
    });

    group('Initialization', () {
      test('should initialize and load existing entries', () async {
        // Добавляем запись напрямую в базу
        await DatabaseService.instance.saveMoodEntry(testEntry);
        
        // Инициализируем MoodService
        await moodService.initialize();
        
        expect(moodService.entries.length, equals(1));
        expect(moodService.entries.first.id, equals('test-1'));
      });

      test('should start with empty entries when no data exists', () async {
        await moodService.initialize();
        expect(moodService.entries, isEmpty);
      });

      test('should handle initialization errors gracefully', () async {
        // Тест должен пройти даже если есть ошибки инициализации
        await moodService.initialize();
        expect(moodService.entries, isNotNull);
      });
    });

    group('Adding Mood Entries', () {
      test('should add entry to database and update local list', () async {
        await moodService.initialize();
        await moodService.addMoodEntry(testEntry);
        
        expect(moodService.entries.length, equals(1));
        expect(moodService.entries.first.id, equals('test-1'));
        expect(moodService.entries.first.mood, equals(MoodType.happy));
      });

      test('should notify listeners when entry is added', () async {
        await moodService.initialize();
        bool notified = false;
        moodService.addListener(() => notified = true);
        
        await moodService.addMoodEntry(testEntry);
        
        expect(notified, isTrue);
      });

      test('should update activity usage in Realm when adding entry', () async {
        await moodService.initialize();
        await moodService.addMoodEntry(testEntry);
        
        // Проверяем что активности были добавлены в Realm
        final activities = await RealmService.instance.getAllActivities();
        expect(activities.length, greaterThanOrEqualTo(2));
        
        final activityNames = activities.map((a) => a.name).toList();
        expect(activityNames, contains('work'));
        expect(activityNames, contains('reading'));
      });

      test('should update daily statistics when adding entry', () async {
        await moodService.initialize();
        await moodService.addMoodEntry(testEntry);
        
        // Проверяем что статистика была обновлена
        final stats = await RealmService.instance.getStatisticsByType('daily');
        expect(stats.length, equals(1));
        expect(stats.first.entryCount, equals(1));
      });

      test('should handle errors when adding entry', () async {
        await moodService.initialize();
        
        // Тест с невалидными данными (очень длинный ID)
        final invalidEntry = testEntry.copyWith(
          id: 'x' * 10000, // Очень длинный ID
        );
        
        // Должно обработать ошибку gracefully
        await moodService.addMoodEntry(invalidEntry);
        // Тест проходит, если не выбрасывается исключение
      });
    });

    group('Updating Mood Entries', () {
      setUp(() async {
        await moodService.initialize();
        await moodService.addMoodEntry(testEntry);
      });

      test('should update existing entry in database', () async {
        final updatedEntry = testEntry.copyWith(
          mood: MoodType.sad,
          note: 'Updated note',
          activities: ['sleeping'],
        );
        
        await moodService.updateMoodEntry(testEntry.id, updatedEntry);
        
        expect(moodService.entries.length, equals(1));
        expect(moodService.entries.first.mood, equals(MoodType.sad));
        expect(moodService.entries.first.note, equals('Updated note'));
        expect(moodService.entries.first.activities, equals(['sleeping']));
      });

      test('should update activity usage when updating entry', () async {
        final updatedEntry = testEntry.copyWith(
          activities: ['exercise', 'meditation'],
        );
        
        await moodService.updateMoodEntry(testEntry.id, updatedEntry);
        
        // Проверяем что новые активности были добавлены
        final activities = await RealmService.instance.getAllActivities();
        final activityNames = activities.map((a) => a.name).toList();
        expect(activityNames, contains('exercise'));
        expect(activityNames, contains('meditation'));
      });

      test('should notify listeners when entry is updated', () async {
        bool notified = false;
        moodService.addListener(() => notified = true);
        
        final updatedEntry = testEntry.copyWith(mood: MoodType.neutral);
        await moodService.updateMoodEntry(testEntry.id, updatedEntry);
        
        expect(notified, isTrue);
      });
    });

    group('Deleting Mood Entries', () {
      setUp(() async {
        await moodService.initialize();
        await moodService.addMoodEntry(testEntry);
      });

      test('should delete entry from database and update local list', () async {
        expect(moodService.entries.length, equals(1));
        
        await moodService.deleteMoodEntry(testEntry.id);
        
        expect(moodService.entries, isEmpty);
      });

      test('should notify listeners when entry is deleted', () async {
        bool notified = false;
        moodService.addListener(() => notified = true);
        
        await moodService.deleteMoodEntry(testEntry.id);
        
        expect(notified, isTrue);
      });

      test('should handle deletion of non-existent entry gracefully', () async {
        await moodService.deleteMoodEntry('non-existent-id');
        
        // Исходная запись должна остаться
        expect(moodService.entries.length, equals(1));
      });
    });

    group('Clearing All Entries', () {
      setUp(() async {
        await moodService.initialize();
        await moodService.addMoodEntry(testEntry);
        
        final entry2 = testEntry.copyWith(
          id: 'test-2',
          mood: MoodType.neutral,
        );
        await moodService.addMoodEntry(entry2);
      });

      test('should clear all entries from both databases', () async {
        expect(moodService.entries.length, equals(2));
        
        await moodService.clearEntries();
        
        expect(moodService.entries, isEmpty);
        
        // Проверяем что данные очищены в обеих базах
        final dbEntries = await DatabaseService.instance.getAllMoodEntries();
        expect(dbEntries, isEmpty);
        
        final activities = await RealmService.instance.getAllActivities();
        expect(activities, isEmpty);
        
        final stats = await RealmService.instance.getStatisticsByType('daily');
        expect(stats, isEmpty);
      });

      test('should notify listeners when entries are cleared', () async {
        bool notified = false;
        moodService.addListener(() => notified = true);
        
        await moodService.clearEntries();
        
        expect(notified, isTrue);
      });
    });

    group('Querying Entries', () {
      late List<MoodEntry> testEntries;

      setUp(() async {
        await moodService.initialize();
        
        testEntries = [
          MoodEntry(
            id: 'entry-1',
            mood: MoodType.happy,
            timestamp: DateTime(2024, 1, 1, 10, 0),
            activities: ['work'],
          ),
          MoodEntry(
            id: 'entry-2',
            mood: MoodType.neutral,
            timestamp: DateTime(2024, 1, 2, 10, 0),
            activities: ['reading'],
          ),
          MoodEntry(
            id: 'entry-3',
            mood: MoodType.sad,
            timestamp: DateTime(2024, 1, 3, 10, 0),
            activities: ['sleeping'],
          ),
        ];

        for (final entry in testEntries) {
          await moodService.addMoodEntry(entry);
        }
      });

      test('should get entry by ID', () async {
        final retrieved = await moodService.getMoodEntryById('entry-2');
        
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals('entry-2'));
        expect(retrieved.mood, equals(MoodType.neutral));
      });

      test('should return null for non-existent entry ID', () async {
        final retrieved = await moodService.getMoodEntryById('non-existent');
        expect(retrieved, isNull);
      });

      test('should get entries by date range', () async {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 2, 23, 59);
        
        final entries = await moodService.getEntriesByDateRange(start, end);
        
        expect(entries.length, equals(2));
        expect(entries.map((e) => e.id), containsAll(['entry-1', 'entry-2']));
      });

      test('should return empty list for date range with no entries', () async {
        final start = DateTime(2025, 1, 1);
        final end = DateTime(2025, 1, 2);
        
        final entries = await moodService.getEntriesByDateRange(start, end);
        
        expect(entries, isEmpty);
      });
    });

    group('Statistics and Analytics', () {
      setUp(() async {
        await moodService.initialize();
        
        final entries = [
          MoodEntry(
            id: 'happy-1',
            mood: MoodType.happy, // value = 4
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            activities: ['exercise'],
            sleepDuration: const Duration(hours: 8),
          ),
          MoodEntry(
            id: 'very-happy-1',
            mood: MoodType.veryHappy, // value = 5
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            activities: ['party'],
            sleepDuration: const Duration(hours: 7),
          ),
          MoodEntry(
            id: 'sad-1',
            mood: MoodType.sad, // value = 2
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            activities: ['work'],
            sleepDuration: const Duration(hours: 6),
          ),
        ];

        for (final entry in entries) {
          await moodService.addMoodEntry(entry);
        }
      });

      test('should calculate average mood correctly', () async {
        final average = await moodService.getAverageMood();
        
        // (4 + 5 + 2) / 3 = 3.67
        expect(average, closeTo(3.67, 0.01));
      });

      test('should find most frequent mood', () async {
        // Добавляем еще одну happy запись для создания большинства
        await moodService.addMoodEntry(MoodEntry(
          id: 'happy-2',
          mood: MoodType.happy,
          timestamp: DateTime.now(),
          activities: ['reading'],
        ));
        
        final mostFrequent = await moodService.getMostFrequentMood();
        
        expect(mostFrequent, equals(MoodType.happy));
      });

      test('should return null for most frequent mood when no entries', () async {
        await moodService.clearEntries();
        
        final mostFrequent = await moodService.getMostFrequentMood();
        
        expect(mostFrequent, isNull);
      });

      test('should get mood distribution', () async {
        final distribution = await moodService.getMoodDistribution();
        
        expect(distribution[MoodType.veryHappy], equals(1));
        expect(distribution[MoodType.happy], equals(1));
        expect(distribution[MoodType.neutral], equals(0));
        expect(distribution[MoodType.sad], equals(1));
        expect(distribution[MoodType.verySad], equals(0));
      });

      test('should return empty distribution when no entries', () async {
        await moodService.clearEntries();
        
        final distribution = await moodService.getMoodDistribution();
        
        for (final mood in MoodType.values) {
          expect(distribution[mood], equals(0));
        }
      });
    });

    group('Backward Compatibility', () {
      test('should support legacy addEntry method', () async {
        await moodService.initialize();
        
        // Используем старый метод addEntry
        await moodService.addEntry(testEntry);
        
        expect(moodService.entries.length, equals(1));
        expect(moodService.entries.first.id, equals('test-1'));
      });
    });

    group('Integration with NoSQL Services', () {
      test('should create daily statistics when adding entries', () async {
        await moodService.initialize();
        
        final today = DateTime.now();
        final entry1 = MoodEntry(
          id: 'today-1',
          mood: MoodType.happy,
          timestamp: today,
          activities: ['work', 'exercise'],
          sleepDuration: const Duration(hours: 8),
        );
        
        final entry2 = MoodEntry(
          id: 'today-2',
          mood: MoodType.veryHappy,
          timestamp: today.add(const Duration(hours: 2)),
          activities: ['reading', 'exercise'],
          sleepDuration: const Duration(minutes: 450),
        );
        
        await moodService.addMoodEntry(entry1);
        await moodService.addMoodEntry(entry2);
        
        // Проверяем что статистика создалась
        final stats = await RealmService.instance.getStatisticsByType('daily');
        expect(stats.length, equals(1));
        
        final dailyStats = stats.first;
        expect(dailyStats.entryCount, equals(2));
        expect(dailyStats.averageMood, equals(4.5)); // (4 + 5) / 2
        expect(dailyStats.totalSleepMinutes, equals(930)); // 8*60 + 7.5*60
        expect(dailyStats.topActivities, contains('exercise')); // Наиболее частая активность
      });

      test('should track activity usage across entries', () async {
        await moodService.initialize();
        
        final entries = [
          MoodEntry(
            id: 'act-1',
            mood: MoodType.happy,
            timestamp: DateTime.now(),
            activities: ['exercise'],
          ),
          MoodEntry(
            id: 'act-2',
            mood: MoodType.neutral,
            timestamp: DateTime.now(),
            activities: ['exercise', 'reading'],
          ),
          MoodEntry(
            id: 'act-3',
            mood: MoodType.happy,
            timestamp: DateTime.now(),
            activities: ['exercise'],
          ),
        ];
        
        for (final entry in entries) {
          await moodService.addMoodEntry(entry);
        }
        
        // Проверяем подсчет использования активностей
        final mostUsed = await RealmService.instance.getMostUsedActivities(2);
        expect(mostUsed.length, greaterThanOrEqualTo(1));
        expect(mostUsed.first.name, equals('exercise'));
        expect(mostUsed.first.usageCount, equals(3));
      });
    });

    group('Error Handling', () {
      test('should handle database errors gracefully', () async {
        await moodService.initialize();
        
        // Тест с экстремальными данными
        final extremeEntry = MoodEntry(
          id: 'extreme',
          mood: MoodType.happy,
          timestamp: DateTime.fromMillisecondsSinceEpoch(0), // Минимальная дата
          activities: List.filled(1000, 'test'), // Много активностей
          note: 'x' * 10000, // Очень длинная заметка
          sleepDuration: const Duration(minutes: -60), // Невалидное значение
        );
        
        // Должно обработать ошибки gracefully
        await moodService.addMoodEntry(extremeEntry);
        
        // Сервис должен продолжать работать
        expect(moodService.entries, isNotNull);
      });

      test('should handle concurrent operations', () async {
        await moodService.initialize();
        
        // Одновременные операции
        final futures = <Future>[];
        for (int i = 0; i < 10; i++) {
          futures.add(moodService.addMoodEntry(MoodEntry(
            id: 'concurrent-$i',
            mood: MoodType.values[i % MoodType.values.length],
            timestamp: DateTime.now().add(Duration(minutes: i)),
            activities: ['activity-$i'],
          )));
        }
        
        await Future.wait(futures);
        
        // Все записи должны быть добавлены
        expect(moodService.entries.length, equals(10));
      });
    });

    group('Performance', () {
      test('should handle large number of entries efficiently', () async {
        await moodService.initialize();
        
        final stopwatch = Stopwatch()..start();
        
        // Добавляем 100 записей
        for (int i = 0; i < 100; i++) {
          await moodService.addMoodEntry(MoodEntry(
            id: 'perf-$i',
            mood: MoodType.values[i % MoodType.values.length],
            timestamp: DateTime.now().subtract(Duration(minutes: i)),
            activities: ['activity-${i % 5}'],
          ));
        }
        
        stopwatch.stop();
        
        // Должно завершиться за разумное время (< 10 секунд)
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
        expect(moodService.entries.length, equals(100));
      });
    });
  });
}