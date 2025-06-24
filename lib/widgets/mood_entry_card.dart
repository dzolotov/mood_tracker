import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';

class MoodEntryCard extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback? onTap;

  const MoodEntryCard({
    Key? key,
    required this.entry,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: entry.mood.color.withOpacity(0.2),
          child: Text(
            entry.mood.emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          entry.mood.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(entry.timestamp)),
            if (entry.note != null && entry.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  entry.note!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (entry.activities.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Wrap(
                  spacing: 4.0,
                  children: entry.activities.map((activity) => Chip(
                    label: Text(
                      activity,
                      style: const TextStyle(fontSize: 12),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ),
            if (entry.sleepDuration != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.bedtime, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.sleepDuration!.inHours}ч ${entry.sleepDuration!.inMinutes % 60}м',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
        onTap: onTap,
        trailing: entry.photoPath != null
            ? const Icon(Icons.photo_camera, size: 20)
            : null,
      ),
    );
  }
}