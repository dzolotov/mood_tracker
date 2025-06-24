import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker_plus/models/mood_entry.dart';

void main() {
  group('MoodType', () {
    test('should have correct values', () {
      expect(MoodType.veryHappy.value, 5);
      expect(MoodType.happy.value, 4);
      expect(MoodType.neutral.value, 3);
      expect(MoodType.sad.value, 2);
      expect(MoodType.verySad.value, 1);
    });

    test('should have correct emojis', () {
      expect(MoodType.veryHappy.emoji, '😄');
      expect(MoodType.happy.emoji, '🙂');
      expect(MoodType.neutral.emoji, '😐');
      expect(MoodType.sad.emoji, '😕');
      expect(MoodType.verySad.emoji, '😢');
    });

    test('should have correct labels', () {
      expect(MoodType.veryHappy.label, 'Очень счастлив');
      expect(MoodType.happy.label, 'Счастлив');
      expect(MoodType.neutral.label, 'Нейтрально');
      expect(MoodType.sad.label, 'Грустно');
      expect(MoodType.verySad.label, 'Очень грустно');
    });

    test('should have correct colors', () {
      expect(MoodType.veryHappy.color, Colors.green);
      expect(MoodType.happy.color, Colors.lightGreen);
      expect(MoodType.neutral.color, Colors.yellow);
      expect(MoodType.sad.color, Colors.orange);
      expect(MoodType.verySad.color, Colors.red);
    });
  });

  group('MoodEntry', () {
    late DateTime testDate;
    late MoodEntry testEntry;

    setUp(() {
      testDate = DateTime(2024, 1, 1, 12, 0);
      testEntry = MoodEntry(
        id: 'test-id',
        mood: MoodType.happy,
        timestamp: testDate,
        note: 'Test note',
        activities: ['work', 'exercise'],
        sleepDuration: const Duration(hours: 8),
        sleepTime: DateTime(2024, 1, 1, 22, 0),
        wakeTime: DateTime(2024, 1, 2, 6, 0),
      );
    });

    test('should create MoodEntry with all parameters', () {
      expect(testEntry.id, 'test-id');
      expect(testEntry.mood, MoodType.happy);
      expect(testEntry.timestamp, testDate);
      expect(testEntry.note, 'Test note');
      expect(testEntry.activities, ['work', 'exercise']);
      expect(testEntry.sleepDuration, const Duration(hours: 8));
      expect(testEntry.sleepTime, DateTime(2024, 1, 1, 22, 0));
      expect(testEntry.wakeTime, DateTime(2024, 1, 2, 6, 0));
    });

    test('should create MoodEntry with default parameters', () {
      final minimalEntry = MoodEntry(
        id: 'minimal-id',
        mood: MoodType.neutral,
        timestamp: testDate,
      );

      expect(minimalEntry.id, 'minimal-id');
      expect(minimalEntry.mood, MoodType.neutral);
      expect(minimalEntry.timestamp, testDate);
      expect(minimalEntry.note, null);
      expect(minimalEntry.activities, []);
      expect(minimalEntry.sleepDuration, null);
      expect(minimalEntry.sleepTime, null);
      expect(minimalEntry.wakeTime, null);
    });

    test('copyWith should create new instance with updated fields', () {
      final copiedEntry = testEntry.copyWith(
        mood: MoodType.veryHappy,
        note: 'Updated note',
      );

      expect(copiedEntry.id, testEntry.id);
      expect(copiedEntry.mood, MoodType.veryHappy);
      expect(copiedEntry.timestamp, testEntry.timestamp);
      expect(copiedEntry.note, 'Updated note');
      expect(copiedEntry.activities, testEntry.activities);
      expect(copiedEntry.sleepDuration, testEntry.sleepDuration);
      expect(copiedEntry.sleepTime, testEntry.sleepTime);
      expect(copiedEntry.wakeTime, testEntry.wakeTime);
    });

    test('copyWith should maintain original values when no parameters provided', () {
      final copiedEntry = testEntry.copyWith();

      expect(copiedEntry.id, testEntry.id);
      expect(copiedEntry.mood, testEntry.mood);
      expect(copiedEntry.timestamp, testEntry.timestamp);
      expect(copiedEntry.note, testEntry.note);
      expect(copiedEntry.activities, testEntry.activities);
      expect(copiedEntry.sleepDuration, testEntry.sleepDuration);
      expect(copiedEntry.sleepTime, testEntry.sleepTime);
      expect(copiedEntry.wakeTime, testEntry.wakeTime);
    });

    test('copyWith should handle all fields', () {
      final newDate = DateTime(2024, 1, 2, 12, 0);
      final newSleepTime = DateTime(2024, 1, 2, 23, 0);
      final newWakeTime = DateTime(2024, 1, 3, 7, 0);
      
      final copiedEntry = testEntry.copyWith(
        id: 'new-id',
        mood: MoodType.verySad,
        timestamp: newDate,
        note: 'New note',
        activities: ['reading', 'coding'],
        sleepDuration: const Duration(hours: 7),
        sleepTime: newSleepTime,
        wakeTime: newWakeTime,
      );

      expect(copiedEntry.id, 'new-id');
      expect(copiedEntry.mood, MoodType.verySad);
      expect(copiedEntry.timestamp, newDate);
      expect(copiedEntry.note, 'New note');
      expect(copiedEntry.activities, ['reading', 'coding']);
      expect(copiedEntry.sleepDuration, const Duration(hours: 7));
      expect(copiedEntry.sleepTime, newSleepTime);
      expect(copiedEntry.wakeTime, newWakeTime);
    });
  });
}