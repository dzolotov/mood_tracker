import 'package:flutter/material.dart';

enum MoodType {
  veryHappy(5, '😄', 'Очень счастлив', Colors.green),
  happy(4, '🙂', 'Счастлив', Colors.lightGreen),
  neutral(3, '😐', 'Нейтрально', Colors.yellow),
  sad(2, '😕', 'Грустно', Colors.orange),
  verySad(1, '😢', 'Очень грустно', Colors.red);

  final int value;
  final String emoji;
  final String label;
  final Color color;

  const MoodType(this.value, this.emoji, this.label, this.color);
}

class MoodEntry {
  final String id;
  final MoodType mood;
  final DateTime timestamp;
  final String? note;
  final List<String> activities;
  final Duration? sleepDuration;
  final DateTime? sleepTime;
  final DateTime? wakeTime;
  final String? photoPath;

  MoodEntry({
    required this.id,
    required this.mood,
    required this.timestamp,
    this.note,
    this.activities = const [],
    this.sleepDuration,
    this.sleepTime,
    this.wakeTime,
    this.photoPath,
  });

  MoodEntry copyWith({
    String? id,
    MoodType? mood,
    DateTime? timestamp,
    String? note,
    List<String>? activities,
    Duration? sleepDuration,
    DateTime? sleepTime,
    DateTime? wakeTime,
    String? photoPath,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      activities: activities ?? this.activities,
      sleepDuration: sleepDuration ?? this.sleepDuration,
      sleepTime: sleepTime ?? this.sleepTime,
      wakeTime: wakeTime ?? this.wakeTime,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}