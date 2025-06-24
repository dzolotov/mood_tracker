import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker_plus/data/objectbox/models/mood_entry_box.dart';
import 'package:mood_tracker_plus/models/mood_entry.dart';

void main() {
  group('MoodEntryBox Tests', () {
    test('should convert from MoodEntry correctly', () {
      final now = DateTime.now();
      final moodEntry = MoodEntry(
        id: 'test-123',
        mood: MoodType.happy,
        timestamp: now,
        note: 'Test note',
        activities: ['Running', 'Reading', 'Coding'],
        sleepDuration: const Duration(hours: 7, minutes: 30),
        sleepTime: now.subtract(const Duration(hours: 8)),
        wakeTime: now.subtract(const Duration(minutes: 30)),
        photoPath: '/path/to/photo.jpg',
      );

      final box = MoodEntryBox.fromMoodEntry(moodEntry);

      expect(box.entryId, equals('test-123'));
      expect(box.moodValue, equals(4)); // happy = 4
      expect(box.timestamp, equals(now));
      expect(box.note, equals('Test note'));
      expect(box.activities, equals('Running,Reading,Coding'));
      expect(box.sleepDurationMinutes, equals(450)); // 7.5 hours
      expect(box.sleepTime, equals(now.subtract(const Duration(hours: 8))));
      expect(box.wakeTime, equals(now.subtract(const Duration(minutes: 30))));
      expect(box.photoPath, equals('/path/to/photo.jpg'));
    });

    test('should convert to MoodEntry correctly', () {
      final now = DateTime.now();
      final box = MoodEntryBox(
        entryId: 'test-456',
        moodValue: 2, // sad
        timestamp: now,
        note: 'Another test',
        activities: 'Walking,Meditation',
        sleepDurationMinutes: 480, // 8 hours
        sleepTime: now.subtract(const Duration(hours: 9)),
        wakeTime: now.subtract(const Duration(hours: 1)),
        photoPath: '/another/photo.png',
      );

      final moodEntry = box.toMoodEntry();

      expect(moodEntry.id, equals('test-456'));
      expect(moodEntry.mood, equals(MoodType.sad));
      expect(moodEntry.timestamp, equals(now));
      expect(moodEntry.note, equals('Another test'));
      expect(moodEntry.activities, equals(['Walking', 'Meditation']));
      expect(moodEntry.sleepDuration, equals(const Duration(minutes: 480)));
      expect(moodEntry.sleepTime, equals(now.subtract(const Duration(hours: 9))));
      expect(moodEntry.wakeTime, equals(now.subtract(const Duration(hours: 1))));
      expect(moodEntry.photoPath, equals('/another/photo.png'));
    });

    test('should handle null values correctly', () {
      final now = DateTime.now();
      final moodEntry = MoodEntry(
        id: 'test-789',
        mood: MoodType.neutral,
        timestamp: now,
        activities: [],
      );

      final box = MoodEntryBox.fromMoodEntry(moodEntry);

      expect(box.note, isNull);
      expect(box.activities, equals(''));
      expect(box.sleepDurationMinutes, isNull);
      expect(box.sleepTime, isNull);
      expect(box.wakeTime, isNull);
      expect(box.photoPath, isNull);

      final converted = box.toMoodEntry();

      expect(converted.note, isNull);
      expect(converted.activities, isEmpty);
      expect(converted.sleepDuration, isNull);
      expect(converted.sleepTime, isNull);
      expect(converted.wakeTime, isNull);
      expect(converted.photoPath, isNull);
    });

    test('should handle all mood types correctly', () {
      final now = DateTime.now();
      
      for (final mood in MoodType.values) {
        final moodEntry = MoodEntry(
          id: 'test-${mood.value}',
          mood: mood,
          timestamp: now,
          activities: [],
        );

        final box = MoodEntryBox.fromMoodEntry(moodEntry);
        expect(box.moodValue, equals(mood.value));

        final converted = box.toMoodEntry();
        expect(converted.mood, equals(mood));
      }
    });

    test('should preserve activity order', () {
      final activities = ['First', 'Second', 'Third', 'Fourth'];
      final moodEntry = MoodEntry(
        id: 'test-order',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
        activities: activities,
      );

      final box = MoodEntryBox.fromMoodEntry(moodEntry);
      final converted = box.toMoodEntry();

      expect(converted.activities, equals(activities));
    });

    test('should handle empty activities list', () {
      final moodEntry = MoodEntry(
        id: 'test-empty',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
        activities: [],
      );

      final box = MoodEntryBox.fromMoodEntry(moodEntry);
      expect(box.activities, equals(''));

      final converted = box.toMoodEntry();
      expect(converted.activities, isEmpty);
    });

    test('should handle single activity', () {
      final moodEntry = MoodEntry(
        id: 'test-single',
        mood: MoodType.happy,
        timestamp: DateTime.now(),
        activities: ['OnlyOne'],
      );

      final box = MoodEntryBox.fromMoodEntry(moodEntry);
      expect(box.activities, equals('OnlyOne'));

      final converted = box.toMoodEntry();
      expect(converted.activities, equals(['OnlyOne']));
    });

    test('should maintain timestamp precision', () {
      final timestamp = DateTime(2024, 1, 15, 14, 30, 45, 123);
      final moodEntry = MoodEntry(
        id: 'test-timestamp',
        mood: MoodType.happy,
        timestamp: timestamp,
        activities: [],
      );

      final box = MoodEntryBox.fromMoodEntry(moodEntry);
      expect(box.timestamp, equals(timestamp));

      final converted = box.toMoodEntry();
      expect(converted.timestamp, equals(timestamp));
    });
  });
}