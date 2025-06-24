import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker_plus/models/realm/statistics_model.dart';
import 'dart:convert';

void main() {
  group('StatisticsModel', () {
    late StatisticsModel stats;

    setUp(() {
      stats = StatisticsModel(
        'test-stats-${DateTime.now().millisecondsSinceEpoch}',
        'daily',
        DateTime(2024, 3, 15),
        4.2,
        12,
        'Счастливый',
        480,
        jsonEncode(['Работа', 'Спорт', 'Чтение']),
        DateTime.now(),
      );
    });

    group('инициализация', () {
      test('должна создаваться с корректными параметрами', () {
        expect(stats.type, equals('daily'));
        expect(stats.date, equals(DateTime(2024, 3, 15)));
        expect(stats.averageMood, equals(4.2));
        expect(stats.entryCount, equals(12));
        expect(stats.mostCommonMood, equals('Счастливый'));
        expect(stats.totalSleepMinutes, equals(480));
        expect(stats.lastUpdated, isA<DateTime>());
      });

      test('должна корректно кодировать topActivities в JSON', () {
        final activities = jsonDecode(stats.topActivities) as List;
        expect(activities, contains('Работа'));
        expect(activities, contains('Спорт'));
        expect(activities, contains('Чтение'));
        expect(activities.length, equals(3));
      });

      test('должна создаваться с типом daily', () {
        final dailyStats = StatisticsModel(
          'test-stats-${DateTime.now().millisecondsSinceEpoch}',
          'daily',
          DateTime.now(),
          3.5,
          8,
          'Нормальный',
          420,
          jsonEncode(['Учеба']),
          DateTime.now(),
        );

        expect(dailyStats.type, equals('daily'));
        expect(dailyStats.entryCount, equals(8));
      });

      test('должна создаваться с типом weekly', () {
        final weeklyStats = StatisticsModel(
          'test-stats-${DateTime.now().millisecondsSinceEpoch}',
          'weekly',
          DateTime.now(),
          4.0,
          50,
          'Радостный',
          3000,
          jsonEncode(['Работа', 'Отдых']),
          DateTime.now(),
        );

        expect(weeklyStats.type, equals('weekly'));
        expect(weeklyStats.entryCount, equals(50));
      });

      test('должна создаваться с типом monthly', () {
        final monthlyStats = StatisticsModel(
          'test-stats-${DateTime.now().millisecondsSinceEpoch}',
          'monthly',
          DateTime.now(),
          3.8,
          200,
          'Спокойный',
          12000,
          jsonEncode(['Работа', 'Семья', 'Хобби']),
          DateTime.now(),
        );

        expect(monthlyStats.type, equals('monthly'));
        expect(monthlyStats.entryCount, equals(200));
      });
    });

    group('валидация данных', () {
      test('должна работать с пустым списком активностей', () {
        final emptyStats = StatisticsModel(
          'test-stats-${DateTime.now().millisecondsSinceEpoch}',
          'daily',
          DateTime.now(),
          0.0,
          0,
          '',
          0,
          jsonEncode([]),
          DateTime.now(),
        );

        final activities = jsonDecode(emptyStats.topActivities) as List;
        expect(activities, isEmpty);
      });

      test('должна работать с нулевыми значениями', () {
        final zeroStats = StatisticsModel(
          'test-stats-${DateTime.now().millisecondsSinceEpoch}',
          'daily',
          DateTime.now(),
          0.0,
          0,
          '',
          0,
          jsonEncode([]),
          DateTime.now(),
        );

        expect(zeroStats.averageMood, equals(0.0));
        expect(zeroStats.entryCount, equals(0));
        expect(zeroStats.totalSleepMinutes, equals(0));
      });

      test('должна работать с высокими значениями', () {
        final highStats = StatisticsModel(
          'test-stats-${DateTime.now().millisecondsSinceEpoch}',
          'monthly',
          DateTime.now(),
          5.0,
          1000,
          'Очень счастливый',
          43200, // 30 дней * 24 часа * 60 минут
          jsonEncode(List.generate(10, (i) => 'Активность $i')),
          DateTime.now(),
        );

        expect(highStats.averageMood, equals(5.0));
        expect(highStats.entryCount, equals(1000));
        expect(highStats.totalSleepMinutes, equals(43200));
      });

      test('должна корректно работать с русскими символами', () {
        final russianStats = StatisticsModel(
          'test-stats-${DateTime.now().millisecondsSinceEpoch}',
          'daily',
          DateTime.now(),
          4.5,
          15,
          'Очень счастливый 😊',
          500,
          jsonEncode(['Работа 💼', 'Спорт 🏃', 'Отдых 🏖️']),
          DateTime.now(),
        );

        expect(russianStats.mostCommonMood, contains('Очень'));
        expect(russianStats.mostCommonMood, contains('😊'));
        
        final activities = jsonDecode(russianStats.topActivities) as List;
        expect(activities.first, contains('💼'));
      });
    });

    group('обработка JSON', () {
      test('должна корректно декодировать сложные активности', () {
        final complexActivities = [
          'Работа с клиентами',
          'Спорт (бег)',
          'Чтение книг по программированию',
          'Время с семьей',
          'Медитация/релаксация'
        ];
        
        final complexStats = StatisticsModel(
          'test-stats-${DateTime.now().millisecondsSinceEpoch}',
          'weekly',
          DateTime.now(),
          4.3,
          35,
          'Счастливый',
          2800,
          jsonEncode(complexActivities),
          DateTime.now(),
        );

        final decodedActivities = jsonDecode(complexStats.topActivities) as List;
        expect(decodedActivities.length, equals(5));
        expect(decodedActivities, contains('Работа с клиентами'));
        expect(decodedActivities, contains('Спорт (бег)'));
        expect(decodedActivities, contains('Медитация/релаксация'));
      });

      test('должна обрабатывать специальные символы в JSON', () {
        final specialActivities = [
          'Активность с "кавычками"',
          'Активность с \'апострофами\'',
          'Активность\nс переносом',
          'Активность\\с слэшем'
        ];
        
        final specialStats = StatisticsModel(
          'test-stats-${DateTime.now().millisecondsSinceEpoch}',
          'daily',
          DateTime.now(),
          3.7,
          8,
          'Нормальный',
          450,
          jsonEncode(specialActivities),
          DateTime.now(),
        );

        final decodedActivities = jsonDecode(specialStats.topActivities) as List;
        expect(decodedActivities.length, equals(4));
        expect(decodedActivities[0], contains('"кавычками"'));
        expect(decodedActivities[1], contains('\'апострофами\''));
      });
    });

    group('типы статистики', () {
      test('должна поддерживать все типы периодов', () {
        final types = ['daily', 'weekly', 'monthly'];
        
        for (final type in types) {
          final typeStats = StatisticsModel(
            'test-stats-${DateTime.now().millisecondsSinceEpoch}',
            type,
            DateTime.now(),
            4.0,
            10,
            'Тест',
            400,
            jsonEncode(['Тест']),
            DateTime.now(),
          );
          
          expect(typeStats.type, equals(type));
        }
      });

      test('должна работать с различными датами', () {
        final dates = [
          DateTime(2024, 1, 1),    // Начало года
          DateTime(2024, 6, 15),   // Середина года
          DateTime(2024, 12, 31),  // Конец года
          DateTime(2023, 2, 29),   // Високосный год (если возможно)
        ];
        
        for (final date in dates) {
          final dateStats = StatisticsModel(
            'test-stats-${DateTime.now().millisecondsSinceEpoch}',
            'daily',
            date,
            4.0,
            10,
            'Тест',
            400,
            jsonEncode(['Тест']),
            DateTime.now(),
          );
          
          expect(dateStats.date, equals(date));
        }
      });
    });

    group('граничные случаи', () {
      test('должна работать с минимальными значениями', () {
        final minStats = StatisticsModel(
          'test-stats-${DateTime.now().millisecondsSinceEpoch}',
          'daily',
          DateTime(1970, 1, 1),
          0.0,
          0,
          '',
          0,
          jsonEncode([]),
          DateTime(1970, 1, 1),
        );

        expect(minStats.averageMood, equals(0.0));
        expect(minStats.entryCount, equals(0));
        expect(minStats.totalSleepMinutes, equals(0));
        expect(minStats.mostCommonMood, isEmpty);
      });

      test('должна работать с очень длинными строками', () {
        final longMood = 'Очень ' * 100 + 'длинное настроение';
        final longActivities = List.generate(20, (i) => 'Очень длинная активность номер $i с множеством дополнительных слов');
        
        final longStats = StatisticsModel(
          'test-stats-${DateTime.now().millisecondsSinceEpoch}',
          'monthly',
          DateTime.now(),
          4.5,
          500,
          longMood,
          15000,
          jsonEncode(longActivities),
          DateTime.now(),
        );

        expect(longStats.mostCommonMood.length, greaterThan(500));
        expect(longStats.topActivities.length, greaterThan(1000));
        
        final decodedActivities = jsonDecode(longStats.topActivities) as List;
        expect(decodedActivities.length, equals(20));
      });
    });

    group('сравнение объектов', () {
      test('два объекта с одинаковым ID должны считаться равными по ключу', () {
        final id = 'test-unique-${DateTime.now().millisecondsSinceEpoch}';
        
        final stats1 = StatisticsModel(
          id,
          'daily',
          DateTime.now(),
          4.0,
          10,
          'Тест1',
          400,
          jsonEncode(['Тест1']),
          DateTime.now(),
        );
        
        final stats2 = StatisticsModel(
          id,
          'weekly',
          DateTime.now(),
          3.0,
          20,
          'Тест2',
          500,
          jsonEncode(['Тест2']),
          DateTime.now(),
        );

        expect(stats1.id, equals(stats2.id));
      });
    });
  });
}