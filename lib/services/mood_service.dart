import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';

class MoodService extends ChangeNotifier {
  final List<MoodEntry> _entries = [];
  
  List<MoodEntry> get entries => List.unmodifiable(_entries);
  
  void addMoodEntry(MoodEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }
  
  void updateMoodEntry(String id, MoodEntry updatedEntry) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      _entries[index] = updatedEntry;
      notifyListeners();
    }
  }
  
  void deleteMoodEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }
  
  MoodEntry? getMoodEntryById(String id) {
    try {
      return _entries.firstWhere((entry) => entry.id == id);
    } catch (_) {
      return null;
    }
  }
  
  List<MoodEntry> getEntriesByDateRange(DateTime start, DateTime end) {
    return _entries.where((entry) {
      return entry.timestamp.isAfter(start) && 
             entry.timestamp.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
  
  double getAverageMood() {
    if (_entries.isEmpty) return 0;
    final sum = _entries.fold(0, (sum, entry) => sum + entry.mood.value);
    return sum / _entries.length;
  }
  
  MoodType? getMostFrequentMood() {
    if (_entries.isEmpty) return null;
    
    final moodCounts = <MoodType, int>{};
    for (final entry in _entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }
    
    return moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}