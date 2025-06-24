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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood.value,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'activities': activities,
      'sleepDurationMinutes': sleepDuration?.inMinutes,
      'sleepTime': sleepTime?.toIso8601String(),
      'wakeTime': wakeTime?.toIso8601String(),
      'photoPath': photoPath,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      mood: MoodType.values.firstWhere((m) => m.value == json['mood']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
      activities: List<String>.from(json['activities'] ?? []),
      sleepDuration: json['sleepDurationMinutes'] != null
          ? Duration(minutes: json['sleepDurationMinutes'] as int)
          : null,
      sleepTime: json['sleepTime'] != null
          ? DateTime.parse(json['sleepTime'] as String)
          : null,
      wakeTime: json['wakeTime'] != null
          ? DateTime.parse(json['wakeTime'] as String)
          : null,
      photoPath: json['photoPath'] as String?,
    );
  }
}