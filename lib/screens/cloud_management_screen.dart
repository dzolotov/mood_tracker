import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mood_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';

class CloudManagementScreen extends StatefulWidget {
  const CloudManagementScreen({super.key});

  @override
  State<CloudManagementScreen> createState() => _CloudManagementScreenState();
}

class _CloudManagementScreenState extends State<CloudManagementScreen> {
  bool _isSyncing = false;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  List<BackupInfo> _backups = [];
  StorageUsage? _storageUsage;
  SyncStatus? _syncStatus;

  @override
  void initState() {
    super.initState();
    _loadCloudData();
  }

  Future<void> _loadCloudData() async {
    final moodService = context.read<MoodService>();
    
    try {
      final backups = await moodService.getCloudBackups();
      final usage = await moodService.getCloudStorageUsage();
      final syncStatus = await moodService.getFirestoreSyncStatus();
      
      if (mounted) {
        setState(() {
          _backups = backups;
          _storageUsage = usage;
          _syncStatus = syncStatus;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки данных: $e')),
        );
      }
    }
  }

  Future<void> _syncWithCloud() async {
    setState(() => _isSyncing = true);
    
    try {
      final moodService = context.read<MoodService>();
      final success = await moodService.syncWithCloud();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? 'Синхронизация завершена успешно' 
              : 'Ошибка синхронизации'),
          ),
        );
        if (success) _loadCloudData();
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _backupToCloud() async {
    setState(() => _isBackingUp = true);
    
    try {
      final moodService = context.read<MoodService>();
      final success = await moodService.backupToCloud();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? 'Резервная копия создана' 
              : 'Ошибка создания резервной копии'),
          ),
        );
        if (success) _loadCloudData();
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restoreFromCloud() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Восстановление данных'),
        content: const Text(
          'Это действие заменит все локальные данные данными из облака. '
          'Продолжить?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Восстановить'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRestoring = true);
    
    try {
      final moodService = context.read<MoodService>();
      final success = await moodService.restoreFromCloud();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? 'Данные восстановлены' 
              : 'Ошибка восстановления данных'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить резервную копию?'),
        content: Text('Резервная копия от ${DateFormat('dd.MM.yyyy HH:mm').format(backup.createdAt)} будет удалена.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final moodService = context.read<MoodService>();
      final success = await moodService.deleteCloudBackup(backup.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? 'Резервная копия удалена' 
              : 'Ошибка удаления'),
          ),
        );
        if (success) _loadCloudData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Облачное хранилище'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCloudData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Storage usage card
            if (_storageUsage != null) Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Использование хранилища',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Фотографии:'),
                        Text(_storageUsage!.photosSizeFormatted),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Резервные копии:'),
                        Text(_storageUsage!.backupsSizeFormatted),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Всего:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _storageUsage!.totalSizeFormatted,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Firestore sync status
            if (_syncStatus != null) Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Статус Firestore',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _syncStatus!.isSynced ? Icons.cloud_done : Icons.cloud_off,
                          color: _syncStatus!.isSynced ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Локально:'),
                        Text('${_syncStatus!.localCount} записей'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('В облаке:'),
                        Text('${_syncStatus!.cloudCount} записей'),
                      ],
                    ),
                    if (_syncStatus!.lastSync != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Последняя синхронизация:'),
                          Text(DateFormat('dd.MM HH:mm').format(_syncStatus!.lastSync!)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sync actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Синхронизация',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSyncing ? null : _syncWithCloud,
                        icon: _isSyncing 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                        label: Text(_isSyncing ? 'Синхронизация...' : 'Синхронизировать'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isBackingUp ? null : _backupToCloud,
                        icon: _isBackingUp 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.backup),
                        label: Text(_isBackingUp ? 'Создание копии...' : 'Создать резервную копию'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_isRestoring || _backups.isEmpty) ? null : _restoreFromCloud,
                        icon: _isRestoring 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.restore),
                        label: Text(_isRestoring ? 'Восстановление...' : 'Восстановить из облака'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Backups list
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Резервные копии',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (_backups.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Нет резервных копий',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._backups.map((backup) => ListTile(
                        title: Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(backup.createdAt),
                        ),
                        subtitle: Text('Размер: ${_formatBytes(backup.size)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteBackup(backup),
                        ),
                      )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}