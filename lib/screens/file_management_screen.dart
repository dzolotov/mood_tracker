import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/file_service.dart';
import '../services/mood_service.dart';

class FileManagementScreen extends StatefulWidget {
  const FileManagementScreen({super.key});

  @override
  State<FileManagementScreen> createState() => _FileManagementScreenState();
}

class _FileManagementScreenState extends State<FileManagementScreen> {
  Map<String, int>? _storageInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    final fileService = context.read<FileService>();
    final info = await fileService.getStorageInfo();
    setState(() {
      _storageInfo = info;
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _exportToCsv() async {
    setState(() => _isLoading = true);
    
    try {
      final moodService = context.read<MoodService>();
      final fileService = context.read<FileService>();
      
      final filePath = await fileService.exportToCSV(moodService.entries);
      
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV экспорт создан: ${filePath.split('/').last}'),
            action: SnackBarAction(
              label: 'Поделиться',
              onPressed: () => fileService.shareFile(filePath),
            ),
          ),
        );
        await _loadStorageInfo();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка создания CSV экспорта')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importFromCsv() async {
    setState(() => _isLoading = true);
    
    try {
      final fileService = context.read<FileService>();
      final moodService = context.read<MoodService>();
      
      final entries = await fileService.importFromCSV();
      
      if (entries != null && entries.isNotEmpty && mounted) {
        // Показываем диалог подтверждения
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Импорт CSV'),
            content: Text(
              'Найдено ${entries.length} записей для импорта.\n'
              'Продолжить импорт?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Импортировать'),
              ),
            ],
          ),
        );
        
        if (confirmed == true) {
          // Добавляем записи
          for (final entry in entries) {
            moodService.addEntry(entry);
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Импортировано ${entries.length} записей'),
              ),
            );
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось импортировать данные')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);
    
    try {
      final moodService = context.read<MoodService>();
      final fileService = context.read<FileService>();
      
      final filePath = await fileService.createBackup(moodService.entries);
      
      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup создан: ${filePath.split('/').last}'),
            action: SnackBarAction(
              label: 'Поделиться',
              onPressed: () => fileService.shareFile(filePath),
            ),
          ),
        );
        await _loadStorageInfo();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка создания backup')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreFromBackup() async {
    setState(() => _isLoading = true);
    
    try {
      final fileService = context.read<FileService>();
      final moodService = context.read<MoodService>();
      
      final entries = await fileService.restoreFromBackup();
      
      if (entries != null && entries.isNotEmpty && mounted) {
        // Показываем диалог подтверждения
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Восстановление'),
            content: Text(
              'Найдено ${entries.length} записей для восстановления.\n'
              'Это заменит все текущие данные!\n'
              'Продолжить?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Восстановить'),
              ),
            ],
          ),
        );
        
        if (confirmed == true) {
          // Очищаем текущие данные и добавляем восстановленные
          moodService.clearEntries();
          for (final entry in entries) {
            moodService.addEntry(entry);
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Восстановлено ${entries.length} записей'),
              ),
            );
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось восстановить данные')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearOldFiles() async {
    setState(() => _isLoading = true);
    
    try {
      final fileService = context.read<FileService>();
      
      final success = await fileService.clearOldFiles(daysToKeep: 30);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Старые файлы очищены')),
        );
        await _loadStorageInfo();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка очистки файлов')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodService = context.watch<MoodService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление файлами'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStorageInfo,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Информация о хранилище
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.storage, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Использование хранилища',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_storageInfo != null) ...[
                    _buildStorageRow('Фотографии', _storageInfo!['photos']!),
                    _buildStorageRow('Экспорты', _storageInfo!['exports']!),
                    _buildStorageRow('Резервные копии', _storageInfo!['backups']!),
                    const Divider(),
                    _buildStorageRow(
                      'Общий размер', 
                      _storageInfo!['total']!, 
                      isTotal: true,
                    ),
                  ] else
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Статистика данных
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Статистика данных',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Записей',
                        moodService.entries.length.toString(),
                        Icons.mood,
                      ),
                      _buildStatCard(
                        'С фото',
                        moodService.entries
                            .where((e) => e.photoPath != null)
                            .length
                            .toString(),
                        Icons.photo_camera,
                      ),
                      _buildStatCard(
                        'Дней',
                        moodService.entries
                            .map((e) => e.timestamp.toIso8601String().split('T')[0])
                            .toSet()
                            .length
                            .toString(),
                        Icons.calendar_today,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Экспорт и импорт
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.import_export, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Экспорт и импорт',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _exportToCsv,
                          icon: const Icon(Icons.file_download),
                          label: const Text('Экспорт CSV'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _importFromCsv,
                          icon: const Icon(Icons.file_upload),
                          label: const Text('Импорт CSV'),
                        ),
                      ),
                    ],
                  ),
                  if (moodService.entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Нет данных для экспорта',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Резервное копирование
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.backup, color: Colors.purple),
                      SizedBox(width: 8),
                      Text(
                        'Резервное копирование',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _createBackup,
                          icon: const Icon(Icons.save),
                          label: const Text('Создать backup'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _restoreFromBackup,
                          icon: const Icon(Icons.restore),
                          label: const Text('Восстановить'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Backup включает все данные и метаданные фотографий',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Очистка и обслуживание
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cleaning_services, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Обслуживание',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _clearOldFiles,
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('Очистить старые файлы (30+ дней)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Удаляет экспорты и резервные копии старше 30 дней',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Выполняется операция...'),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStorageRow(String label, int bytes, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _formatBytes(bytes),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}