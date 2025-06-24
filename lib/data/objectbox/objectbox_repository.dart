import 'package:objectbox/objectbox.dart';
import '../../models/mood_entry.dart';
import 'models/mood_entry_box.dart';
import '../../objectbox.g.dart';

class ObjectBoxRepository {
  late final Store _store;
  late final Box<MoodEntryBox> _moodBox;
  
  static final ObjectBoxRepository _instance = ObjectBoxRepository._internal();
  
  factory ObjectBoxRepository() => _instance;
  
  ObjectBoxRepository._internal();
  
  Future<void> initialize() async {
    _store = await openStore();
    _moodBox = _store.box<MoodEntryBox>();
  }
  
  void close() {
    _store.close();
  }
  
  Future<String> addMoodEntry(MoodEntry entry) async {
    final boxEntry = MoodEntryBox.fromMoodEntry(entry);
    final id = _moodBox.put(boxEntry);
    return entry.id;
  }
  
  Future<MoodEntry?> getMoodEntry(String id) async {
    final query = _moodBox.query(
      MoodEntryBox_.entryId.equals(id)
    ).build();
    
    final result = query.findFirst();
    query.close();
    
    return result?.toMoodEntry();
  }
  
  Future<List<MoodEntry>> getAllMoodEntries() async {
    final allEntries = _moodBox.getAll();
    return allEntries.map((box) => box.toMoodEntry()).toList();
  }
  
  Future<List<MoodEntry>> getMoodEntriesForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final query = _moodBox.query(
      MoodEntryBox_.timestamp.between(
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      )
    ).order(MoodEntryBox_.timestamp, flags: Order.descending).build();
    
    final results = query.find();
    query.close();
    
    return results.map((box) => box.toMoodEntry()).toList();
  }
  
  Future<List<MoodEntry>> getMoodEntriesByMood(MoodType mood) async {
    final query = _moodBox.query(
      MoodEntryBox_.moodValue.equals(mood.value)
    ).order(MoodEntryBox_.timestamp, flags: Order.descending).build();
    
    final results = query.find();
    query.close();
    
    return results.map((box) => box.toMoodEntry()).toList();
  }
  
  Future<List<MoodEntry>> searchMoodEntries(String searchTerm) async {
    final query = _moodBox.query(
      MoodEntryBox_.note.contains(searchTerm, caseSensitive: false) |
      MoodEntryBox_.activities.contains(searchTerm, caseSensitive: false)
    ).order(MoodEntryBox_.timestamp, flags: Order.descending).build();
    
    final results = query.find();
    query.close();
    
    return results.map((box) => box.toMoodEntry()).toList();
  }
  
  Future<void> updateMoodEntry(MoodEntry entry) async {
    final query = _moodBox.query(
      MoodEntryBox_.entryId.equals(entry.id)
    ).build();
    
    final existing = query.findFirst();
    query.close();
    
    if (existing != null) {
      final updated = MoodEntryBox.fromMoodEntry(entry);
      updated.id = existing.id;
      _moodBox.put(updated);
    }
  }
  
  Future<void> deleteMoodEntry(String id) async {
    final query = _moodBox.query(
      MoodEntryBox_.entryId.equals(id)
    ).build();
    
    final existing = query.findFirst();
    query.close();
    
    if (existing != null) {
      _moodBox.remove(existing.id);
    }
  }
  
  Future<Map<MoodType, int>> getMoodDistribution() async {
    final distribution = <MoodType, int>{};
    
    for (final mood in MoodType.values) {
      final count = _moodBox.query(
        MoodEntryBox_.moodValue.equals(mood.value)
      ).build().count();
      distribution[mood] = count;
    }
    
    return distribution;
  }
  
  Future<double> getAverageMoodForPeriod(
    DateTime start,
    DateTime end,
  ) async {
    final query = _moodBox.query(
      MoodEntryBox_.timestamp.between(
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      )
    ).build();
    
    final results = query.find();
    query.close();
    
    if (results.isEmpty) return 0.0;
    
    final sum = results.fold<int>(0, (sum, entry) => sum + entry.moodValue);
    return sum / results.length;
  }
  
  Stream<List<MoodEntry>> watchMoodEntries() {
    return _moodBox.query()
        .order(MoodEntryBox_.timestamp, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) => query.find())
        .map((boxes) => boxes.map((box) => box.toMoodEntry()).toList());
  }
  
  Future<void> clearAllData() async {
    await _moodBox.removeAll();
  }
}