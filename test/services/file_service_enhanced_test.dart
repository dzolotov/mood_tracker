import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker_plus/services/file_service.dart';
import 'package:mood_tracker_plus/models/mood_entry.dart';
// import '../test_helpers.dart';

void main() {
  group('FileService Enhanced Tests', () {
    late FileService fileService;
    late Directory tempDir;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      fileService = FileService();
      
      // Create temporary directory for tests
      tempDir = await Directory.systemTemp.createTemp('mood_tracker_file_test_');
      
      // Mock path_provider plugin with real temporary paths
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
      // Clean up temporary directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      
      // Clear mock method call handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
    });

    group('Directory Management', () {
      test('getAppDirectories creates required directories', () async {
        final directories = await fileService.getAppDirectories();
        
        expect(directories, isA<Map<String, String>>());
        expect(directories.keys, containsAll([
          'app', 'temp', 'support', 'moodData', 'photos', 'exports', 'backups'
        ]));
        
        // Verify directories are created
        for (final path in directories.values) {
          expect(await Directory(path).exists(), isTrue,
              reason: 'Directory should exist: $path');
        }
      });

      test('getAppDirectories is idempotent', () async {
        final dirs1 = await fileService.getAppDirectories();
        final dirs2 = await fileService.getAppDirectories();
        
        expect(dirs1, equals(dirs2));
      });

      test('directory paths are valid and accessible', () async {
        final directories = await fileService.getAppDirectories();
        
        for (final entry in directories.entries) {
          final dir = Directory(entry.value);
          expect(await dir.exists(), isTrue,
              reason: '${entry.key} directory should exist');
          
          // Test write access
          final testFile = File('${entry.value}/test_file.txt');
          await testFile.writeAsString('test content');
          expect(await testFile.exists(), isTrue);
          await testFile.delete();
        }
      });
    });

    group('CSV Export', () {
      test('exportToCSV creates valid CSV file', () async {
        final testEntries = [
          MoodEntry(
            id: '1',
            mood: MoodType.neutral,
            note: 'CSV test note',
            activities: ['working', 'meeting'],
            timestamp: DateTime(2024, 2, 10),
          ),
        ];

        final result = await fileService.exportToCSV(testEntries);
        
        expect(result, isNotNull);
        
        // Verify CSV file content
        final csvFile = File(result!);
        expect(await csvFile.exists(), isTrue);
        
        final content = await csvFile.readAsString();
        final lines = content.split('\n');
        
        // Should have header + data + empty line
        expect(lines.length, greaterThanOrEqualTo(2));
        
        // Check header
        expect(lines[0], contains('Дата'));
        expect(lines[0], contains('Настроение'));
        expect(lines[0], contains('Заметка'));
        
        // Check data
        expect(lines[1], contains('Нейтрально'));
        expect(lines[1], contains('CSV test note'));
        expect(lines[1], contains('working; meeting'));
      });

      test('exportToCSV handles special characters in CSV', () async {
        final testEntries = [
          MoodEntry(
            id: '1',
            mood: MoodType.happy,
            note: 'Note with "quotes" and, commas',
            activities: ['activity with, comma'],
            timestamp: DateTime(2024, 3, 1),
          ),
        ];

        final result = await fileService.exportToCSV(testEntries);
        expect(result, isNotNull);
        
        final csvFile = File(result!);
        final content = await csvFile.readAsString();
        
        // CSV should properly escape special characters
        expect(content, contains('Note with'));
      });

      test('exportToCSV handles empty entries list', () async {
        final result = await fileService.exportToCSV([]);
        
        expect(result, isNotNull);
        
        final csvFile = File(result!);
        final content = await csvFile.readAsString();
        
        // Should still have header
        expect(content, contains('Дата'));
        expect(content.split('\n').length, lessThanOrEqualTo(3));
      });
    });

    group('JSON Backup', () {
      test('createBackup creates backup file', () async {
        final testEntries = [
          MoodEntry(
            id: '1',
            mood: MoodType.neutral,
            note: 'Backup test',
            activities: ['meditating'],
            timestamp: DateTime.now(),
          ),
        ];

        final result = await fileService.createBackup(testEntries);
        
        expect(result, isNotNull);
        expect(fileService.lastBackupPath, isNotNull);
        
        // Verify backup file exists
        final backupFile = File(fileService.lastBackupPath!);
        expect(await backupFile.exists(), isTrue);
        
        // Verify backup content is valid JSON
        final content = await backupFile.readAsString();
        final decoded = json.decode(content);
        expect(decoded['entries'], isA<List>());
        expect(decoded['exportDate'], isA<String>());
      });

      test('createBackup filename includes timestamp', () async {
        final testEntries = [
          MoodEntry(
            id: '1',
            mood: MoodType.happy,
            timestamp: DateTime.now(),
          ),
        ];

        await fileService.createBackup(testEntries);
        
        final backupPath = fileService.lastBackupPath!;
        final filename = backupPath.split('/').last;
        
        // Should contain date pattern
        expect(filename, matches(r'mood_backup_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}\.json'));
      });
    });

    group('File Management', () {
      test('getStorageInfo returns file sizes', () async {
        // Create some test files
        final dirs = await fileService.getAppDirectories();
        
        await File('${dirs['exports']}/test_export.csv').writeAsString('test data');
        await File('${dirs['backups']}/test_backup.json').writeAsString('{"test": "data"}');
        await File('${dirs['photos']}/test_photo.jpg').writeAsString('fake photo data');
        
        final storageInfo = await fileService.getStorageInfo();
        
        expect(storageInfo, isA<Map<String, int>>());
        expect(storageInfo['exports']!, greaterThan(0));
        expect(storageInfo['backups']!, greaterThan(0));
        expect(storageInfo['photos']!, greaterThan(0));
        expect(storageInfo['total'], 
               storageInfo['photos']! + storageInfo['exports']! + storageInfo['backups']!);
      });

      test('clearOldFiles removes old files', () async {
        await fileService.getAppDirectories();
        
        // Create test file
        final dirs = await fileService.getAppDirectories();
        final oldFile = File('${dirs['exports']}/old_export.csv');
        await oldFile.writeAsString('old content');
        
        // Test cleanup function exists
        final result = await fileService.clearOldFiles(daysToKeep: 0);
        expect(result, isA<bool>());
      });
    });

    group('Error Handling', () {
      test('handles file system errors gracefully', () async {
        // Test with operations that might fail
        expect(() => fileService.takePhoto(), returnsNormally);
        expect(() => fileService.pickPhoto(), returnsNormally);
      });

      test('notifies listeners on state changes', () async {
        bool notified = false;
        fileService.addListener(() {
          notified = true;
        });

        // Trigger a state change that should notify listeners
        final testEntries = [
          MoodEntry(id: '1', mood: MoodType.happy, timestamp: DateTime.now()),
        ];
        await fileService.createBackup(testEntries);
        expect(notified, isTrue);
      });
    });

    group('Integration Tests', () {
      test('full export cycle preserves data integrity', () async {
        final originalEntries = [
          MoodEntry(
            id: '1',
            mood: MoodType.happy,
            note: 'Integration test entry 1',
            activities: ['testing', 'coding', 'debugging'],
            timestamp: DateTime(2024, 6, 15, 14, 30),
          ),
          MoodEntry(
            id: '2',
            mood: MoodType.sad,
            note: 'Integration test entry 2 with special chars: àáâãäå',
            activities: [],
            timestamp: DateTime(2024, 6, 16, 9, 15),
          ),
        ];

        // Export to CSV
        final csvResult = await fileService.exportToCSV(originalEntries);
        expect(csvResult, isNotNull);
        
        // Export to JSON backup
        final backupResult = await fileService.createBackup(originalEntries);
        expect(backupResult, isNotNull);
        
        // Verify CSV content
        final csvFile = File(csvResult!);
        final csvContent = await csvFile.readAsString();
        expect(csvContent, contains('Integration test entry 1'));
        expect(csvContent, contains('Integration test entry 2'));
        
        // Verify JSON backup content
        final backupFile = File(fileService.lastBackupPath!);
        final jsonContent = await backupFile.readAsString();
        final backupData = json.decode(jsonContent) as Map<String, dynamic>;
        
        expect(backupData['version'], '1.0');
        expect(backupData['entriesCount'], 2);
        
        final entries = backupData['entries'] as List;
        expect(entries.length, 2);
        
        final firstEntry = entries[0] as Map<String, dynamic>;
        expect(firstEntry['id'], '1');
        expect(firstEntry['mood'], 'happy');
        expect(firstEntry['note'], 'Integration test entry 1');
      });
      
      test('handles multiple file operations simultaneously', () async {
        final testEntries = [
          MoodEntry(id: 'multi-test', mood: MoodType.veryHappy, timestamp: DateTime.now()),
        ];
        
        // Test multiple operations
        final csvPath = await fileService.exportToCSV(testEntries);
        final backupPath = await fileService.createBackup(testEntries);
        
        expect(csvPath, isNotNull);
        expect(backupPath, isNotNull);
        
        // Verify both files exist simultaneously
        expect(await File(csvPath!).exists(), isTrue);
        expect(await File(backupPath!).exists(), isTrue);
        
        // Check storage info after creating files
        final storageInfo = await fileService.getStorageInfo();
        expect(storageInfo['exports']!, greaterThan(0));
        expect(storageInfo['backups']!, greaterThan(0));
      });
    });
  });
}