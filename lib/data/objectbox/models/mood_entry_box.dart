import 'package:objectbox/objectbox.dart';
import '../../../models/mood_entry.dart';

@Entity()
class MoodEntryBox {
  @Id()
  int id = 0;
  
  @Unique()
  String entryId;
  
  int moodValue;
  
  @Property(type: PropertyType.date)
  DateTime timestamp;
  
  String? note;
  
  String activities;
  
  int? sleepDurationMinutes;
  
  @Property(type: PropertyType.date)
  DateTime? sleepTime;
  
  @Property(type: PropertyType.date)
  DateTime? wakeTime;
  
  String? photoPath;
  
  MoodEntryBox({
    this.id = 0,
    required this.entryId,
    required this.moodValue,
    required this.timestamp,
    this.note,
    required this.activities,
    this.sleepDurationMinutes,
    this.sleepTime,
    this.wakeTime,
    this.photoPath,
  });
  
  factory MoodEntryBox.fromMoodEntry(MoodEntry entry) {
    return MoodEntryBox(
      entryId: entry.id,
      moodValue: entry.mood.value,
      timestamp: entry.timestamp,
      note: entry.note,
      activities: entry.activities.join(','),
      sleepDurationMinutes: entry.sleepDuration?.inMinutes,
      sleepTime: entry.sleepTime,
      wakeTime: entry.wakeTime,
      photoPath: entry.photoPath,
    );
  }
  
  MoodEntry toMoodEntry() {
    return MoodEntry(
      id: entryId,
      mood: MoodType.values.firstWhere((m) => m.value == moodValue),
      timestamp: timestamp,
      note: note,
      activities: activities.isEmpty ? [] : activities.split(','),
      sleepDuration: sleepDurationMinutes != null 
          ? Duration(minutes: sleepDurationMinutes!) 
          : null,
      sleepTime: sleepTime,
      wakeTime: wakeTime,
      photoPath: photoPath,
    );
  }
}