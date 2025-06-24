import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';
import 'database_service.dart';
import 'realm_service.dart';

class MoodService extends ChangeNotifier {
  List<MoodEntry> _entries = [];
  
  List<MoodEntry> get entries => List.unmodifiable(_entries);

  Future<void> initialize() async {
    await _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      _entries = await DatabaseService.instance.getAllMoodEntries();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading mood entries: $e');
    }
  }
  
  Future<void> addMoodEntry(MoodEntry entry) async {
    try {
      await DatabaseService.instance.saveMoodEntry(entry);
      
      // Update activity usage in Realm
      for (final activity in entry.activities) {
        await RealmService.instance.updateActivityUsage(activity);
      }
      
      // Update daily statistics
      await _updateDailyStatistics(entry.timestamp);
      
      await _loadEntries();
    } catch (e) {
      debugPrint('Error adding mood entry: $e');
    }
  }
  
  Future<void> updateMoodEntry(String id, MoodEntry updatedEntry) async {
    try {
      await DatabaseService.instance.updateMoodEntry(updatedEntry);
      
      // Update activity usage in Realm
      for (final activity in updatedEntry.activities) {
        await RealmService.instance.updateActivityUsage(activity);
      }
      
      await _loadEntries();
    } catch (e) {
      debugPrint('Error updating mood entry: $e');
    }
  }
  
  Future<void> deleteMoodEntry(String id) async {
    try {
      await DatabaseService.instance.deleteMoodEntry(id);
      await _loadEntries();
    } catch (e) {
      debugPrint('Error deleting mood entry: $e');
    }
  }
  
  Future<void> clearEntries() async {
    try {
      await DatabaseService.instance.clearAllData();
      await RealmService.instance.clearAllData();
      await _loadEntries();
    } catch (e) {
      debugPrint('Error clearing entries: $e');
    }
  }
  
  // Alias for addMoodEntry for backward compatibility
  Future<void> addEntry(MoodEntry entry) async {
    await addMoodEntry(entry);
  }
  
  Future<MoodEntry?> getMoodEntryById(String id) async {
    try {
      return await DatabaseService.instance.getMoodEntryById(id);
    } catch (e) {
      debugPrint('Error getting mood entry: $e');
      return null;
    }
  }
  
  Future<List<MoodEntry>> getEntriesByDateRange(DateTime start, DateTime end) async {
    try {
      return await DatabaseService.instance.getMoodEntriesByDateRange(start, end);
    } catch (e) {
      debugPrint('Error getting entries by date range: $e');
      return [];
    }
  }
  
  Future<double> getAverageMood() async {
    try {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      return await DatabaseService.instance.getAverageMoodForPeriod(startOfYear, now);
    } catch (e) {
      debugPrint('Error getting average mood: $e');
      return 0.0;
    }
  }
  
  Future<MoodType?> getMostFrequentMood() async {
    try {
      final distribution = await DatabaseService.instance.getMoodDistribution();
      if (distribution.isEmpty) return null;
      
      // Check if all values are 0 (no entries)
      final hasEntries = distribution.values.any((count) => count > 0);
      if (!hasEntries) return null;
      
      return distribution.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    } catch (e) {
      debugPrint('Error getting most frequent mood: $e');
      return null;
    }
  }

  Future<Map<MoodType, int>> getMoodDistribution() async {
    try {
      return await DatabaseService.instance.getMoodDistribution();
    } catch (e) {
      debugPrint('Error getting mood distribution: $e');
      return {};
    }
  }

  Future<void> _updateDailyStatistics(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final dayEntries = await DatabaseService.instance.getMoodEntriesByDateRange(startOfDay, endOfDay);
      if (dayEntries.isEmpty) return;
      
      final averageMood = dayEntries.fold<double>(0, (sum, entry) => sum + entry.mood.value) / dayEntries.length;
      final moodCounts = <MoodType, int>{};
      
      for (final entry in dayEntries) {
        moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
      }
      
      final mostCommonMood = moodCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key.label;
      
      final totalSleepMinutes = dayEntries
          .where((e) => e.sleepDuration != null)
          .fold<int>(0, (sum, entry) => sum + entry.sleepDuration!.inMinutes);
      
      final allActivities = <String>[];
      for (final entry in dayEntries) {
        allActivities.addAll(entry.activities);
      }
      
      final activityCounts = <String, int>{};
      for (final activity in allActivities) {
        activityCounts[activity] = (activityCounts[activity] ?? 0) + 1;
      }
      
      final topActivities = activityCounts.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      await RealmService.instance.updateDailyStatistics(
        date: startOfDay,
        averageMood: averageMood,
        entryCount: dayEntries.length,
        mostCommonMood: mostCommonMood,
        totalSleepMinutes: totalSleepMinutes,
        topActivities: topActivities.take(5).map((e) => e.key).toList(),
      );
    } catch (e) {
      debugPrint('Error updating daily statistics: $e');
    }
  }
}