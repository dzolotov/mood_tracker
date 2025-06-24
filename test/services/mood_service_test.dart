import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker_plus/models/mood_entry.dart';
import 'package:mood_tracker_plus/services/mood_service.dart';

void main() {
  group('MoodService', () {
    late MoodService moodService;
    late MoodEntry testEntry;

    setUp(() {
      moodService = MoodService();
      testEntry = MoodEntry(
        id: 'test-1',
        mood: MoodType.happy,
        timestamp: DateTime(2024, 1, 1, 12, 0),
        note: 'Test note',
        activities: ['work'],
      );
    });

    test('should start with empty entries list', () {
      expect(moodService.entries, isEmpty);
    });

    group('addMoodEntry', () {
      test('should add entry to the list', () {
        moodService.addMoodEntry(testEntry);
        
        expect(moodService.entries.length, 1);
        expect(moodService.entries.first.id, 'test-1');
        expect(moodService.entries.first.mood, MoodType.happy);
      });

      test('should notify listeners when entry is added', () {
        bool notified = false;
        moodService.addListener(() => notified = true);
        
        moodService.addMoodEntry(testEntry);
        
        expect(notified, true);
      });

      test('should add multiple entries', () {
        final entry2 = MoodEntry(
          id: 'test-2',
          mood: MoodType.neutral,
          timestamp: DateTime(2024, 1, 2, 12, 0),
        );

        moodService.addMoodEntry(testEntry);
        moodService.addMoodEntry(entry2);
        
        expect(moodService.entries.length, 2);
        expect(moodService.entries[0].id, 'test-1');
        expect(moodService.entries[1].id, 'test-2');
      });
    });

    group('updateMoodEntry', () {
      setUp(() {
        moodService.addMoodEntry(testEntry);
      });

      test('should update existing entry', () {
        final updatedEntry = testEntry.copyWith(
          mood: MoodType.veryHappy,
          note: 'Updated note',
        );

        moodService.updateMoodEntry('test-1', updatedEntry);
        
        expect(moodService.entries.length, 1);
        expect(moodService.entries.first.mood, MoodType.veryHappy);
        expect(moodService.entries.first.note, 'Updated note');
      });

      test('should notify listeners when entry is updated', () {
        bool notified = false;
        moodService.addListener(() => notified = true);
        
        final updatedEntry = testEntry.copyWith(mood: MoodType.veryHappy);
        moodService.updateMoodEntry('test-1', updatedEntry);
        
        expect(notified, true);
      });

      test('should not update if entry not found', () {
        final updatedEntry = testEntry.copyWith(
          id: 'non-existent',
          mood: MoodType.veryHappy,
        );

        moodService.updateMoodEntry('non-existent', updatedEntry);
        
        expect(moodService.entries.length, 1);
        expect(moodService.entries.first.mood, MoodType.happy);
      });
    });

    group('deleteMoodEntry', () {
      setUp(() {
        moodService.addMoodEntry(testEntry);
      });

      test('should delete existing entry', () {
        moodService.deleteMoodEntry('test-1');
        
        expect(moodService.entries, isEmpty);
      });

      test('should notify listeners when entry is deleted', () {
        bool notified = false;
        moodService.addListener(() => notified = true);
        
        moodService.deleteMoodEntry('test-1');
        
        expect(notified, true);
      });

      test('should handle deletion of non-existent entry', () {
        moodService.deleteMoodEntry('non-existent');
        
        expect(moodService.entries.length, 1);
      });
    });

    group('getMoodEntryById', () {
      setUp(() {
        moodService.addMoodEntry(testEntry);
      });

      test('should return entry when found', () {
        final foundEntry = moodService.getMoodEntryById('test-1');
        
        expect(foundEntry, isNotNull);
        expect(foundEntry!.id, 'test-1');
        expect(foundEntry.mood, MoodType.happy);
      });

      test('should return null when not found', () {
        final foundEntry = moodService.getMoodEntryById('non-existent');
        
        expect(foundEntry, isNull);
      });
    });

    group('getEntriesByDateRange', () {
      setUp(() {
        // Add entries for different dates
        moodService.addMoodEntry(MoodEntry(
          id: 'entry-1',
          mood: MoodType.happy,
          timestamp: DateTime(2024, 1, 1, 10, 0),
        ));
        moodService.addMoodEntry(MoodEntry(
          id: 'entry-2',
          mood: MoodType.neutral,
          timestamp: DateTime(2024, 1, 2, 15, 0),
        ));
        moodService.addMoodEntry(MoodEntry(
          id: 'entry-3',
          mood: MoodType.sad,
          timestamp: DateTime(2024, 1, 3, 20, 0),
        ));
      });

      test('should return entries within date range', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 2);
        
        final entries = moodService.getEntriesByDateRange(start, end);
        
        expect(entries.length, 2);
        expect(entries[0].id, 'entry-1');
        expect(entries[1].id, 'entry-2');
      });

      test('should return empty list when no entries in range', () {
        final start = DateTime(2024, 1, 5);
        final end = DateTime(2024, 1, 6);
        
        final entries = moodService.getEntriesByDateRange(start, end);
        
        expect(entries, isEmpty);
      });

      test('should include entries on the same day', () {
        final start = DateTime(2024, 1, 2);
        final end = DateTime(2024, 1, 2);
        
        final entries = moodService.getEntriesByDateRange(start, end);
        
        expect(entries.length, 1);
        expect(entries[0].id, 'entry-2');
      });
    });

    group('getAverageMood', () {
      test('should return 0 for empty entries', () {
        expect(moodService.getAverageMood(), 0);
      });

      test('should calculate correct average', () {
        moodService.addMoodEntry(MoodEntry(
          id: '1',
          mood: MoodType.veryHappy, // value: 5
          timestamp: DateTime.now(),
        ));
        moodService.addMoodEntry(MoodEntry(
          id: '2',
          mood: MoodType.happy, // value: 4
          timestamp: DateTime.now(),
        ));
        moodService.addMoodEntry(MoodEntry(
          id: '3',
          mood: MoodType.neutral, // value: 3
          timestamp: DateTime.now(),
        ));
        
        expect(moodService.getAverageMood(), 4.0);
      });
    });

    group('getMostFrequentMood', () {
      test('should return null for empty entries', () {
        expect(moodService.getMostFrequentMood(), isNull);
      });

      test('should return most frequent mood', () {
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
          mood: MoodType.neutral,
          timestamp: DateTime.now(),
        ));
        
        expect(moodService.getMostFrequentMood(), MoodType.happy);
      });

      test('should handle tie by returning first in comparison', () {
        moodService.addMoodEntry(MoodEntry(
          id: '1',
          mood: MoodType.happy,
          timestamp: DateTime.now(),
        ));
        moodService.addMoodEntry(MoodEntry(
          id: '2',
          mood: MoodType.neutral,
          timestamp: DateTime.now(),
        ));
        
        // В случае равенства, функция вернет тот mood, который был последним в reduce
        final result = moodService.getMostFrequentMood();
        expect(result, isNotNull);
        expect([MoodType.happy, MoodType.neutral], contains(result));
      });
    });

    group('entries getter', () {
      test('should return unmodifiable list', () {
        moodService.addMoodEntry(testEntry);
        final entries = moodService.entries;
        
        expect(() => entries.add(testEntry), throwsUnsupportedError);
      });
    });
  });
}