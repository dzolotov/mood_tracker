import 'package:flutter/material.dart';
import '../data/objectbox/objectbox_service.dart';
import '../models/mood_entry.dart';
import '../widgets/mood_entry_card.dart';

class ObjectBoxDemoScreen extends StatefulWidget {
  const ObjectBoxDemoScreen({Key? key}) : super(key: key);

  @override
  State<ObjectBoxDemoScreen> createState() => _ObjectBoxDemoScreenState();
}

class _ObjectBoxDemoScreenState extends State<ObjectBoxDemoScreen> {
  final ObjectBoxService _objectBoxService = ObjectBoxService();
  List<MoodEntry> _entries = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }
  
  Future<void> _initializeAndLoad() async {
    setState(() => _isLoading = true);
    
    try {
      if (!_objectBoxService.isInitialized) {
        await _objectBoxService.initialize();
      }
      await _loadEntries();
    } catch (e) {
      _showError('Ошибка инициализации: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _loadEntries() async {
    try {
      final entries = await _objectBoxService.repository.getAllMoodEntries();
      setState(() => _entries = entries);
    } catch (e) {
      _showError('Ошибка загрузки: $e');
    }
  }
  
  Future<void> _addSampleEntry() async {
    final entry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mood: MoodType.values[DateTime.now().second % 5],
      timestamp: DateTime.now(),
      note: 'Тестовая запись из ObjectBox Demo',
      activities: ['Тестирование', 'Разработка'],
      sleepDuration: const Duration(hours: 7, minutes: 30),
      sleepTime: DateTime.now().subtract(const Duration(hours: 8)),
      wakeTime: DateTime.now().subtract(const Duration(minutes: 30)),
    );
    
    try {
      await _objectBoxService.repository.addMoodEntry(entry);
      await _loadEntries();
      _showMessage('Запись добавлена!');
    } catch (e) {
      _showError('Ошибка добавления: $e');
    }
  }
  
  Future<void> _searchEntries(String term) async {
    if (term.isEmpty) {
      await _loadEntries();
      return;
    }
    
    try {
      final results = await _objectBoxService.repository.searchMoodEntries(term);
      setState(() => _entries = results);
    } catch (e) {
      _showError('Ошибка поиска: $e');
    }
  }
  
  Future<void> _filterByMood(MoodType mood) async {
    try {
      final results = await _objectBoxService.repository.getMoodEntriesByMood(mood);
      setState(() => _entries = results);
    } catch (e) {
      _showError('Ошибка фильтрации: $e');
    }
  }
  
  Future<void> _showStats() async {
    try {
      final distribution = await _objectBoxService.repository.getMoodDistribution();
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final avgMood = await _objectBoxService.repository.getAverageMoodForPeriod(weekAgo, now);
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Статистика ObjectBox'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Средний показатель за неделю: ${avgMood.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              const Text('Распределение настроений:'),
              ...distribution.entries.map((e) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text('${e.key.emoji} ${e.key.label}: ${e.value}'),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showError('Ошибка получения статистики: $e');
    }
  }
  
  Future<void> _deleteEntry(String id) async {
    try {
      await _objectBoxService.repository.deleteMoodEntry(id);
      await _loadEntries();
      _showMessage('Запись удалена');
    } catch (e) {
      _showError('Ошибка удаления: $e');
    }
  }
  
  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение'),
        content: const Text('Удалить все записи из ObjectBox?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await _objectBoxService.repository.clearAllData();
        await _loadEntries();
        _showMessage('Все записи удалены');
      } catch (e) {
        _showError('Ошибка очистки: $e');
      }
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ObjectBox Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _showStats,
            tooltip: 'Статистика',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAll,
            tooltip: 'Очистить все',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Поиск по заметкам и активностям...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _searchEntries,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ActionChip(
                  label: const Text('Все'),
                  onPressed: _loadEntries,
                ),
                const SizedBox(width: 8),
                ...MoodType.values.map((mood) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text('${mood.emoji} ${mood.label}'),
                    onPressed: () => _filterByMood(mood),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_entries.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Нет записей'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return Dismissible(
                    key: Key(entry.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _deleteEntry(entry.id),
                    child: MoodEntryCard(
                      entry: entry,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('${entry.mood.emoji} Запись'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: ${entry.id}'),
                                Text('Время: ${entry.timestamp}'),
                                if (entry.note != null)
                                  Text('Заметка: ${entry.note}'),
                                if (entry.activities.isNotEmpty)
                                  Text('Активности: ${entry.activities.join(", ")}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Закрыть'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleEntry,
        child: const Icon(Icons.add),
        tooltip: 'Добавить тестовую запись',
      ),
    );
  }
}