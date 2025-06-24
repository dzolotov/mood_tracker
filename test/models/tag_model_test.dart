import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker_plus/models/realm/tag_model.dart';

void main() {
  group('TagModel', () {
    late TagModel tag;

    setUp(() {
      tag = TagModel(
        'работа',
        '#FF5722',
        DateTime(2024, 3, 15, 10, 30),
        5,
        description: 'Тег для рабочих активностей',
      );
    });

    group('инициализация', () {
      test('должна создаваться с обязательными параметрами', () {
        final basicTag = TagModel(
          'спорт',
          '#4CAF50',
          DateTime.now(),
          0,
        );

        expect(basicTag.name, equals('спорт'));
        expect(basicTag.color, equals('#4CAF50'));
        expect(basicTag.usageCount, equals(0));
        expect(basicTag.description, isNull);
      });

      test('должна создаваться с полными параметрами', () {
        expect(tag.name, equals('работа'));
        expect(tag.color, equals('#FF5722'));
        expect(tag.createdAt, equals(DateTime(2024, 3, 15, 10, 30)));
        expect(tag.usageCount, equals(5));
        expect(tag.description, equals('Тег для рабочих активностей'));
      });

      test('должна корректно обрабатывать русские названия', () {
        final russianTag = TagModel(
          'отдых и развлечения',
          '#2196F3',
          DateTime.now(),
          10,
          description: 'Тег для активностей отдыха',
        );

        expect(russianTag.name, equals('отдых и развлечения'));
        expect(russianTag.description, contains('отдыха'));
      });

      test('должна корректно обрабатывать эмодзи в названии', () {
        final emojiTag = TagModel(
          '🏃 спорт',
          '#FFC107',
          DateTime.now(),
          3,
          description: '🏃‍♂️ Физическая активность',
        );

        expect(emojiTag.name, contains('🏃'));
        expect(emojiTag.description, contains('🏃‍♂️'));
      });
    });

    group('валидация цветов', () {
      test('должна работать с HEX цветами', () {
        final hexColors = [
          '#FF0000',  // Красный
          '#00FF00',  // Зеленый
          '#0000FF',  // Синий
          '#FFFFFF',  // Белый
          '#000000',  // Черный
          '#ff5722',  // Строчные буквы
        ];

        for (final color in hexColors) {
          final colorTag = TagModel(
            'тест_$color',
            color,
            DateTime.now(),
            0,
          );
          
          expect(colorTag.color, equals(color));
        }
      });

      test('должна работать с именованными цветами', () {
        final namedColors = [
          'red',
          'green',
          'blue',
          'orange',
          'purple',
        ];

        for (final color in namedColors) {
          final colorTag = TagModel(
            'тест_$color',
            color,
            DateTime.now(),
            0,
          );
          
          expect(colorTag.color, equals(color));
        }
      });

      test('должна работать с RGB цветами', () {
        final rgbColors = [
          'rgb(255, 0, 0)',
          'rgb(0, 255, 0)',
          'rgb(0, 0, 255)',
          'rgba(255, 0, 0, 0.5)',
        ];

        for (final color in rgbColors) {
          final colorTag = TagModel(
            'тест_rgb',
            color,
            DateTime.now(),
            0,
          );
          
          expect(colorTag.color, equals(color));
        }
      });
    });

    group('счетчик использования', () {
      test('должна начинаться с нулевого использования', () {
        final newTag = TagModel(
          'новый_тег',
          '#E91E63',
          DateTime.now(),
          0,
        );

        expect(newTag.usageCount, equals(0));
      });

      test('должна корректно отслеживать количество использований', () {
        final usageCounts = [1, 5, 10, 100, 1000];

        for (final count in usageCounts) {
          final usageTag = TagModel(
            'тег_$count',
            '#9C27B0',
            DateTime.now(),
            count,
          );
          
          expect(usageTag.usageCount, equals(count));
        }
      });

      test('должна работать с очень большими значениями использования', () {
        final highUsageTag = TagModel(
          'популярный_тег',
          '#673AB7',
          DateTime.now(),
          999999,
        );

        expect(highUsageTag.usageCount, equals(999999));
      });
    });

    group('описание тега', () {
      test('должна работать без описания', () {
        final noDescTag = TagModel(
          'без_описания',
          '#607D8B',
          DateTime.now(),
          0,
        );

        expect(noDescTag.description, isNull);
      });

      test('должна работать с коротким описанием', () {
        final shortDescTag = TagModel(
          'короткий',
          '#795548',
          DateTime.now(),
          0,
          description: 'Короткое описание',
        );

        expect(shortDescTag.description, equals('Короткое описание'));
      });

      test('должна работать с длинным описанием', () {
        final longDescription = 'Это очень длинное описание тега, которое содержит много информации о том, ' +
            'для чего используется данный тег и в каких ситуациях его следует применять. ' +
            'Описание может включать специальные символы: !@#\$%^&*()_+ и даже эмодзи 🎉🎊✨';
        
        final longDescTag = TagModel(
          'длинный',
          '#FF9800',
          DateTime.now(),
          0,
          description: longDescription,
        );

        expect(longDescTag.description, equals(longDescription));
        expect(longDescTag.description!.length, greaterThan(100));
      });

      test('должна работать с многострочным описанием', () {
        final multilineDescription = 'Первая строка\nВторая строка\nТретья строка\n\nПятая строка после пустой';
        
        final multilineTag = TagModel(
          'многострочный',
          '#CDDC39',
          DateTime.now(),
          0,
          description: multilineDescription,
        );

        expect(multilineTag.description, contains('\n'));
        expect(multilineTag.description!.split('\n').length, equals(5));
      });

      test('должна работать с описанием из специальных символов', () {
        final specialDescription = 'Описание с "кавычками", \'апострофами\', символами: @#\$%^&*()[]{}|\\;:,.<>?/`~';
        
        final specialTag = TagModel(
          'спецсимволы',
          '#8BC34A',
          DateTime.now(),
          0,
          description: specialDescription,
        );

        expect(specialTag.description, contains('"кавычками"'));
        expect(specialTag.description, contains('\'апострофами\''));
        expect(specialTag.description, contains('@#\$%^&*()'));
      });
    });

    group('имена тегов', () {
      test('должна работать с простыми именами', () {
        final simpleNames = [
          'работа',
          'спорт',
          'семья',
          'учеба',
          'здоровье',
        ];

        for (final name in simpleNames) {
          final simpleTag = TagModel(
            name,
            '#03DAC6',
            DateTime.now(),
            0,
          );
          
          expect(simpleTag.name, equals(name));
        }
      });

      test('должна работать со сложными именами', () {
        final complexNames = [
          'работа_в_офисе',
          'спорт-активности',
          'семья и друзья',
          'учеба/образование',
          'здоровье+питание',
          'хобби & развлечения',
        ];

        for (final name in complexNames) {
          final complexTag = TagModel(
            name,
            '#6200EE',
            DateTime.now(),
            0,
          );
          
          expect(complexTag.name, equals(name));
        }
      });

      test('должна работать с именами из разных языков', () {
        final multiLangNames = [
          'work',           // Английский
          'trabajo',        // Испанский
          'travail',        // Французский
          '仕事',           // Японский
          '工作',           // Китайский
          'работа',         // Русский
        ];

        for (final name in multiLangNames) {
          final multiLangTag = TagModel(
            name,
            '#BB86FC',
            DateTime.now(),
            0,
          );
          
          expect(multiLangTag.name, equals(name));
        }
      });

      test('должна работать с очень длинными именами', () {
        final longName = 'очень_длинное_имя_тега_которое_содержит_множество_слов_и_символов_для_тестирования_граничных_случаев';
        
        final longNameTag = TagModel(
          longName,
          '#CF6679',
          DateTime.now(),
          0,
        );

        expect(longNameTag.name, equals(longName));
        expect(longNameTag.name.length, greaterThan(50));
      });
    });

    group('временные метки', () {
      test('должна корректно сохранять время создания', () {
        final specificDate = DateTime(2024, 6, 15, 14, 30, 45, 123);
        
        final timeTag = TagModel(
          'временной_тег',
          '#F44336',
          specificDate,
          0,
        );

        expect(timeTag.createdAt, equals(specificDate));
        expect(timeTag.createdAt.year, equals(2024));
        expect(timeTag.createdAt.month, equals(6));
        expect(timeTag.createdAt.day, equals(15));
        expect(timeTag.createdAt.hour, equals(14));
        expect(timeTag.createdAt.minute, equals(30));
        expect(timeTag.createdAt.second, equals(45));
      });

      test('должна работать с граничными датами', () {
        final boundaryDates = [
          DateTime(1970, 1, 1),        // Unix epoch
          DateTime(2000, 1, 1),        // Новое тысячелетие
          DateTime(2024, 2, 29),       // Високосный год
          DateTime(2024, 12, 31, 23, 59, 59),  // Конец года
        ];

        for (final date in boundaryDates) {
          final dateTag = TagModel(
            'дата_${date.year}_${date.month}_${date.day}',
            '#E91E63',
            date,
            0,
          );
          
          expect(dateTag.createdAt, equals(date));
        }
      });
    });

    group('первичный ключ', () {
      test('имя должно служить первичным ключом', () {
        final tag1 = TagModel(
          'уникальный_тег',
          '#9C27B0',
          DateTime.now(),
          5,
        );
        
        final tag2 = TagModel(
          'уникальный_тег',
          '#673AB7',
          DateTime.now().add(const Duration(hours: 1)),
          10,
          description: 'Другое описание',
        );

        // Оба тега имеют одинаковое имя (первичный ключ)
        expect(tag1.name, equals(tag2.name));
      });

      test('разные имена должны создавать разные теги', () {
        final tag1 = TagModel(
          'тег_1',
          '#FF5722',
          DateTime.now(),
          0,
        );
        
        final tag2 = TagModel(
          'тег_2',
          '#FF5722',
          DateTime.now(),
          0,
        );

        expect(tag1.name, isNot(equals(tag2.name)));
      });
    });

    group('граничные случаи', () {
      test('должна работать с пустым именем', () {
        final emptyNameTag = TagModel(
          '',
          '#607D8B',
          DateTime.now(),
          0,
        );

        expect(emptyNameTag.name, isEmpty);
      });

      test('должна работать с пустым цветом', () {
        final emptyColorTag = TagModel(
          'пустой_цвет',
          '',
          DateTime.now(),
          0,
        );

        expect(emptyColorTag.color, isEmpty);
      });

      test('должна работать с пустым описанием', () {
        final emptyDescTag = TagModel(
          'пустое_описание',
          '#795548',
          DateTime.now(),
          0,
          description: '',
        );

        expect(emptyDescTag.description, isEmpty);
      });

      test('должна работать с отрицательным счетчиком использования', () {
        final negativeUsageTag = TagModel(
          'отрицательный',
          '#9E9E9E',
          DateTime.now(),
          -5,
        );

        expect(negativeUsageTag.usageCount, equals(-5));
      });
    });
  });
}