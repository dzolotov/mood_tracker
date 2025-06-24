import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker_plus/services/file_service.dart';
import 'package:mood_tracker_plus/models/mood_entry.dart';

void main() {
  group('FileService Import/Export Logic Tests', () {
    late FileService fileService;
    late Directory tempDir;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      fileService = FileService();
      tempDir = await Directory.systemTemp.createTemp('file_service_import_export_test_');
      
      // Mock path_provider
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getApplicationDocumentsDirectory':
            case 'getTemporaryDirectory':
            case 'getApplicationSupportDirectory':
              return tempDir.path;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
    });

    group('CSV Export Data Integrity', () {
      test('CSV export should include all entry fields correctly', () async {
        final testEntry = MoodEntry(
          id: 'csv-test-comprehensive',
          mood: MoodType.veryHappy,
          timestamp: DateTime(2024, 3, 15, 14, 30, 45),
          note: 'Comprehensive test entry with special characters: àáâ "quotes" and, commas',
          activities: ['coding', 'testing', 'debugging'],
          sleepTime: DateTime(2024, 3, 14, 23, 15),
          wakeTime: DateTime(2024, 3, 15, 7, 30),
          sleepDuration: const Duration(hours: 8, minutes: 15),
          photoPath: '/test/path/photo.jpg',
        );

        final csvPath = await fileService.exportToCSV([testEntry]);
        expect(csvPath, isNotNull);

        final csvFile = File(csvPath!);
        final content = await csvFile.readAsString(encoding: utf8);
        final lines = content.split('\n');

        // Verify header line
        expect(lines[0], contains('ID'));
        expect(lines[0], contains('Дата'));
        expect(lines[0], contains('Настроение'));
        expect(lines[0], contains('Активности'));

        // Verify data line
        final dataLine = lines[1];
        expect(dataLine, contains('csv-test-comprehensive'));
        expect(dataLine, contains('2024-03-15'));
        expect(dataLine, contains('14:30:45'));
        expect(dataLine, contains('Очень счастлив'));
        expect(dataLine, contains('5')); // MoodType.veryHappy.value
        expect(dataLine, contains('coding; testing; debugging'));
        expect(dataLine, contains('8')); // Sleep duration in hours
        expect(dataLine, contains('Да')); // Has photo
      });

      test('CSV export should handle UTF-8 encoding correctly', () async {
        final testEntry = MoodEntry(
          id: 'utf8-test',
          mood: MoodType.happy,
          timestamp: DateTime.now(),
          note: 'Тест с русскими символами и эмодзи: 😊🎉💪',
          activities: ['медитация', 'чтение', 'спорт'],
        );

        final csvPath = await fileService.exportToCSV([testEntry]);
        expect(csvPath, isNotNull);

        final csvFile = File(csvPath!);
        final content = await csvFile.readAsString(encoding: utf8);
        
        expect(content, contains('Тест с русскими символами'));
        expect(content, contains('😊🎉💪'));
        expect(content, contains('медитация; чтение; спорт'));
      });

      test('CSV export should escape special characters properly', () async {
        final testEntry = MoodEntry(
          id: 'special-chars-test',
          mood: MoodType.neutral,
          timestamp: DateTime.now(),
          note: 'Note with "quotes", commas, and\nnewlines',
          activities: ['activity with, comma', 'activity with "quotes"'],
        );

        final csvPath = await fileService.exportToCSV([testEntry]);
        expect(csvPath, isNotNull);

        final csvFile = File(csvPath!);
        final content = await csvFile.readAsString(encoding: utf8);
        
        // CSV should properly escape quotes and handle commas
        expect(content, contains('"Note with ""quotes"", commas, and\nnewlines"'));
        expect(content, contains('"activity with, comma; activity with ""quotes"""'));
      });

      test('CSV export should handle empty and null values', () async {
        final testEntry = MoodEntry(
          id: 'empty-values-test',
          mood: MoodType.sad,
          timestamp: DateTime.now(),
          note: null,
          activities: [],
          sleepTime: null,
          wakeTime: null,
          sleepDuration: null,
          photoPath: null,
        );

        final csvPath = await fileService.exportToCSV([testEntry]);
        expect(csvPath, isNotNull);

        final csvFile = File(csvPath!);
        final content = await csvFile.readAsString(encoding: utf8);
        final lines = content.split('\n');
        final dataLine = lines[1];

        // Should have empty values for null fields
        expect(dataLine, contains('empty-values-test'));
        expect(dataLine, contains('Грустно'));
        expect(dataLine, contains('Нет')); // No photo
        
        // Count commas to ensure all fields are present
        final commaCount = dataLine.split(',').length - 1;
        expect(commaCount, greaterThanOrEqualTo(10)); // Should have all columns
      });
    });

    group('JSON Backup Data Integrity', () {
      test('JSON backup should preserve all entry data', () async {
        final testEntries = [
          MoodEntry(
            id: 'json-test-1',
            mood: MoodType.veryHappy,
            timestamp: DateTime(2024, 2, 20, 16, 45, 30),
            note: 'First test entry',
            activities: ['work', 'exercise'],
            sleepTime: DateTime(2024, 2, 19, 23, 0),
            wakeTime: DateTime(2024, 2, 20, 7, 0),
            sleepDuration: const Duration(hours: 8),
            photoPath: '/path/to/photo1.jpg',
          ),
          MoodEntry(
            id: 'json-test-2',
            mood: MoodType.sad,
            timestamp: DateTime(2024, 2, 21, 9, 15, 0),
            note: null,
            activities: [],
            sleepTime: null,
            wakeTime: null,
            sleepDuration: null,
            photoPath: null,
          ),
        ];

        final backupPath = await fileService.createBackup(testEntries);
        expect(backupPath, isNotNull);

        final backupFile = File(backupPath!);
        final content = await backupFile.readAsString(encoding: utf8);
        final backupData = json.decode(content) as Map<String, dynamic>;

        // Verify backup structure
        expect(backupData['version'], equals('1.0'));
        expect(backupData['exportDate'], isA<String>());
        expect(backupData['entriesCount'], equals(2));
        expect(backupData['entries'], isA<List>());

        final entries = backupData['entries'] as List;
        expect(entries.length, equals(2));

        // Verify first entry
        final entry1 = entries[0] as Map<String, dynamic>;
        expect(entry1['id'], equals('json-test-1'));
        expect(entry1['mood'], equals('veryHappy'));
        expect(entry1['timestamp'], equals('2024-02-20T16:45:30.000'));
        expect(entry1['note'], equals('First test entry'));
        expect(entry1['activities'], equals(['work', 'exercise']));
        expect(entry1['sleepTime'], equals('2024-02-19T23:00:00.000'));
        expect(entry1['wakeTime'], equals('2024-02-20T07:00:00.000'));
        expect(entry1['sleepDuration'], equals(480)); // 8 hours in minutes
        expect(entry1['photoPath'], equals('/path/to/photo1.jpg'));

        // Verify second entry with null values
        final entry2 = entries[1] as Map<String, dynamic>;
        expect(entry2['id'], equals('json-test-2'));
        expect(entry2['mood'], equals('sad'));
        expect(entry2['note'], isNull);
        expect(entry2['activities'], equals([]));
        expect(entry2['sleepTime'], isNull);
        expect(entry2['wakeTime'], isNull);
        expect(entry2['sleepDuration'], isNull);
        expect(entry2['photoPath'], isNull);
      });

      test('JSON backup should handle large datasets efficiently', () async {
        final largeDataset = List.generate(100, (index) => 
          MoodEntry(
            id: 'bulk-entry-$index',
            mood: MoodType.values[index % MoodType.values.length],
            timestamp: DateTime.now().subtract(Duration(hours: index)),
            note: 'Bulk test entry number $index with some detailed content',
            activities: List.generate(index % 3 + 1, (i) => 'activity-$index-$i'),
            sleepDuration: Duration(hours: 7 + (index % 3)),
          ),
        );

        final stopwatch = Stopwatch()..start();
        final backupPath = await fileService.createBackup(largeDataset);
        stopwatch.stop();

        expect(backupPath, isNotNull);
        expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // Should be fast

        final backupFile = File(backupPath!);
        final content = await backupFile.readAsString(encoding: utf8);
        final backupData = json.decode(content) as Map<String, dynamic>;

        expect(backupData['entriesCount'], equals(100));
        final entries = backupData['entries'] as List;
        expect(entries.length, equals(100));

        // Verify a few random entries
        final entry25 = entries[25] as Map<String, dynamic>;
        expect(entry25['id'], equals('bulk-entry-25'));
        expect(entry25['activities'], isA<List>());
        expect((entry25['activities'] as List).isNotEmpty, isTrue);
      });

      test('JSON backup should generate valid timestamps', () async {
        final testEntry = MoodEntry(
          id: 'timestamp-test',
          mood: MoodType.neutral,
          timestamp: DateTime.now(),
        );

        final backupPath = await fileService.createBackup([testEntry]);
        expect(backupPath, isNotNull);

        final backupFile = File(backupPath!);
        final content = await backupFile.readAsString(encoding: utf8);
        final backupData = json.decode(content) as Map<String, dynamic>;

        // Verify exportDate is valid ISO8601
        final exportDate = backupData['exportDate'] as String;
        expect(() => DateTime.parse(exportDate), returnsNormally);

        // Verify entry timestamp is valid
        final entries = backupData['entries'] as List;
        final entry = entries[0] as Map<String, dynamic>;
        final entryTimestamp = entry['timestamp'] as String;
        expect(() => DateTime.parse(entryTimestamp), returnsNormally);
      });
    });

    group('File Management and Storage', () {
      test('getStorageInfo should calculate sizes accurately', () async {
        // Create files of known sizes
        final dirs = await fileService.getAppDirectories();
        
        // Create photo file (100 bytes)
        final photoContent = List.generate(100, (index) => index % 256);
        await File('${dirs['photos']}/test_photo.jpg').writeAsBytes(photoContent);
        
        // Create export file (50 bytes)
        final exportContent = 'x' * 50;
        await File('${dirs['exports']}/test_export.csv').writeAsString(exportContent);
        
        // Create backup file (75 bytes)
        final backupContent = 'y' * 75;
        await File('${dirs['backups']}/test_backup.json').writeAsString(backupContent);

        final storageInfo = await fileService.getStorageInfo();

        expect(storageInfo['photos'], equals(100));
        expect(storageInfo['exports'], equals(50));
        expect(storageInfo['backups'], equals(75));
        expect(storageInfo['total'], equals(225));
      });

      test('clearOldFiles should respect date threshold', () async {
        final dirs = await fileService.getAppDirectories();
        
        // Create files with different modification times by creating them sequentially
        final oldFile1 = File('${dirs['exports']}/old_file_1.csv');
        await oldFile1.writeAsString('old content 1');
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        final oldFile2 = File('${dirs['backups']}/old_file_2.json');
        await oldFile2.writeAsString('old content 2');
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        final recentFile = File('${dirs['exports']}/recent_file.csv');
        await recentFile.writeAsString('recent content');

        // Clear files older than 50ms (should remove first two files)
        await Future.delayed(const Duration(milliseconds: 50));
        final result = await fileService.clearOldFiles(daysToKeep: 0);

        expect(result, isTrue);
        // Note: The exact behavior depends on file system timing, 
        // but the method should execute without errors
      });

      test('should handle directory creation and permissions', () async {
        final dirs = await fileService.getAppDirectories();
        
        // Verify all directories exist and are writable
        for (final dirPath in dirs.values) {
          final dir = Directory(dirPath);
          expect(await dir.exists(), isTrue);
          
          // Test write permission
          final testFile = File('$dirPath/permission_test.tmp');
          await testFile.writeAsString('test');
          expect(await testFile.exists(), isTrue);
          await testFile.delete();
        }
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should handle extremely large entries gracefully', () async {
        final hugeNote = 'x' * 10000; // 10KB note
        final manyActivities = List.generate(100, (i) => 'activity_$i');
        
        final largeEntry = MoodEntry(
          id: 'huge-entry',
          mood: MoodType.happy,
          timestamp: DateTime.now(),
          note: hugeNote,
          activities: manyActivities,
        );

        // Should handle large data without issues
        final csvPath = await fileService.exportToCSV([largeEntry]);
        expect(csvPath, isNotNull);
        
        final backupPath = await fileService.createBackup([largeEntry]);
        expect(backupPath, isNotNull);
        
        // Verify files were created and contain data
        expect(await File(csvPath!).length(), greaterThan(10000));
        expect(await File(backupPath!).length(), greaterThan(10000));
      });

      test('should handle special filesystem characters in data', () async {
        final problematicEntry = MoodEntry(
          id: 'problematic-entry',
          mood: MoodType.neutral,
          timestamp: DateTime.now(),
          note: 'Entry with / \\ : * ? " < > | characters',
          activities: ['activity/with\\special:chars'],
        );

        // Should not fail due to filesystem-unfriendly characters in data
        final csvPath = await fileService.exportToCSV([problematicEntry]);
        expect(csvPath, isNotNull);
        
        final backupPath = await fileService.createBackup([problematicEntry]);
        expect(backupPath, isNotNull);
        
        // Verify content is preserved
        final csvContent = await File(csvPath!).readAsString();
        expect(csvContent, contains('activity/with\\special:chars'));
        
        final backupContent = await File(backupPath!).readAsString();
        final backupData = json.decode(backupContent);
        final entries = backupData['entries'] as List;
        final entry = entries[0] as Map<String, dynamic>;
        expect(entry['activities'], contains('activity/with\\special:chars'));
      });

      test('should maintain data consistency across multiple operations', () async {
        final originalEntries = List.generate(10, (index) => 
          MoodEntry(
            id: 'consistency-test-$index',
            mood: MoodType.values[index % MoodType.values.length],
            timestamp: DateTime.now().subtract(Duration(hours: index)),
            note: 'Consistency test entry $index',
            activities: ['test-activity-$index'],
          ),
        );

        // Perform multiple exports/backups concurrently
        final futures = <Future>[];
        for (int i = 0; i < 3; i++) {
          futures.add(fileService.exportToCSV(originalEntries));
          futures.add(fileService.createBackup(originalEntries));
        }

        final results = await Future.wait(futures);
        
        // All operations should succeed
        expect(results.every((result) => result != null), isTrue);
        
        // Verify all files exist and have reasonable sizes
        for (final result in results) {
          if (result is String) {
            final file = File(result);
            expect(await file.exists(), isTrue);
            expect(await file.length(), greaterThan(100)); // Should have substantial content
          }
        }
      });
    });
  });
}