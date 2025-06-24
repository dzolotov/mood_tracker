import 'package:objectbox/objectbox.dart';
import '../mood_entry.dart';

@Entity()
class MoodEntryEntity {
  @Id()
  int id = 0;

  String entryId;
  int moodValue;
  @Property(type: PropertyType.date)
  DateTime timestamp;
  String? note;
  String activities; // JSON encoded list
  int? sleepDurationMinutes;
  @Property(type: PropertyType.date)
  DateTime? sleepTime;
  @Property(type: PropertyType.date)
  DateTime? wakeTime;
  String? photoPath;

  MoodEntryEntity({
    this.id = 0,
    required this.entryId,
    required this.moodValue,
    required this.timestamp,
    this.note,
    this.activities = '[]',
    this.sleepDurationMinutes,
    this.sleepTime,
    this.wakeTime,
    this.photoPath,
  });

  // Convert from domain model to entity
  factory MoodEntryEntity.fromMoodEntry(MoodEntry entry) {
    return MoodEntryEntity(
      entryId: entry.id,
      moodValue: entry.mood.value,
      timestamp: entry.timestamp,
      note: entry.note,
      activities: _encodeActivities(entry.activities),
      sleepDurationMinutes: entry.sleepDuration?.inMinutes,
      sleepTime: entry.sleepTime,
      wakeTime: entry.wakeTime,
      photoPath: entry.photoPath,
    );
  }

  // Convert from entity to domain model
  MoodEntry toMoodEntry() {
    return MoodEntry(
      id: entryId,
      mood: MoodType.values.firstWhere((m) => m.value == moodValue),
      timestamp: timestamp,
      note: note,
      activities: _decodeActivities(activities),
      sleepDuration: sleepDurationMinutes != null 
          ? Duration(minutes: sleepDurationMinutes!) 
          : null,
      sleepTime: sleepTime,
      wakeTime: wakeTime,
      photoPath: photoPath,
    );
  }

  static String _encodeActivities(List<String> activities) {
    // Simple JSON encoding for activities
    return activities.map((a) => '"$a"').join(',');
  }

  static List<String> _decodeActivities(String encoded) {
    if (encoded.isEmpty || encoded == '[]') return [];
    return encoded
        .split(',')
        .map((a) => a.trim().replaceAll('"', ''))
        .where((a) => a.isNotEmpty)
        .toList();
  }
}