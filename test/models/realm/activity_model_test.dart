import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker_plus/models/realm/activity_model.dart';

void main() {
  group('ActivityModel', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
    });

    group('Construction', () {
      test('should create activity with required fields', () {
        final activity = ActivityModel(
          'exercise',
          'health',
          testDate,
          5,
        );

        expect(activity.name, equals('exercise'));
        expect(activity.category, equals('health'));
        expect(activity.createdAt, equals(testDate));
        expect(activity.usageCount, equals(5));
        expect(activity.description, isNull);
        expect(activity.iconCode, isNull);
      });

      test('should create activity with all fields', () {
        final activity = ActivityModel(
          'reading',
          'leisure',
          testDate,
          10,
        );
        activity.description = 'Reading books and articles';
        activity.iconCode = 'book_icon';

        expect(activity.name, equals('reading'));
        expect(activity.category, equals('leisure'));
        expect(activity.createdAt, equals(testDate));
        expect(activity.usageCount, equals(10));
        expect(activity.description, equals('Reading books and articles'));
        expect(activity.iconCode, equals('book_icon'));
      });
    });

    group('Primary Key Functionality', () {
      test('should use name as primary key', () {
        final activity1 = ActivityModel('unique_activity', 'test', testDate, 1);
        final activity2 = ActivityModel('unique_activity', 'different_category', testDate, 100);

        // Оба должны иметь одинаковый primary key (name)
        expect(activity1.name, equals(activity2.name));
        expect(activity1.name, equals('unique_activity'));
      });

      test('should handle special characters in name', () {
        final specialNames = [
          'activity-with-dashes',
          'activity_with_underscores',
          'activity with spaces',
          'activity@with#special!chars',
          'активность на русском',
          '活动中文',
          '🏃‍♂️ running with emoji',
        ];

        for (final name in specialNames) {
          final activity = ActivityModel(name, 'test', testDate, 1);
          expect(activity.name, equals(name));
        }
      });

      test('should handle empty and very long names', () {
        // Empty name
        final emptyActivity = ActivityModel('', 'test', testDate, 1);
        expect(emptyActivity.name, equals(''));

        // Very long name
        final longName = 'activity' * 100; // 800 characters
        final longActivity = ActivityModel(longName, 'test', testDate, 1);
        expect(longActivity.name, equals(longName));
      });
    });

    group('Category Handling', () {
      test('should support common activity categories', () {
        final commonCategories = [
          'health',
          'leisure',
          'work',
          'social',
          'exercise',
          'education',
          'entertainment',
          'household',
          'travel',
          'spiritual',
          'creative',
          'user_defined',
        ];

        for (final category in commonCategories) {
          final activity = ActivityModel('test_activity', category, testDate, 1);
          expect(activity.category, equals(category));
        }
      });

      test('should handle special characters in category', () {
        final specialCategories = [
          'self-care',
          'work_related',
          'fun & games',
          'health/fitness',
          'категория на русском',
        ];

        for (final category in specialCategories) {
          final activity = ActivityModel('test', category, testDate, 1);
          expect(activity.category, equals(category));
        }
      });
    });

    group('Usage Count Functionality', () {
      test('should handle various usage count values', () {
        final usageCounts = [0, 1, 100, 999999, -1]; // Including edge cases

        for (final count in usageCounts) {
          final activity = ActivityModel('test', 'test', testDate, count);
          expect(activity.usageCount, equals(count));
        }
      });

      test('should support incrementing usage count', () {
        final activity = ActivityModel('test', 'test', testDate, 5);
        
        activity.usageCount++;
        expect(activity.usageCount, equals(6));
        
        activity.usageCount += 10;
        expect(activity.usageCount, equals(16));
      });

      test('should handle large usage counts', () {
        final activity = ActivityModel('popular', 'test', testDate, 999999999);
        expect(activity.usageCount, equals(999999999));
      });
    });

    group('DateTime Handling', () {
      test('should handle various date formats', () {
        final dates = [
          DateTime(1970, 1, 1), // Unix epoch
          DateTime(2000, 12, 31, 23, 59, 59), // Y2K transition
          DateTime.now(), // Current time
          DateTime(2100, 6, 15), // Future date
          DateTime(2024, 2, 29), // Leap year
        ];

        for (final date in dates) {
          final activity = ActivityModel('test', 'test', date, 1);
          expect(activity.createdAt, equals(date));
        }
      });

      test('should preserve millisecond precision', () {
        final preciseDate = DateTime(2024, 1, 15, 10, 30, 45, 123, 456);
        final activity = ActivityModel('precise', 'test', preciseDate, 1);
        
        expect(activity.createdAt, equals(preciseDate));
        expect(activity.createdAt.millisecond, equals(123));
        expect(activity.createdAt.microsecond, equals(456));
      });
    });

    group('Optional Fields', () {
      test('should handle null description and iconCode', () {
        final activity = ActivityModel('minimal', 'test', testDate, 1);
        
        expect(activity.description, isNull);
        expect(activity.iconCode, isNull);
      });

      test('should handle empty string values for optional fields', () {
        final activity = ActivityModel('empty_fields', 'test', testDate, 1);
        activity.description = '';
        activity.iconCode = '';
        
        expect(activity.description, equals(''));
        expect(activity.iconCode, equals(''));
      });

      test('should handle very long description', () {
        final longDescription = 'This is a very long description that goes on and on. ' * 100;
        final activity = ActivityModel('long_desc', 'test', testDate, 1);
        activity.description = longDescription;
        
        expect(activity.description, equals(longDescription));
      });

      test('should handle special characters in optional fields', () {
        final activity = ActivityModel('special', 'test', testDate, 1);
        activity.description = 'Description with special chars: !@#\$%^&*()_+-=[]{}|;:,.<>?~`';
        activity.iconCode = 'icon_with_special_chars_123!@#';
        
        expect(activity.description, contains('special chars'));
        expect(activity.iconCode, contains('icon_with_special_chars'));
      });
    });

    group('Real-world Use Cases', () {
      test('should represent common real-world activities', () {
        final realActivities = [
          ('morning jog', 'exercise', 'Daily 30-minute run around the neighborhood', 'run_icon'),
          ('work meeting', 'work', 'Team standup and project planning', 'meeting_icon'),
          ('reading book', 'leisure', 'Reading "The Pragmatic Programmer"', 'book_icon'),
          ('cooking dinner', 'household', 'Preparing healthy meal for family', 'cook_icon'),
          ('meditation', 'wellness', '15 minutes mindfulness practice', 'meditation_icon'),
          ('video call with friends', 'social', 'Weekly catch-up with college friends', 'video_icon'),
        ];

        for (final (name, category, description, iconCode) in realActivities) {
          final activity = ActivityModel(name, category, testDate, 1);
          activity.description = description;
          activity.iconCode = iconCode;

          expect(activity.name, equals(name));
          expect(activity.category, equals(category));
          expect(activity.description, equals(description));
          expect(activity.iconCode, equals(iconCode));
        }
      });

      test('should support activity tracking scenarios', () {
        final activity = ActivityModel('gym workout', 'fitness', testDate, 0);
        activity.description = 'Strength training session';
        activity.iconCode = 'gym_icon';

        // Simulate tracking usage over time
        final usageScenarios = [
          'First time trying this activity',
          'Second session this week',
          'Building consistency',
          'Regular habit forming',
          'Well-established routine',
        ];

        for (int i = 0; i < usageScenarios.length; i++) {
          activity.usageCount++;
          expect(activity.usageCount, equals(i + 1));
        }

        expect(activity.usageCount, equals(5));
      });

      test('should handle multilingual activity names', () {
        final multilingualActivities = [
          ('спорт', 'здоровье'), // Russian
          ('読書', '娯楽'), // Japanese
          ('trabajo', 'profesional'), // Spanish
          ('운동', '건강'), // Korean
          ('ผ่อนคลาย', 'สุขภาพ'), // Thai
        ];

        for (final (name, category) in multilingualActivities) {
          final activity = ActivityModel(name, category, testDate, 1);
          expect(activity.name, equals(name));
          expect(activity.category, equals(category));
        }
      });
    });

    group('Edge Cases and Boundaries', () {
      test('should handle extreme usage counts', () {
        // Test boundary conditions
        final extremeCounts = [
          -999999999, // Very negative
          0, // Zero
          1, // Minimum positive
          2147483647, // Max 32-bit signed integer
        ];

        for (final count in extremeCounts) {
          final activity = ActivityModel('extreme', 'test', testDate, count);
          expect(activity.usageCount, equals(count));
        }
      });

      test('should handle very long names and categories', () {
        final longName = 'a' * 1000;
        final longCategory = 'b' * 1000;
        
        final activity = ActivityModel(longName, longCategory, testDate, 1);
        expect(activity.name.length, equals(1000));
        expect(activity.category.length, equals(1000));
      });

      test('should handle unicode and emoji characters', () {
        final activity = ActivityModel(
          '🏃‍♂️ Running with 💪 strength training 🎯',
          '💪 fitness & health 🏃‍♀️',
          testDate,
          42,
        );
        activity.description = '🌟 Amazing workout session! 💯 energy boost! 🚀';
        activity.iconCode = '🏃‍♂️';

        expect(activity.name, contains('🏃‍♂️'));
        expect(activity.category, contains('💪'));
        expect(activity.description, contains('💯'));
        expect(activity.iconCode, equals('🏃‍♂️'));
      });
    });

    group('Comparison and Equality', () {
      test('should support comparison by usage count', () {
        final activity1 = ActivityModel('low_usage', 'test', testDate, 5);
        final activity2 = ActivityModel('high_usage', 'test', testDate, 50);
        final activity3 = ActivityModel('medium_usage', 'test', testDate, 25);

        final activities = [activity1, activity2, activity3];
        activities.sort((a, b) => b.usageCount.compareTo(a.usageCount));

        expect(activities[0].name, equals('high_usage'));
        expect(activities[1].name, equals('medium_usage'));
        expect(activities[2].name, equals('low_usage'));
      });

      test('should support comparison by creation date', () {
        final oldActivity = ActivityModel('old', 'test', DateTime(2020, 1, 1), 1);
        final newActivity = ActivityModel('new', 'test', DateTime(2024, 1, 1), 1);
        final middleActivity = ActivityModel('middle', 'test', DateTime(2022, 1, 1), 1);

        final activities = [middleActivity, newActivity, oldActivity];
        activities.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        expect(activities[0].name, equals('old'));
        expect(activities[1].name, equals('middle'));
        expect(activities[2].name, equals('new'));
      });
    });
  });
}