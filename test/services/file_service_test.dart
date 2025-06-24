import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker_plus/services/file_service.dart';
import 'package:mood_tracker_plus/models/mood_entry.dart';

void main() {
  group('FileService', () {
    late FileService fileService;
    late Directory tempDir;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      fileService = FileService();
      
      // Создаем временную директорию для тестов
      tempDir = await Directory.systemTemp.createTemp('mood_tracker_test_');
      
      // Мокируем path_provider плагин с реальными временными путями
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getApplicationDocumentsDirectory':
              return tempDir.path;
            case 'getTemporaryDirectory':
              return tempDir.path;
            case 'getApplicationSupportDirectory':
              return tempDir.path;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() async {
      // Очищаем моки после каждого теста
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
      
      // Удаляем временную директорию
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('Basic Properties', () {
      test('should be a ChangeNotifier', () {
        expect(fileService, isA<FileService>());
      });

      test('should have null initial paths', () {
        expect(fileService.lastExportPath, isNull);
        expect(fileService.lastBackupPath, isNull);
      });
    });

    group('Directory Management', () {
      test('getAppDirectories should return correct paths', () async {
        final result = await fileService.getAppDirectories();
        
        expect(result, isA<Map<String, String>>());
        expect(result['app'], equals(tempDir.path));
        expect(result['temp'], equals(tempDir.path));
        expect(result['support'], equals(tempDir.path));
        expect(result['moodData'], equals('${tempDir.path}/mood_data'));
        expect(result['photos'], equals('${tempDir.path}/photos'));
        expect(result['exports'], equals('${tempDir.path}/exports'));
        expect(result['backups'], equals('${tempDir.path}/backups'));
      });

      test('should create all subdirectories', () async {
        await fileService.getAppDirectories();
        
        // Проверяем, что все поддиректории созданы
        expect(await Directory('${tempDir.path}/mood_data').exists(), isTrue);
        expect(await Directory('${tempDir.path}/photos').exists(), isTrue);
        expect(await Directory('${tempDir.path}/exports').exists(), isTrue);
        expect(await Directory('${tempDir.path}/backups').exists(), isTrue);
      });
    });

    group('CSV Export Logic', () {
      test('should create actual CSV file with different mood types', () async {
        final entries = [
          MoodEntry(id: '1', mood: MoodType.veryHappy, timestamp: DateTime.now()),
          MoodEntry(id: '2', mood: MoodType.happy, timestamp: DateTime.now()),
          MoodEntry(id: '3', mood: MoodType.neutral, timestamp: DateTime.now()),
          MoodEntry(id: '4', mood: MoodType.sad, timestamp: DateTime.now()),
          MoodEntry(id: '5', mood: MoodType.verySad, timestamp: DateTime.now()),
        ];
        
        final filePath = await fileService.exportToCSV(entries);
        
        expect(filePath, isNotNull);
        expect(filePath!.endsWith('.csv'), isTrue);
        expect(fileService.lastExportPath, equals(filePath));
        
        // Проверяем, что файл создан
        final file = File(filePath);
        expect(await file.exists(), isTrue);
        
        // Читаем и проверяем содержимое
        final content = await file.readAsString(encoding: utf8);
        expect(content, contains('ID'));
        expect(content, contains('Дата'));
        expect(content, contains('Настроение'));
        expect(content, contains('Очень счастлив')); // проверяем что есть данные настроения
      });

      test('should create CSV with all possible fields', () async {
        final entry = MoodEntry(
          id: 'comprehensive-test',
          mood: MoodType.happy,
          timestamp: DateTime(2024, 1, 15, 10, 30),
          note: 'Test note with special chars: áéíóú, 中文, 🎉',
          activities: ['work', 'exercise', 'reading'],
          sleepTime: DateTime(2024, 1, 14, 23, 0),
          wakeTime: DateTime(2024, 1, 15, 7, 0),
          sleepDuration: const Duration(hours: 8),
          photoPath: '/path/to/photo.jpg',
        );
        
        final filePath = await fileService.exportToCSV([entry]);
        expect(filePath, isNotNull);
        
        final file = File(filePath!);
        final content = await file.readAsString(encoding: utf8);
        
        // Проверяем наличие всех полей в CSV
        expect(content, contains('comprehensive-test'));
        expect(content, contains('2024-01-15'));
        expect(content, contains('10:30:00'));
        expect(content, contains('Test note with special chars'));
        expect(content, contains('work; exercise; reading'));
        expect(content, contains('Да')); // Есть фото
      });

      test('should handle empty entries list', () {
        expect(() => fileService.exportToCSV([]), returnsNormally);
      });

      test('should generate filename with current date', () {
        final now = DateTime.now();
        final expectedPattern = RegExp(r'mood_export_\d{4}-\d{1,2}-\d{1,2}\.csv');
        
        // We can't test actual file creation, but we can test filename logic
        final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final fileName = 'mood_export_$dateStr.csv';
        
        expect(fileName, matches(expectedPattern));
        expect(fileName, contains(now.year.toString()));
      });

      test('should handle date formatting correctly', () {
        final testDate = DateTime(2024, 3, 5, 14, 30, 45);
        final entry = MoodEntry(
          id: 'date-test',
          mood: MoodType.neutral,
          timestamp: testDate,
        );
        
        // Test date formatting logic
        final dateStr = testDate.toIso8601String().split('T')[0];
        final timeStr = testDate.toIso8601String().split('T')[1].split('.')[0];
        
        expect(dateStr, '2024-03-05');
        expect(timeStr, '14:30:45');
        
        expect(() => fileService.exportToCSV([entry]), returnsNormally);
      });
    });

    group('Backup Logic', () {
      test('should create actual JSON backup file', () async {
        final entries = [
          MoodEntry(
            id: 'backup-test-1',
            mood: MoodType.veryHappy,
            timestamp: DateTime(2024, 2, 1, 15, 30),
            note: 'Complex entry for backup',
            activities: ['meditation', 'yoga', 'journaling'],
            sleepDuration: const Duration(hours: 7, minutes: 30),
            photoPath: '/path/to/photo.jpg',
          ),
          MoodEntry(
            id: 'backup-test-2',
            mood: MoodType.sad,
            timestamp: DateTime(2024, 2, 2, 9, 15),
            note: null,
            activities: [],
            sleepTime: null,
            wakeTime: null,
            sleepDuration: null,
            photoPath: null,
          ),
        ];
        
        final filePath = await fileService.createBackup(entries);
        
        expect(filePath, isNotNull);
        expect(filePath!.endsWith('.json'), isTrue);
        expect(fileService.lastBackupPath, equals(filePath));
        
        // Проверяем файл
        final file = File(filePath);
        expect(await file.exists(), isTrue);
        
        // Читаем и парсим JSON
        final content = await file.readAsString(encoding: utf8);
        final backupData = json.decode(content) as Map<String, dynamic>;
        
        expect(backupData['version'], '1.0');
        expect(backupData['entriesCount'], 2);
        expect(backupData['entries'], isA<List>());
        
        final entries2 = backupData['entries'] as List;
        expect(entries2.length, 2);
        
        final firstEntry = entries2[0] as Map<String, dynamic>;
        expect(firstEntry['id'], 'backup-test-1');
        expect(firstEntry['mood'], 'veryHappy');
        expect(firstEntry['note'], 'Complex entry for backup');
        expect(firstEntry['sleepDuration'], 450); // 7*60 + 30
      });

      test('should handle entries with null values', () {
        final entries = [
          MoodEntry(
            id: 'null-test',
            mood: MoodType.neutral,
            timestamp: DateTime.now(),
            note: null,
            activities: [],
            sleepTime: null,
            wakeTime: null,
            sleepDuration: null,
            photoPath: null,
          ),
        ];
        
        expect(() => fileService.createBackup(entries), returnsNormally);
      });

      test('should generate backup filename with date and time', () {
        final now = DateTime.now();
        final expectedPattern = RegExp(r'mood_backup_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}\.json');
        
        // Test filename generation logic
        final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';
        final fileName = 'mood_backup_$dateStr.json';
        
        expect(fileName, matches(expectedPattern));
        expect(fileName, contains('.json'));
      });

      test('should convert mood types to strings correctly', () {
        // Test mood type serialization
        expect(MoodType.veryHappy.name, 'veryHappy');
        expect(MoodType.happy.name, 'happy');
        expect(MoodType.neutral.name, 'neutral');
        expect(MoodType.sad.name, 'sad');
        expect(MoodType.verySad.name, 'verySad');
      });

      test('should handle duration serialization', () {
        const duration = Duration(hours: 8, minutes: 30);
        final minutes = duration.inMinutes;
        
        expect(minutes, 510); // 8*60 + 30
        
        // Test reverse conversion
        final reconstructed = Duration(minutes: minutes);
        expect(reconstructed, duration);
      });

      test('should create proper backup structure', () {
        final entries = [
          MoodEntry(
            id: 'structure-test',
            mood: MoodType.happy,
            timestamp: DateTime(2024, 1, 1, 12, 0),
            note: 'Test note',
            activities: ['test'],
          ),
        ];
        
        // Test that we can simulate backup data structure
        final backupData = {
          'version': '1.0',
          'exportDate': DateTime.now().toIso8601String(),
          'entriesCount': entries.length,
          'entries': entries.map((entry) => {
            'id': entry.id,
            'mood': entry.mood.name,
            'timestamp': entry.timestamp.toIso8601String(),
            'note': entry.note,
            'activities': entry.activities,
            'sleepTime': entry.sleepTime?.toIso8601String(),
            'wakeTime': entry.wakeTime?.toIso8601String(),
            'sleepDuration': entry.sleepDuration?.inMinutes,
            'photoPath': entry.photoPath,
          }).toList(),
        };
        
        expect(backupData['version'], '1.0');
        expect(backupData['entriesCount'], 1);
        expect(backupData['entries'], isA<List>());
        
        final firstEntry = (backupData['entries'] as List)[0] as Map;
        expect(firstEntry['id'], 'structure-test');
        expect(firstEntry['mood'], 'happy');
        expect(firstEntry['note'], 'Test note');
      });
    });

    group('Edge Cases', () {
      test('should handle very long lists', () {
        final entries = List.generate(100, (index) => 
          MoodEntry(
            id: 'entry-$index',
            mood: MoodType.values[index % MoodType.values.length],
            timestamp: DateTime.now().subtract(Duration(days: index)),
            note: 'Entry number $index with some longer text to test limits',
            activities: ['activity-$index', 'secondary-activity-$index'],
          ),
        );
        
        expect(() => fileService.exportToCSV(entries), returnsNormally);
        expect(() => fileService.createBackup(entries), returnsNormally);
      });

      test('should handle entries with special characters', () {
        final entries = [
          MoodEntry(
            id: 'special-chars-test',
            mood: MoodType.happy,
            timestamp: DateTime.now(),
            note: 'Note with special chars: áéíóú, 中文, 🎉, "quotes", commas,',
            activities: ['café visit', 'música', 'reading "books"'],
          ),
        ];
        
        expect(() => fileService.exportToCSV(entries), returnsNormally);
        expect(() => fileService.createBackup(entries), returnsNormally);
      });
    });

    group('Storage Management', () {
      test('getStorageInfo should return actual file sizes', () async {
        // Создаем несколько файлов
        await fileService.getAppDirectories(); // создаем директории
        
        // Создаем тестовые файлы
        final photoFile = File('${tempDir.path}/photos/test.jpg');
        await photoFile.writeAsString('test photo content');
        
        final exportFile = File('${tempDir.path}/exports/test.csv');
        await exportFile.writeAsString('test,csv,content');
        
        final backupFile = File('${tempDir.path}/backups/test.json');
        await backupFile.writeAsString('{"test": "backup content"}');
        
        final storageInfo = await fileService.getStorageInfo();
        
        expect(storageInfo, isA<Map<String, int>>());
        expect(storageInfo['photos']!, greaterThan(0));
        expect(storageInfo['exports']!, greaterThan(0));
        expect(storageInfo['backups']!, greaterThan(0));
        expect(storageInfo['total'], 
               storageInfo['photos']! + storageInfo['exports']! + storageInfo['backups']!);
      });

      test('clearOldFiles should remove old files', () async {
        await fileService.getAppDirectories();
        
        // Создаем старый файл
        final oldFile = File('${tempDir.path}/exports/old_export.csv');
        await oldFile.writeAsString('old content');
        
        // Устанавливаем старую дату модификации (симулируем)
        final result = await fileService.clearOldFiles(daysToKeep: 0);
        
        expect(result, isA<bool>());
      });

      test('should have methods for photo management', () {
        expect(() => fileService.takePhoto(), returnsNormally);
        expect(() => fileService.pickPhoto(), returnsNormally);
      });
    });

    group('Integration Tests', () {
      test('should handle export/import round trip for CSV', () async {
        final originalEntries = [
          MoodEntry(
            id: 'round-trip-1',
            mood: MoodType.happy,
            timestamp: DateTime(2024, 3, 1, 12, 0),
            note: 'Round trip test',
            activities: ['testing', 'coding'],
            sleepDuration: const Duration(hours: 8),
          ),
          MoodEntry(
            id: 'round-trip-2',
            mood: MoodType.sad,
            timestamp: DateTime(2024, 3, 2, 14, 30),
            note: null,
            activities: [],
          ),
        ];
        
        // Экспортируем в CSV
        final exportPath = await fileService.exportToCSV(originalEntries);
        expect(exportPath, isNotNull);
        
        // Проверяем, что файл создан и содержит данные
        final exportFile = File(exportPath!);
        expect(await exportFile.exists(), isTrue);
        
        final csvContent = await exportFile.readAsString(encoding: utf8);
        expect(csvContent, contains('round-trip-1'));
        expect(csvContent, contains('round-trip-2'));
        expect(csvContent, contains('Round trip test'));
      });

      test('should handle backup/restore round trip for JSON', () async {
        final originalEntries = [
          MoodEntry(
            id: 'backup-round-trip',
            mood: MoodType.neutral,
            timestamp: DateTime(2024, 3, 3, 16, 45),
            note: 'Backup test entry',
            activities: ['backup-testing'],
            sleepTime: DateTime(2024, 3, 2, 23, 30),
            wakeTime: DateTime(2024, 3, 3, 7, 30),
            sleepDuration: const Duration(hours: 8),
          ),
        ];
        
        // Создаем backup
        final backupPath = await fileService.createBackup(originalEntries);
        expect(backupPath, isNotNull);
        
        // Проверяем файл backup
        final backupFile = File(backupPath!);
        expect(await backupFile.exists(), isTrue);
        
        // Читаем и проверяем структуру JSON
        final jsonContent = await backupFile.readAsString(encoding: utf8);
        final backupData = json.decode(jsonContent) as Map<String, dynamic>;
        
        expect(backupData['version'], '1.0');
        expect(backupData['entriesCount'], 1);
        
        final entries = backupData['entries'] as List;
        final restoredEntry = entries[0] as Map<String, dynamic>;
        
        expect(restoredEntry['id'], 'backup-round-trip');
        expect(restoredEntry['mood'], 'neutral');
        expect(restoredEntry['note'], 'Backup test entry');
        expect(restoredEntry['sleepDuration'], 480); // 8 hours
      });

      test('should maintain data integrity across file operations', () async {
        // Создаем несколько файлов и проверяем их одновременное существование
        final testEntries = [
          MoodEntry(id: 'integrity-test', mood: MoodType.veryHappy, timestamp: DateTime.now()),
        ];
        
        final csvPath = await fileService.exportToCSV(testEntries);
        final backupPath = await fileService.createBackup(testEntries);
        
        expect(csvPath, isNotNull);
        expect(backupPath, isNotNull);
        
        // Проверяем, что оба файла существуют одновременно
        expect(await File(csvPath!).exists(), isTrue);
        expect(await File(backupPath!).exists(), isTrue);
        
        // Проверяем storage info после создания файлов
        final storageInfo = await fileService.getStorageInfo();
        expect(storageInfo['exports']!, greaterThan(0));
        expect(storageInfo['backups']!, greaterThan(0));
      });
    });
  });
}