import 'package:objectbox/objectbox.dart';
import '../models/objectbox/mood_entry_entity.dart';
import '../models/mood_entry.dart';
import '../objectbox.g.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Store? _store;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  static Future<void> initialize() async {
    if (_store != null) return;
    _store = await openStore();
  }

  Store get store {
    if (_store == null) {
      throw StateError('DatabaseService not initialized. Call initialize() first.');
    }
    return _store!;
  }

  Box<MoodEntryEntity> get moodBox => store.box<MoodEntryEntity>();

  // CRUD operations for mood entries
  Future<void> saveMoodEntry(MoodEntry entry) async {
    final entity = MoodEntryEntity.fromMoodEntry(entry);
    moodBox.put(entity);
  }

  Future<List<MoodEntry>> getAllMoodEntries() async {
    final entities = moodBox.getAll();
    return entities.map((e) => e.toMoodEntry()).toList();
  }

  Future<MoodEntry?> getMoodEntryById(String entryId) async {
    final query = moodBox.query(MoodEntryEntity_.entryId.equals(entryId)).build();
    final entity = query.findFirst();
    query.close();
    return entity?.toMoodEntry();
  }

  Future<List<MoodEntry>> getMoodEntriesByDateRange(DateTime start, DateTime end) async {
    final query = moodBox.query(
      MoodEntryEntity_.timestamp.greaterOrEqual(start.millisecondsSinceEpoch) &
      MoodEntryEntity_.timestamp.lessOrEqual(end.millisecondsSinceEpoch)
    ).build();
    final entities = query.find();
    query.close();
    return entities.map((e) => e.toMoodEntry()).toList();
  }

  Future<void> updateMoodEntry(MoodEntry entry) async {
    final query = moodBox.query(MoodEntryEntity_.entryId.equals(entry.id)).build();
    final entity = query.findFirst();
    query.close();
    
    if (entity != null) {
      final updatedEntity = MoodEntryEntity.fromMoodEntry(entry);
      updatedEntity.id = entity.id; // Keep the ObjectBox ID
      moodBox.put(updatedEntity);
    }
  }

  Future<void> deleteMoodEntry(String entryId) async {
    final query = moodBox.query(MoodEntryEntity_.entryId.equals(entryId)).build();
    final entity = query.findFirst();
    query.close();
    
    if (entity != null) {
      moodBox.remove(entity.id);
    }
  }

  Future<int> getMoodEntryCount() async {
    return moodBox.count();
  }

  Future<List<MoodEntry>> getRecentMoodEntries(int limit) async {
    final query = moodBox.query()
      ..order(MoodEntryEntity_.timestamp, flags: Order.descending);
    final builtQuery = query.build();
    final entities = builtQuery.find();
    builtQuery.close();
    
    // Apply limit manually since ObjectBox find() doesn't support limit parameter
    final limitedEntities = entities.take(limit).toList();
    return limitedEntities.map((e) => e.toMoodEntry()).toList();
  }

  Future<double> getAverageMoodForPeriod(DateTime start, DateTime end) async {
    final entries = await getMoodEntriesByDateRange(start, end);
    if (entries.isEmpty) return 0.0;
    
    final sum = entries.fold<int>(0, (sum, entry) => sum + entry.mood.value);
    return sum / entries.length;
  }

  Future<Map<MoodType, int>> getMoodDistribution() async {
    final entries = await getAllMoodEntries();
    final distribution = <MoodType, int>{};
    
    for (final mood in MoodType.values) {
      distribution[mood] = 0;
    }
    
    for (final entry in entries) {
      distribution[entry.mood] = (distribution[entry.mood] ?? 0) + 1;
    }
    
    return distribution;
  }

  Future<void> clearAllData() async {
    moodBox.removeAll();
  }

  void dispose() {
    _store?.close();
    _store = null;
  }
}