import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:objectbox/objectbox.dart';
import 'package:mood_tracker_plus/services/database_service.dart';
import 'package:mood_tracker_plus/models/mood_entry.dart';
import 'package:mood_tracker_plus/models/objectbox/mood_entry_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('DatabaseService', () {
    late DatabaseService databaseService;
    late Directory tempDir;

    setUpAll(() async {
      // Создаем временную директорию для тестовой базы данных
      tempDir = await Directory.systemTemp.createTemp('objectbox_test_');
      
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
      
      // Инициализируем ObjectBox с тестовой директорией
      // Initialize fresh store for tests
      await DatabaseService.initialize();
      databaseService = DatabaseService.instance;
    });

    tearDownAll(() async {
      // Закрываем базу данных и удаляем временные файлы
      databaseService.dispose();
      
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
      // Очищаем данные перед каждым тестом
      await databaseService.clearAllData();
    });

    group('Initialization', () {
      test('should initialize without errors', () {
        expect(databaseService.store, isNotNull);
        expect(databaseService.moodBox, isNotNull);
      });

      test('should handle reinitialization correctly', () async {
        // Проверяем, что сервис может быть переинициализирован
        databaseService.dispose();
        await DatabaseService.initialize();
        databaseService = DatabaseService.instance;
        expect(databaseService.store, isNotNull);
      });
    });

    group('CRUD Operations', () {
      late MoodEntry testEntry;

      setUp(() {
        testEntry = MoodEntry(
          id: 'test-entry-1',
          mood: MoodType.happy,
          timestamp: DateTime.now(),
          activities: ['reading', 'walking'],
          note: 'Test note',
          sleepDuration: const Duration(hours: 8),
        );
      });

      test('should save mood entry successfully', () async {
        await databaseService.saveMoodEntry(testEntry);
        
        final count = await databaseService.getMoodEntryCount();
        expect(count, equals(1));
      });

      test('should retrieve mood entry by ID', () async {
        await databaseService.saveMoodEntry(testEntry);
        
        final retrieved = await databaseService.getMoodEntryById(testEntry.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(testEntry.id));
        expect(retrieved.mood, equals(testEntry.mood));
        expect(retrieved.note, equals(testEntry.note));
        expect(retrieved.activities, containsAll(testEntry.activities));
      });

      test('should return null for non-existent entry ID', () async {
        final retrieved = await databaseService.getMoodEntryById('non-existent');
        expect(retrieved, isNull);
      });

      test('should get all mood entries', () async {
        final entry1 = testEntry;
        final entry2 = testEntry.copyWith(
          id: 'test-entry-2',
          mood: MoodType.sad,
          note: 'Another test note',
        );

        await databaseService.saveMoodEntry(entry1);
        await databaseService.saveMoodEntry(entry2);

        final allEntries = await databaseService.getAllMoodEntries();
        expect(allEntries.length, equals(2));
        expect(allEntries.map((e) => e.id), containsAll([entry1.id, entry2.id]));
      });

      test('should update existing mood entry', () async {
        await databaseService.saveMoodEntry(testEntry);
        
        final updatedEntry = testEntry.copyWith(
          mood: MoodType.verySad,
          note: 'Updated note',
          activities: ['sleeping'],
        );
        
        await databaseService.updateMoodEntry(updatedEntry);
        
        final retrieved = await databaseService.getMoodEntryById(testEntry.id);
        expect(retrieved!.mood, equals(MoodType.verySad));
        expect(retrieved.note, equals('Updated note'));
        expect(retrieved.activities, equals(['sleeping']));
      });

      test('should delete mood entry successfully', () async {
        await databaseService.saveMoodEntry(testEntry);
        expect(await databaseService.getMoodEntryCount(), equals(1));
        
        await databaseService.deleteMoodEntry(testEntry.id);
        expect(await databaseService.getMoodEntryCount(), equals(0));
        
        final retrieved = await databaseService.getMoodEntryById(testEntry.id);
        expect(retrieved, isNull);
      });

      test('should handle deletion of non-existent entry gracefully', () async {
        await databaseService.deleteMoodEntry('non-existent');
        expect(await databaseService.getMoodEntryCount(), equals(0));
      });
    });

    group('Date Range Queries', () {
      late List<MoodEntry> testEntries;

      setUp(() async {
        final now = DateTime.now();
        testEntries = [
          MoodEntry(
            id: 'entry-1',
            mood: MoodType.happy,
            timestamp: now.subtract(const Duration(days: 3)),
            activities: ['reading'],
          ),
          MoodEntry(
            id: 'entry-2',
            mood: MoodType.neutral,
            timestamp: now.subtract(const Duration(days: 1)),
            activities: ['walking'],
          ),
          MoodEntry(
            id: 'entry-3',
            mood: MoodType.sad,
            timestamp: now,
            activities: ['sleeping'],
          ),
        ];

        for (final entry in testEntries) {
          await databaseService.saveMoodEntry(entry);
        }
      });

      test('should get entries within date range', () async {
        final start = DateTime.now().subtract(const Duration(days: 2));
        final end = DateTime.now().add(const Duration(hours: 1));
        
        final entries = await databaseService.getMoodEntriesByDateRange(start, end);
        expect(entries.length, equals(2));
        expect(entries.map((e) => e.id), containsAll(['entry-2', 'entry-3']));
      });

      test('should return empty list for date range with no entries', () async {
        final start = DateTime.now().subtract(const Duration(days: 10));
        final end = DateTime.now().subtract(const Duration(days: 5));
        
        final entries = await databaseService.getMoodEntriesByDateRange(start, end);
        expect(entries, isEmpty);
      });

      test('should get recent entries with limit', () async {
        final recentEntries = await databaseService.getRecentMoodEntries(2);
        expect(recentEntries.length, equals(2));
        
        // Должны быть отсортированы по времени (новые первыми)
        expect(recentEntries.first.id, equals('entry-3'));
        expect(recentEntries.last.id, equals('entry-2'));
      });
    });

    group('Statistics and Analytics', () {
      setUp(() async {
        final now = DateTime.now();
        final entries = [
          MoodEntry(
            id: 'happy-1',
            mood: MoodType.happy,
            timestamp: now.subtract(const Duration(hours: 1)),
            activities: ['reading'],
          ),
          MoodEntry(
            id: 'happy-2',
            mood: MoodType.veryHappy,
            timestamp: now.subtract(const Duration(hours: 2)),
            activities: ['exercise'],
          ),
          MoodEntry(
            id: 'sad-1',
            mood: MoodType.sad,
            timestamp: now.subtract(const Duration(hours: 3)),
            activities: ['work'],
          ),
        ];

        for (final entry in entries) {
          await databaseService.saveMoodEntry(entry);
        }
      });

      test('should calculate average mood for period', () async {
        final start = DateTime.now().subtract(const Duration(hours: 4));
        final end = DateTime.now();
        
        final average = await databaseService.getAverageMoodForPeriod(start, end);
        
        // (4 + 5 + 2) / 3 = 3.67
        expect(average, closeTo(3.67, 0.01));
      });

      test('should return 0 for average when no entries in period', () async {
        final start = DateTime.now().subtract(const Duration(days: 10));
        final end = DateTime.now().subtract(const Duration(days: 5));
        
        final average = await databaseService.getAverageMoodForPeriod(start, end);
        expect(average, equals(0.0));
      });

      test('should calculate mood distribution', () async {
        final distribution = await databaseService.getMoodDistribution();
        
        expect(distribution[MoodType.veryHappy], equals(1));
        expect(distribution[MoodType.happy], equals(1));
        expect(distribution[MoodType.neutral], equals(0));
        expect(distribution[MoodType.sad], equals(1));
        expect(distribution[MoodType.verySad], equals(0));
      });

      test('should return zero distribution for empty database', () async {
        await databaseService.clearAllData();
        
        final distribution = await databaseService.getMoodDistribution();
        
        for (final mood in MoodType.values) {
          expect(distribution[mood], equals(0));
        }
      });
    });

    group('Data Persistence', () {
      test('should persist data across service instances', () async {
        final testEntry = MoodEntry(
          id: 'persist-test',
          mood: MoodType.neutral,
          timestamp: DateTime.now(),
          activities: ['testing'],
          note: 'Persistence test',
        );

        await databaseService.saveMoodEntry(testEntry);
        
        // Создаем новый экземпляр сервиса
        final newService = DatabaseService.instance;
        
        final retrieved = await newService.getMoodEntryById('persist-test');
        expect(retrieved, isNotNull);
        expect(retrieved!.note, equals('Persistence test'));
      });
    });

    group('Error Handling', () {
      test('should handle malformed data gracefully', () async {
        // Тест с пустыми активностями
        final entryWithEmptyActivities = MoodEntry(
          id: 'empty-activities',
          mood: MoodType.happy,
          timestamp: DateTime.now(),
          activities: [],
        );

        await databaseService.saveMoodEntry(entryWithEmptyActivities);
        final retrieved = await databaseService.getMoodEntryById('empty-activities');
        
        expect(retrieved, isNotNull);
        expect(retrieved!.activities, isEmpty);
      });

      test('should handle null values correctly', () async {
        final entryWithNulls = MoodEntry(
          id: 'null-test',
          mood: MoodType.neutral,
          timestamp: DateTime.now(),
          activities: ['test'],
          note: null,
          sleepDuration: null,
        );

        await databaseService.saveMoodEntry(entryWithNulls);
        final retrieved = await databaseService.getMoodEntryById('null-test');
        
        expect(retrieved, isNotNull);
        expect(retrieved!.note, isNull);
        expect(retrieved.sleepDuration, isNull);
      });
    });

    group('Performance', () {
      test('should handle large number of entries efficiently', () async {
        final stopwatch = Stopwatch()..start();
        
        // Создаем 1000 записей
        for (int i = 0; i < 1000; i++) {
          final entry = MoodEntry(
            id: 'perf-test-$i',
            mood: MoodType.values[i % MoodType.values.length],
            timestamp: DateTime.now().subtract(Duration(minutes: i)),
            activities: ['activity-$i'],
          );
          await databaseService.saveMoodEntry(entry);
        }
        
        stopwatch.stop();
        
        // Операция должна завершиться за разумное время (< 5 секунд)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
        
        // Проверяем что все данные сохранились
        final count = await databaseService.getMoodEntryCount();
        expect(count, equals(1000));
        
        // Проверяем скорость получения данных
        final queryStopwatch = Stopwatch()..start();
        final allEntries = await databaseService.getAllMoodEntries();
        queryStopwatch.stop();
        
        expect(allEntries.length, equals(1000));
        expect(queryStopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}