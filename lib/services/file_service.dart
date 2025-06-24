import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:csv/csv.dart';
import '../models/mood_entry.dart';

class FileService extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();
  String? _lastExportPath;
  String? _lastBackupPath;
  
  String? get lastExportPath => _lastExportPath;
  String? get lastBackupPath => _lastBackupPath;

  // Получение путей к директориям приложения
  Future<Map<String, String>> getAppDirectories() async {
    final appDir = await getApplicationDocumentsDirectory();
    final tempDir = await getTemporaryDirectory();
    final supportDir = await getApplicationSupportDirectory();
    
    // Создаем поддиректории для разных типов файлов
    final moodDataDir = Directory('${appDir.path}/mood_data');
    final photosDir = Directory('${appDir.path}/photos');
    final exportsDir = Directory('${appDir.path}/exports');
    final backupsDir = Directory('${appDir.path}/backups');
    
    // Создаем директории если их нет
    await moodDataDir.create(recursive: true);
    await photosDir.create(recursive: true);
    await exportsDir.create(recursive: true);
    await backupsDir.create(recursive: true);
    
    return {
      'app': appDir.path,
      'temp': tempDir.path,
      'support': supportDir.path,
      'moodData': moodDataDir.path,
      'photos': photosDir.path,
      'exports': exportsDir.path,
      'backups': backupsDir.path,
    };
  }

  // Сохранение фото и возврат пути к нему
  Future<String?> savePhoto(XFile photo) async {
    try {
      final dirs = await getAppDirectories();
      final photosDir = dirs['photos']!;
      
      // Создаем уникальное имя файла с timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = photo.path.split('.').last;
      final fileName = 'mood_photo_$timestamp.$extension';
      final filePath = '$photosDir/$fileName';
      
      // Копируем файл в папку приложения
      await File(photo.path).copy(filePath);
      
      return filePath;
    } catch (e) {
      debugPrint('Ошибка сохранения фото: $e');
      return null;
    }
  }

  // Выбор фото с камеры
  Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (photo != null) {
        return await savePhoto(photo);
      }
      return null;
    } catch (e) {
      debugPrint('Ошибка при съемке фото: $e');
      return null;
    }
  }

  // Выбор фото из галереи
  Future<String?> pickPhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (photo != null) {
        return await savePhoto(photo);
      }
      return null;
    } catch (e) {
      debugPrint('Ошибка при выборе фото: $e');
      return null;
    }
  }

  // Экспорт данных в CSV
  Future<String?> exportToCSV(List<MoodEntry> entries) async {
    try {
      final dirs = await getAppDirectories();
      final exportsDir = dirs['exports']!;
      
      // Создаем имя файла с датой
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final fileName = 'mood_export_$dateStr.csv';
      final filePath = '$exportsDir/$fileName';
      
      // Создаем CSV данные
      List<List<dynamic>> csvData = [
        // Заголовки
        [
          'ID',
          'Дата',
          'Время',
          'Настроение',
          'Оценка',
          'Заметка',
          'Активности',
          'Время сна',
          'Время пробуждения',
          'Продолжительность сна (часы)',
          'Есть фото'
        ]
      ];
      
      // Добавляем данные записей
      for (final entry in entries) {
        csvData.add([
          entry.id,
          entry.timestamp.toIso8601String().split('T')[0], // Дата
          entry.timestamp.toIso8601String().split('T')[1].split('.')[0], // Время
          entry.mood.label,
          entry.mood.value,
          entry.note ?? '',
          entry.activities.join('; '),
          entry.sleepTime?.toIso8601String() ?? '',
          entry.wakeTime?.toIso8601String() ?? '',
          entry.sleepDuration?.inHours.toString() ?? '',
          entry.photoPath != null ? 'Да' : 'Нет',
        ]);
      }
      
      // Конвертируем в CSV строку
      String csvString = const ListToCsvConverter().convert(csvData);
      
      // Сохраняем файл
      final file = File(filePath);
      await file.writeAsString(csvString, encoding: utf8);
      
      _lastExportPath = filePath;
      notifyListeners();
      
      return filePath;
    } catch (e) {
      debugPrint('Ошибка экспорта в CSV: $e');
      return null;
    }
  }

  // Импорт данных из CSV
  Future<List<MoodEntry>?> importFromCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final csvString = await file.readAsString(encoding: utf8);
        
        // Парсим CSV
        List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
        
        // Пропускаем заголовок
        if (csvData.isEmpty || csvData.length < 2) {
          throw Exception('CSV файл пуст или содержит только заголовки');
        }
        
        List<MoodEntry> entries = [];
        
        for (int i = 1; i < csvData.length; i++) {
          final row = csvData[i];
          if (row.length < 5) continue; // Пропускаем неполные строки
          
          try {
            // Парсим настроение по оценке
            final moodValue = int.tryParse(row[4].toString()) ?? 3;
            final mood = MoodType.values.firstWhere(
              (m) => m.value == moodValue,
              orElse: () => MoodType.neutral,
            );
            
            // Парсим дату и время
            final dateStr = row[1].toString();
            final timeStr = row[2].toString();
            final timestamp = DateTime.tryParse('${dateStr}T$timeStr') ?? DateTime.now();
            
            // Парсим активности
            final activitiesStr = row[6].toString();
            final activities = activitiesStr.isNotEmpty 
                ? activitiesStr.split('; ').where((a) => a.isNotEmpty).toList()
                : <String>[];
            
            // Парсим время сна если есть
            DateTime? sleepTime;
            DateTime? wakeTime;
            Duration? sleepDuration;
            
            if (row.length > 7 && row[7].toString().isNotEmpty) {
              sleepTime = DateTime.tryParse(row[7].toString());
            }
            if (row.length > 8 && row[8].toString().isNotEmpty) {
              wakeTime = DateTime.tryParse(row[8].toString());
            }
            if (row.length > 9 && row[9].toString().isNotEmpty) {
              final hours = double.tryParse(row[9].toString());
              if (hours != null) {
                sleepDuration = Duration(minutes: (hours * 60).round());
              }
            }
            
            final entry = MoodEntry(
              id: row[0].toString(),
              mood: mood,
              timestamp: timestamp,
              note: row[5].toString().isEmpty ? null : row[5].toString(),
              activities: activities,
              sleepTime: sleepTime,
              wakeTime: wakeTime,
              sleepDuration: sleepDuration,
              // Фото не импортируем, так как пути могут быть недействительными
            );
            
            entries.add(entry);
          } catch (e) {
            debugPrint('Ошибка парсинга строки $i: $e');
            continue; // Пропускаем проблемные строки
          }
        }
        
        return entries;
      }
      
      return null;
    } catch (e) {
      debugPrint('Ошибка импорта из CSV: $e');
      return null;
    }
  }

  // Создание резервной копии в JSON формате
  Future<String?> createBackup(List<MoodEntry> entries) async {
    try {
      final dirs = await getAppDirectories();
      final backupsDir = dirs['backups']!;
      
      // Создаем имя файла с датой и временем
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';
      final fileName = 'mood_backup_$dateStr.json';
      final filePath = '$backupsDir/$fileName';
      
      // Конвертируем entries в JSON
      final backupData = {
        'version': '1.0',
        'exportDate': now.toIso8601String(),
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
      
      // Сохраняем файл
      final file = File(filePath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(backupData),
        encoding: utf8,
      );
      
      _lastBackupPath = filePath;
      notifyListeners();
      
      return filePath;
    } catch (e) {
      debugPrint('Ошибка создания backup: $e');
      return null;
    }
  }

  // Восстановление из резервной копии
  Future<List<MoodEntry>?> restoreFromBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString(encoding: utf8);
        final backupData = json.decode(jsonString) as Map<String, dynamic>;
        
        if (!backupData.containsKey('entries')) {
          throw Exception('Некорректный формат backup файла');
        }
        
        final entriesData = backupData['entries'] as List;
        List<MoodEntry> entries = [];
        
        for (final entryData in entriesData) {
          try {
            final entry = entryData as Map<String, dynamic>;
            
            // Парсим настроение
            final moodName = entry['mood'] as String;
            final mood = MoodType.values.firstWhere(
              (m) => m.name == moodName,
              orElse: () => MoodType.neutral,
            );
            
            // Парсим время сна
            Duration? sleepDuration;
            if (entry['sleepDuration'] != null) {
              sleepDuration = Duration(minutes: entry['sleepDuration'] as int);
            }
            
            final restoredEntry = MoodEntry(
              id: entry['id'] as String,
              mood: mood,
              timestamp: DateTime.parse(entry['timestamp'] as String),
              note: entry['note'] as String?,
              activities: List<String>.from(entry['activities'] as List? ?? []),
              sleepTime: entry['sleepTime'] != null 
                  ? DateTime.parse(entry['sleepTime'] as String)
                  : null,
              wakeTime: entry['wakeTime'] != null 
                  ? DateTime.parse(entry['wakeTime'] as String)
                  : null,
              sleepDuration: sleepDuration,
              photoPath: entry['photoPath'] as String?,
            );
            
            entries.add(restoredEntry);
          } catch (e) {
            debugPrint('Ошибка восстановления записи: $e');
            continue;
          }
        }
        
        return entries;
      }
      
      return null;
    } catch (e) {
      debugPrint('Ошибка восстановления из backup: $e');
      return null;
    }
  }

  // Получение размера используемого пространства
  Future<Map<String, int>> getStorageInfo() async {
    try {
      final dirs = await getAppDirectories();
      
      int photosSize = 0;
      int exportsSize = 0;
      int backupsSize = 0;
      
      // Подсчитываем размер фото
      final photosDir = Directory(dirs['photos']!);
      if (await photosDir.exists()) {
        await for (final file in photosDir.list(recursive: true)) {
          if (file is File) {
            final stat = await file.stat();
            photosSize += stat.size;
          }
        }
      }
      
      // Подсчитываем размер экспортов
      final exportsDir = Directory(dirs['exports']!);
      if (await exportsDir.exists()) {
        await for (final file in exportsDir.list(recursive: true)) {
          if (file is File) {
            final stat = await file.stat();
            exportsSize += stat.size;
          }
        }
      }
      
      // Подсчитываем размер backup'ов
      final backupsDir = Directory(dirs['backups']!);
      if (await backupsDir.exists()) {
        await for (final file in backupsDir.list(recursive: true)) {
          if (file is File) {
            final stat = await file.stat();
            backupsSize += stat.size;
          }
        }
      }
      
      return {
        'photos': photosSize,
        'exports': exportsSize,
        'backups': backupsSize,
        'total': photosSize + exportsSize + backupsSize,
      };
    } catch (e) {
      debugPrint('Ошибка получения информации о хранилище: $e');
      return {
        'photos': 0,
        'exports': 0,
        'backups': 0,
        'total': 0,
      };
    }
  }

  // Очистка старых файлов
  Future<bool> clearOldFiles({int daysToKeep = 30}) async {
    try {
      final dirs = await getAppDirectories();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      int deletedCount = 0;
      
      // Очищаем старые экспорты
      final exportsDir = Directory(dirs['exports']!);
      if (await exportsDir.exists()) {
        await for (final file in exportsDir.list()) {
          if (file is File) {
            final stat = await file.stat();
            if (stat.modified.isBefore(cutoffDate)) {
              await file.delete();
              deletedCount++;
            }
          }
        }
      }
      
      // Очищаем старые backup'ы
      final backupsDir = Directory(dirs['backups']!);
      if (await backupsDir.exists()) {
        await for (final file in backupsDir.list()) {
          if (file is File) {
            final stat = await file.stat();
            if (stat.modified.isBefore(cutoffDate)) {
              await file.delete();
              deletedCount++;
            }
          }
        }
      }
      
      debugPrint('Удалено $deletedCount старых файлов');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка очистки старых файлов: $e');
      return false;
    }
  }

  // Поделиться файлом (для будущего использования с share_plus)
  Future<void> shareFile(String filePath) async {
    // Здесь можно добавить логику для шеринга файлов
    // Пока просто показываем путь к файлу
    debugPrint('Файл для шеринга: $filePath');
  }
}