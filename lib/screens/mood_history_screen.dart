import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/mood_service.dart';
import '../models/mood_entry.dart';

class MoodHistoryScreen extends StatelessWidget {
  const MoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodService = context.watch<MoodService>();
    final entries = moodService.entries.reversed.toList();

    if (entries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'История пуста',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Добавьте свое первое настроение',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Группируем записи по датам
    final groupedEntries = <String, List<MoodEntry>>{};
    for (final entry in entries) {
      final dateKey = DateFormat('dd MMMM yyyy', 'ru').format(entry.timestamp);
      groupedEntries[dateKey] ??= [];
      groupedEntries[dateKey]!.add(entry);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedEntries.length,
      itemBuilder: (context, index) {
        final dateKey = groupedEntries.keys.elementAt(index);
        final dayEntries = groupedEntries[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                dateKey,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...dayEntries.map((entry) => _MoodEntryCard(entry: entry)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _MoodEntryCard extends StatelessWidget {
  final MoodEntry entry;

  const _MoodEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: entry.mood.color.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              entry.mood.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(entry.mood.label),
            const SizedBox(width: 8),
            Text(
              DateFormat('HH:mm').format(entry.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.sleepDuration != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.bedtime, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Сон: ${entry.sleepDuration!.inHours}ч ${entry.sleepDuration!.inMinutes % 60}мин',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            if (entry.activities.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: entry.activities
                    .map((activity) => Chip(
                          label: Text(
                            activity,
                            style: const TextStyle(fontSize: 10),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                entry.note!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            final moodService = context.read<MoodService>();
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Удалить запись?'),
                content: const Text('Это действие нельзя отменить'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () {
                      moodService.deleteMoodEntry(entry.id);
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Удалить'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}