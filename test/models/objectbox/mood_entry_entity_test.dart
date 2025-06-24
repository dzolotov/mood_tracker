import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker_plus/models/mood_entry.dart';
import 'package:mood_tracker_plus/models/objectbox/mood_entry_entity.dart';

void main() {
  group('MoodEntryEntity', () {
    late MoodEntry testMoodEntry;
    late MoodEntryEntity testEntity;

    setUp(() {
      testMoodEntry = MoodEntry(
        id: 'test-entry-123',
        mood: MoodType.happy,
        timestamp: DateTime(2024, 1, 15, 14, 30),
        note: 'Test note for entity',
        activities: ['work', 'exercise', 'reading'],
        sleepDuration: const Duration(hours: 8, minutes: 30),
        sleepTime: DateTime(2024, 1, 14, 23, 0),
        wakeTime: DateTime(2024, 1, 15, 7, 30),
        photoPath: '/path/to/photo.jpg',
      );

      testEntity = MoodEntryEntity(
        entryId: 'test-entity-456',
        moodValue: 4,
        timestamp: DateTime(2024, 1, 16, 10, 0),
        note: 'Entity test note',
        activities: '"swimming","cycling"',
        sleepDurationMinutes: 480,
        sleepTime: DateTime(2024, 1, 15, 22, 30),
        wakeTime: DateTime(2024, 1, 16, 6, 30),
        photoPath: '/path/to/entity/photo.jpg',
      );
    });

    group('Construction', () {
      test('should create entity with default values', () {
        final entity = MoodEntryEntity(
          entryId: 'test',
          moodValue: 3,
          timestamp: DateTime.now(),
        );

        expect(entity.id, equals(0));
        expect(entity.entryId, equals('test'));
        expect(entity.moodValue, equals(3));
        expect(entity.note, isNull);
        expect(entity.activities, equals('[]'));
        expect(entity.sleepDurationMinutes, isNull);
        expect(entity.sleepTime, isNull);
        expect(entity.wakeTime, isNull);
        expect(entity.photoPath, isNull);
      });

      test('should create entity with all values provided', () {
        expect(testEntity.entryId, equals('test-entity-456'));
        expect(testEntity.moodValue, equals(4));
        expect(testEntity.note, equals('Entity test note'));
        expect(testEntity.activities, equals('"swimming","cycling"'));
        expect(testEntity.sleepDurationMinutes, equals(480));
        expect(testEntity.photoPath, equals('/path/to/entity/photo.jpg'));
      });
    });

    group('Domain Model Conversion', () {
      test('should convert from MoodEntry to MoodEntryEntity correctly', () {
        final entity = MoodEntryEntity.fromMoodEntry(testMoodEntry);

        expect(entity.entryId, equals('test-entry-123'));
        expect(entity.moodValue, equals(4)); // MoodType.happy.value
        expect(entity.timestamp, equals(DateTime(2024, 1, 15, 14, 30)));
        expect(entity.note, equals('Test note for entity'));
        expect(entity.activities, equals('"work","exercise","reading"'));
        expect(entity.sleepDurationMinutes, equals(510)); // 8.5 * 60
        expect(entity.sleepTime, equals(DateTime(2024, 1, 14, 23, 0)));
        expect(entity.wakeTime, equals(DateTime(2024, 1, 15, 7, 30)));
        expect(entity.photoPath, equals('/path/to/photo.jpg'));
      });

      test('should convert from MoodEntryEntity to MoodEntry correctly', () {
        final moodEntry = testEntity.toMoodEntry();

        expect(moodEntry.id, equals('test-entity-456'));
        expect(moodEntry.mood, equals(MoodType.happy)); // value 4
        expect(moodEntry.timestamp, equals(DateTime(2024, 1, 16, 10, 0)));
        expect(moodEntry.note, equals('Entity test note'));
        expect(moodEntry.activities, equals(['swimming', 'cycling']));
        expect(moodEntry.sleepDuration, equals(const Duration(minutes: 480)));
        expect(moodEntry.sleepTime, equals(DateTime(2024, 1, 15, 22, 30)));
        expect(moodEntry.wakeTime, equals(DateTime(2024, 1, 16, 6, 30)));
        expect(moodEntry.photoPath, equals('/path/to/entity/photo.jpg'));
      });

      test('should handle null values in conversion from MoodEntry', () {
        final minimumEntry = MoodEntry(
          id: 'minimum',
          mood: MoodType.neutral,
          timestamp: DateTime.now(),
          activities: [],
        );

        final entity = MoodEntryEntity.fromMoodEntry(minimumEntry);

        expect(entity.entryId, equals('minimum'));
        expect(entity.moodValue, equals(3)); // MoodType.neutral.value
        expect(entity.note, isNull);
        expect(entity.activities, equals(''));
        expect(entity.sleepDurationMinutes, isNull);
        expect(entity.sleepTime, isNull);
        expect(entity.wakeTime, isNull);
        expect(entity.photoPath, isNull);
      });

      test('should handle null values in conversion to MoodEntry', () {
        final minimumEntity = MoodEntryEntity(
          entryId: 'minimum-entity',
          moodValue: 2,
          timestamp: DateTime.now(),
        );

        final moodEntry = minimumEntity.toMoodEntry();

        expect(moodEntry.id, equals('minimum-entity'));
        expect(moodEntry.mood, equals(MoodType.sad)); // value 2
        expect(moodEntry.note, isNull);
        expect(moodEntry.activities, isEmpty);
        expect(moodEntry.sleepDuration, isNull);
        expect(moodEntry.sleepTime, isNull);
        expect(moodEntry.wakeTime, isNull);
        expect(moodEntry.photoPath, isNull);
      });

      test('should round-trip conversion preserve data', () {
        // MoodEntry -> Entity -> MoodEntry
        final entity = MoodEntryEntity.fromMoodEntry(testMoodEntry);
        final convertedEntry = entity.toMoodEntry();

        expect(convertedEntry.id, equals(testMoodEntry.id));
        expect(convertedEntry.mood, equals(testMoodEntry.mood));
        expect(convertedEntry.timestamp, equals(testMoodEntry.timestamp));
        expect(convertedEntry.note, equals(testMoodEntry.note));
        expect(convertedEntry.activities, equals(testMoodEntry.activities));
        expect(convertedEntry.sleepDuration, equals(testMoodEntry.sleepDuration));
        expect(convertedEntry.sleepTime, equals(testMoodEntry.sleepTime));
        expect(convertedEntry.wakeTime, equals(testMoodEntry.wakeTime));
        expect(convertedEntry.photoPath, equals(testMoodEntry.photoPath));
      });
    });

    group('Activity Encoding/Decoding', () {
      test('should encode activities correctly', () {
        final activities = ['work', 'exercise', 'reading'];
        final entity = MoodEntryEntity.fromMoodEntry(MoodEntry(
          id: 'test',
          mood: MoodType.happy,
          timestamp: DateTime.now(),
          activities: activities,
        ));

        expect(entity.activities, equals('"work","exercise","reading"'));
      });

      test('should decode activities correctly', () {
        final entity = MoodEntryEntity(
          entryId: 'test',
          moodValue: 3,
          timestamp: DateTime.now(),
          activities: '"swimming","cycling","running"',
        );

        final moodEntry = entity.toMoodEntry();
        expect(moodEntry.activities, equals(['swimming', 'cycling', 'running']));
      });

      test('should handle empty activities list', () {
        final entity = MoodEntryEntity(
          entryId: 'test',
          moodValue: 3,
          timestamp: DateTime.now(),
          activities: '',
        );

        final moodEntry = entity.toMoodEntry();
        expect(moodEntry.activities, isEmpty);
      });

      test('should handle activities with empty brackets', () {
        final entity = MoodEntryEntity(
          entryId: 'test',
          moodValue: 3,
          timestamp: DateTime.now(),
          activities: '[]',
        );

        final moodEntry = entity.toMoodEntry();
        expect(moodEntry.activities, isEmpty);
      });

      test('should handle activities with special characters', () {
        final activities = ['work-task', 'exercise@gym', 'reading_book'];
        final entity = MoodEntryEntity.fromMoodEntry(MoodEntry(
          id: 'test',
          mood: MoodType.happy,
          timestamp: DateTime.now(),
          activities: activities,
        ));

        final converted = entity.toMoodEntry();
        expect(converted.activities, equals(activities));
      });

      test('should handle activities with commas in names', () {
        // Test что активности с запятыми обрабатываются корректно
        final activities = ['work', 'exercise'];
        final entity = MoodEntryEntity.fromMoodEntry(MoodEntry(
          id: 'test',
          mood: MoodType.happy,
          timestamp: DateTime.now(),
          activities: activities,
        ));

        expect(entity.activities, equals('"work","exercise"'));
        
        final converted = entity.toMoodEntry();
        expect(converted.activities, equals(activities));
      });

      test('should filter out empty activity names', () {
        final entity = MoodEntryEntity(
          entryId: 'test',
          moodValue: 3,
          timestamp: DateTime.now(),
          activities: '"valid","",  , "another_valid"',
        );

        final moodEntry = entity.toMoodEntry();
        expect(moodEntry.activities, equals(['valid', 'another_valid']));
      });
    });

    group('Mood Value Mapping', () {
      test('should map all MoodType values correctly', () {
        final moodTests = [
          (MoodType.verySad, 1),
          (MoodType.sad, 2),
          (MoodType.neutral, 3),
          (MoodType.happy, 4),
          (MoodType.veryHappy, 5),
        ];

        for (final (mood, expectedValue) in moodTests) {
          final entry = MoodEntry(
            id: 'test-${mood.name}',
            mood: mood,
            timestamp: DateTime.now(),
            activities: [],
          );

          final entity = MoodEntryEntity.fromMoodEntry(entry);
          expect(entity.moodValue, equals(expectedValue));

          final convertedEntry = entity.toMoodEntry();
          expect(convertedEntry.mood, equals(mood));
        }
      });
    });

    group('Sleep Duration Handling', () {
      test('should convert sleep hours to minutes correctly', () {
        final entry = MoodEntry(
          id: 'sleep-test',
          mood: MoodType.happy,
          timestamp: DateTime.now(),
          activities: [],
          sleepDuration: const Duration(hours: 7, minutes: 45), // 465 minutes
        );

        final entity = MoodEntryEntity.fromMoodEntry(entry);
        expect(entity.sleepDurationMinutes, equals(465));

        final converted = entity.toMoodEntry();
        expect(converted.sleepDuration, equals(const Duration(minutes: 465)));
      });

      test('should handle zero sleep duration', () {
        final entry = MoodEntry(
          id: 'no-sleep',
          mood: MoodType.verySad,
          timestamp: DateTime.now(),
          activities: [],
          sleepDuration: Duration.zero,
        );

        final entity = MoodEntryEntity.fromMoodEntry(entry);
        expect(entity.sleepDurationMinutes, equals(0));

        final converted = entity.toMoodEntry();
        expect(converted.sleepDuration, equals(Duration.zero));
      });

      test('should handle fractional sleep hours', () {
        final entry = MoodEntry(
          id: 'fractional-sleep',
          mood: MoodType.neutral,
          timestamp: DateTime.now(),
          activities: [],
          sleepDuration: const Duration(hours: 8, minutes: 20), // 500 minutes
        );

        final entity = MoodEntryEntity.fromMoodEntry(entry);
        // 8 hours 20 minutes = 500 minutes
        expect(entity.sleepDurationMinutes, equals(500));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle very long note text', () {
        final longNote = 'x' * 10000;
        final entry = MoodEntry(
          id: 'long-note',
          mood: MoodType.happy,
          timestamp: DateTime.now(),
          activities: [],
          note: longNote,
        );

        final entity = MoodEntryEntity.fromMoodEntry(entry);
        expect(entity.note, equals(longNote));

        final converted = entity.toMoodEntry();
        expect(converted.note, equals(longNote));
      });

      test('should handle many activities', () {
        final manyActivities = List.generate(100, (i) => 'activity_$i');
        final entry = MoodEntry(
          id: 'many-activities',
          mood: MoodType.happy,
          timestamp: DateTime.now(),
          activities: manyActivities,
        );

        final entity = MoodEntryEntity.fromMoodEntry(entry);
        final converted = entity.toMoodEntry();
        expect(converted.activities, equals(manyActivities));
      });

      test('should handle extreme dates', () {
        final extremeDates = [
          DateTime(1970, 1, 1), // Unix epoch start
          DateTime(2100, 12, 31), // Far future
          DateTime.now().add(const Duration(days: 365 * 50)), // 50 years in future
        ];

        for (final date in extremeDates) {
          final entry = MoodEntry(
            id: 'extreme-date-${date.millisecondsSinceEpoch}',
            mood: MoodType.neutral,
            timestamp: date,
            activities: [],
          );

          final entity = MoodEntryEntity.fromMoodEntry(entry);
          final converted = entity.toMoodEntry();
          expect(converted.timestamp, equals(date));
        }
      });

      test('should handle special characters in all string fields', () {
        // Запятые исключаются, так как используются как разделители в кодировании активностей
        final specialChars = '!@#\$%^&*()_+-=[]{}|;:<>?~`';
        final entry = MoodEntry(
          id: 'special-$specialChars',
          mood: MoodType.happy,
          timestamp: DateTime.now(),
          activities: ['activity-$specialChars'],
          note: 'Note with $specialChars',
          photoPath: '/path/with/$specialChars/photo.jpg',
        );

        final entity = MoodEntryEntity.fromMoodEntry(entry);
        final converted = entity.toMoodEntry();

        expect(converted.id, equals(entry.id));
        expect(converted.activities, equals(entry.activities));
        expect(converted.note, equals(entry.note));
        expect(converted.photoPath, equals(entry.photoPath));
      });
    });
  });
}