import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry.dart';
import '../services/mood_service.dart';
import '../services/file_service.dart';

class AddMoodScreen extends StatefulWidget {
  const AddMoodScreen({super.key});

  @override
  State<AddMoodScreen> createState() => _AddMoodScreenState();
}

class _AddMoodScreenState extends State<AddMoodScreen> {
  MoodType? _selectedMood;
  final _noteController = TextEditingController();
  final List<String> _selectedActivities = [];
  TimeOfDay? _sleepTime;
  TimeOfDay? _wakeTime;
  String? _photoPath;
  
  final List<String> _availableActivities = [
    'Работа',
    'Спорт',
    'Семья',
    'Друзья',
    'Хобби',
    'Отдых',
    'Учеба',
    'Путешествие',
    'Еда',
    'Сон',
    'Прогулка',
    'Музыка',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveMood() {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите настроение')),
      );
      return;
    }

    DateTime? sleepDateTime;
    DateTime? wakeDateTime;
    Duration? sleepDuration;

    if (_sleepTime != null && _wakeTime != null) {
      final now = DateTime.now();
      sleepDateTime = DateTime(
        now.year,
        now.month,
        now.day - 1,
        _sleepTime!.hour,
        _sleepTime!.minute,
      );
      wakeDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _wakeTime!.hour,
        _wakeTime!.minute,
      );
      
      if (wakeDateTime.isBefore(sleepDateTime)) {
        wakeDateTime = wakeDateTime.add(const Duration(days: 1));
      }
      
      sleepDuration = wakeDateTime.difference(sleepDateTime);
    }

    final entry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mood: _selectedMood!,
      timestamp: DateTime.now(),
      note: _noteController.text.isEmpty ? null : _noteController.text,
      activities: _selectedActivities,
      sleepTime: sleepDateTime,
      wakeTime: wakeDateTime,
      sleepDuration: sleepDuration,
      photoPath: _photoPath,
    );

    context.read<MoodService>().addMoodEntry(entry);
    Navigator.pop(context);
  }

  Future<void> _showPhotoOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Добавить фото',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Сделать фото'),
              onTap: () async {
                Navigator.pop(context);
                await _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Выбрать из галереи'),
              onTap: () async {
                Navigator.pop(context);
                await _pickPhoto();
              },
            ),
            if (_photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Удалить фото'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _photoPath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    final fileService = context.read<FileService>();
    final photoPath = await fileService.takePhoto();
    if (photoPath != null) {
      setState(() => _photoPath = photoPath);
    }
  }

  Future<void> _pickPhoto() async {
    final fileService = context.read<FileService>();
    final photoPath = await fileService.pickPhoto();
    if (photoPath != null) {
      setState(() => _photoPath = photoPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить настроение'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Как вы себя чувствуете?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Center(
              child: Wrap(
                spacing: 16,
                children: MoodType.values.map((mood) {
                  final isSelected = _selectedMood == mood;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? mood.color.withAlpha((0.3 * 255).round())
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? mood.color : Colors.grey,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mood.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Что вы делали?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableActivities.map((activity) {
                final isSelected = _selectedActivities.contains(activity);
                return FilterChip(
                  label: Text(activity),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedActivities.add(activity);
                      } else {
                        _selectedActivities.remove(activity);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Сон',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.bedtime),
                      title: const Text('Время сна'),
                      subtitle: Text(
                        _sleepTime != null
                            ? '${_sleepTime!.hour.toString().padLeft(2, '0')}:${_sleepTime!.minute.toString().padLeft(2, '0')}'
                            : 'Не указано',
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _sleepTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => _sleepTime = time);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.wb_sunny),
                      title: const Text('Время подъема'),
                      subtitle: Text(
                        _wakeTime != null
                            ? '${_wakeTime!.hour.toString().padLeft(2, '0')}:${_wakeTime!.minute.toString().padLeft(2, '0')}'
                            : 'Не указано',
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _wakeTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => _wakeTime = time);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Заметки (необязательно)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Добавьте заметку о вашем настроении...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Фотография (необязательно)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: _photoPath != null
                  ? Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.file(
                            File(_photoPath!),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error, size: 48),
                                      Text('Ошибка загрузки фото'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Изменить фото'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => _photoPath = null),
                          ),
                          onTap: _showPhotoOptions,
                        ),
                      ],
                    )
                  : ListTile(
                      leading: const Icon(Icons.add_a_photo),
                      title: const Text('Добавить фото'),
                      subtitle: const Text('Запечатлейте момент'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showPhotoOptions,
                    ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveMood,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Сохранить',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}