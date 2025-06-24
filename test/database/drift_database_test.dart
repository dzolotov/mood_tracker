import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:mood_tracker_plus/database/drift_database.dart';
import 'package:mood_tracker_plus/models/mood_entry.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('Drift Database Tests', () {
    test('should add and retrieve mood entry', () async {
      final entryId = await database.addMoodEntry(
        moodValue: 4,
        note: 'Test mood entry',
        timestamp: DateTime.now(),
        photoPath: '/test/photo.jpg',
      );

      expect(entryId, greaterThan(0));

      final entries = await database.getRecentMoodEntries(1);
      expect(entries, hasLength(1));
      expect(entries.first.moodValue, equals(4));
      expect(entries.first.note, equals('Test mood entry'));
      expect(entries.first.photoPath, equals('/test/photo.jpg'));
    });

    test('should get mood entries by date range', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));
      final lastWeek = now.subtract(const Duration(days: 7));

      // Add entries at different times
      await database.addMoodEntry(
        moodValue: 5,
        timestamp: yesterday,
      );
      await database.addMoodEntry(
        moodValue: 3,
        timestamp: now,
      );
      await database.addMoodEntry(
        moodValue: 1,
        timestamp: lastWeek,
      );

      final entries = await database.getMoodEntriesByDateRange(
        yesterday.subtract(const Duration(hours: 1)),
        tomorrow,
      );

      expect(entries, hasLength(2));
      expect(entries.any((e) => e.moodValue == 1), isFalse);
    });

    test('should add and retrieve activities', () async {
      // Get initial activity count
      final initialActivities = await database.getAllActivities();
      final initialCount = initialActivities.length;
      
      await database.addActivity('Exercise', '#FF5722');
      await database.addActivity('Reading', '#2196F3');
      await database.addActivity('Work', '#4CAF50');

      final activities = await database.getAllActivities();

      expect(activities, hasLength(initialCount + 3));
      expect(activities.any((a) => a.name == 'Exercise'), isTrue);
      expect(activities.any((a) => a.color == '#2196F3'), isTrue);
    });

    test('should link activities to mood entries', () async {
      // Create activity
      final activityId = await database.addActivity('Meditation', '#9C27B0');

      // Create mood entry
      final entryId = await database.addMoodEntry(
        moodValue: 5,
        timestamp: DateTime.now(),
      );

      // Link them
      await database.linkActivityToEntry(entryId, activityId);

      // Verify link exists
      final activities = await database.getActivitiesForEntry(entryId);
      expect(activities, hasLength(1));
      expect(activities.first.name, equals('Meditation'));
    });

    test('should update statistics', () async {
      final date = DateTime.now();

      await database.updateStatistics(
        date: date,
        averageMood: 3.5,
        entryCount: 10,
        totalSleepMinutes: 480,
      );

      final stats = await database.getStatisticsForDate(date);

      expect(stats, isNotNull);
      expect(stats!.averageMood, equals(3.5));
      expect(stats.entryCount, equals(10));
      expect(stats.totalSleepMinutes, equals(480));
    });

    test('should calculate mood trends by weekday', () async {
      final now = DateTime.now();

      // Add entries for different weekdays
      for (int i = 0; i < 14; i++) {
        final date = now.subtract(Duration(days: i));
        await database.addMoodEntry(
          moodValue: (i % 5) + 1, // Mood values 1-5
          timestamp: date,
        );
      }

      final trends = await database.getMoodEntriesByWeekday();

      expect(trends, isNotEmpty);
      expect(trends.keys.length, lessThanOrEqualTo(7));
      trends.values.forEach((avgMood) {
        expect(avgMood, greaterThanOrEqualTo(1.0));
        expect(avgMood, lessThanOrEqualTo(5.0));
      });
    });

    test('should handle complex analytics queries', () async {
      // Add various entries with activities
      final activities = ['Work', 'Exercise', 'Family', 'Friends'];
      final activityIds = <int>[];

      for (final activity in activities) {
        final id = await database.addActivity(activity, '#000000');
        activityIds.add(id);
      }

      // Create entries with different moods and activities
      for (int i = 0; i < 20; i++) {
        final entryId = await database.addMoodEntry(
          moodValue: (i % 5) + 1,
          timestamp: DateTime.now().subtract(Duration(days: i)),
          note: 'Entry $i',
        );

        // Link random activities
        if (i % 2 == 0) {
          await database.linkActivityToEntry(entryId, activityIds[i % 4]);
        }
      }

      // Test various queries
      final recentEntries = await database.getRecentMoodEntries(5);
      expect(recentEntries, hasLength(5));

      final happyEntries = await database.getMoodEntriesByMood(5);
      expect(happyEntries.every((e) => e.moodValue == 5), isTrue);

      final weeklyTrends = await database.getMoodEntriesByWeekday();
      expect(weeklyTrends, isNotEmpty);
    });

    test('should handle transactions correctly', () async {
      // Test atomic transaction
      await database.transaction(() async {
        await database.addMoodEntry(moodValue: 5, timestamp: DateTime.now());
        await database.addMoodEntry(moodValue: 4, timestamp: DateTime.now());
        await database.addMoodEntry(moodValue: 3, timestamp: DateTime.now());
      });

      final entries = await database.getRecentMoodEntries(10);
      expect(entries, hasLength(3));
    });

    test('should handle null values correctly', () async {
      final entryId = await database.addMoodEntry(
        moodValue: 3,
        note: null,
        timestamp: DateTime.now(),
        photoPath: null,
      );

      final entries = await database.getRecentMoodEntries(1);
      expect(entries, hasLength(1));
      expect(entries.first.note, isNull);
      expect(entries.first.photoPath, isNull);
    });

    test('should delete old entries', () async {
      final now = DateTime.now();
      final oldDate = now.subtract(const Duration(days: 100));

      // Add old and new entries
      await database.addMoodEntry(moodValue: 1, timestamp: oldDate);
      await database.addMoodEntry(moodValue: 2, timestamp: oldDate);
      await database.addMoodEntry(moodValue: 3, timestamp: now);
      await database.addMoodEntry(moodValue: 4, timestamp: now);

      // Delete entries older than 90 days
      await database.deleteEntriesOlderThan(const Duration(days: 90));

      final remainingEntries = await database.getRecentMoodEntries(10);
      expect(remainingEntries, hasLength(2));
      expect(remainingEntries.every((e) => e.moodValue >= 3), isTrue);
    });

    test('should perform complex aggregations', () async {
      // Add entries with sleep data
      for (int i = 0; i < 7; i++) {
        await database.addMoodEntry(
          moodValue: (i % 5) + 1,
          timestamp: DateTime.now().subtract(Duration(days: i)),
          note: 'Day $i',
        );

        await database.updateStatistics(
          date: DateTime.now().subtract(Duration(days: i)),
          averageMood: ((i % 5) + 1).toDouble(),
          entryCount: 1,
          totalSleepMinutes: 420 + (i * 10), // 7-8 hours
        );
      }

      // Get weekly statistics
      final weeklyStats = await database.getWeeklyStatistics();
      expect(weeklyStats, isNotEmpty);

      // Verify aggregated data
      final totalSleep = weeklyStats.fold<num>(
        0,
        (sum, stat) => sum + (stat['total_sleep'] ?? 0),
      );
      expect(totalSleep, greaterThan(0));
    });
  });

  group('Raw SQL Query Tests', () {
    test('should execute raw queries safely', () async {
      // Add test data
      await database.addMoodEntry(
        moodValue: 5,
        timestamp: DateTime.now(),
        note: 'Happy day',
      );

      // Execute raw query (using Drift's customSelect)
      final result = await database.customSelect(
        'SELECT COUNT(*) as count FROM mood_entries WHERE mood_value = ?',
        variables: [const Variable(5)],
      ).get();

      expect(result, isNotEmpty);
      expect(result.first.data['count'], equals(1));
    });

    test('should handle SQL injection attempts', () async {
      // Try to inject SQL (Drift should handle this safely)
      final maliciousNote = "'; DROP TABLE mood_entries; --";
      
      final entryId = await database.addMoodEntry(
        moodValue: 3,
        note: maliciousNote,
        timestamp: DateTime.now(),
      );

      // Table should still exist and contain the entry
      final entries = await database.getRecentMoodEntries(1);
      expect(entries, hasLength(1));
      expect(entries.first.note, equals(maliciousNote));
    });
  });

  group('Performance Tests', () {
    test('should handle bulk inserts efficiently', () async {
      final stopwatch = Stopwatch()..start();

      // Insert 100 entries (reduced for test stability)
      await database.transaction(() async {
        for (int i = 0; i < 100; i++) {
          await database.addMoodEntry(
            moodValue: (i % 5) + 1,
            timestamp: DateTime.now().subtract(Duration(hours: i)),
            note: 'Bulk entry $i',
          );
          // Small delay to ensure unique IDs
          await Future.delayed(Duration(microseconds: 10));
        }
      });

      stopwatch.stop();

      // Should complete in reasonable time (less than 5 seconds)
      expect(stopwatch.elapsed.inSeconds, lessThan(5));

      // Verify all entries were inserted
      final count = await database.customSelect(
        'SELECT COUNT(*) as count FROM mood_entries',
      ).get();
      expect(count.first.data['count'], equals(100));
    });

    test('should query large datasets efficiently', () async {
      // Add many entries
      for (int i = 0; i < 50; i++) {
        await database.addMoodEntry(
          moodValue: (i % 5) + 1,
          timestamp: DateTime.now().subtract(Duration(hours: i)),
        );
        // Small delay to ensure unique IDs
        await Future.delayed(Duration(microseconds: 10));
      }

      final stopwatch = Stopwatch()..start();

      // Perform complex query
      final trends = await database.getMoodEntriesByWeekday();
      final recentEntries = await database.getRecentMoodEntries(100);
      final stats = await database.getWeeklyStatistics();

      stopwatch.stop();

      // Queries should be fast
      expect(stopwatch.elapsed.inMilliseconds, lessThan(500));
      expect(trends, isNotEmpty);
      expect(recentEntries.length, lessThanOrEqualTo(100));
    });
  });
}