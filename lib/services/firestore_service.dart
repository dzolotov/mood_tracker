import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? get userId => _auth.currentUser?.uid;
  
  // Collection reference for mood entries
  CollectionReference<Map<String, dynamic>> get _moodEntriesCollection {
    if (userId == null) throw Exception('User not authenticated');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('moodEntries');
  }
  
  // Add or update mood entry
  Future<void> saveMoodEntry(MoodEntry entry) async {
    if (userId == null) {
      debugPrint('Cannot save to Firestore: user not authenticated');
      return;
    }
    
    try {
      await _moodEntriesCollection.doc(entry.id).set({
        'id': entry.id,
        'mood': entry.mood.value,
        'timestamp': Timestamp.fromDate(entry.timestamp),
        'note': entry.note,
        'activities': entry.activities,
        'sleepDurationMinutes': entry.sleepDuration?.inMinutes,
        'sleepTime': entry.sleepTime != null ? Timestamp.fromDate(entry.sleepTime!) : null,
        'wakeTime': entry.wakeTime != null ? Timestamp.fromDate(entry.wakeTime!) : null,
        'photoPath': entry.photoPath,
        'lastUpdated': FieldValue.serverTimestamp(),
        'userId': userId,
      });
      debugPrint('Mood entry saved to Firestore: ${entry.id}');
    } catch (e) {
      debugPrint('Error saving mood entry to Firestore: $e');
      rethrow;
    }
  }
  
  // Get all mood entries
  Future<List<MoodEntry>> getAllMoodEntries() async {
    if (userId == null) {
      debugPrint('Cannot read from Firestore: user not authenticated');
      return [];
    }
    
    try {
      final snapshot = await _moodEntriesCollection
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => _moodEntryFromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting mood entries from Firestore: $e');
      return [];
    }
  }
  
  // Get mood entries stream for real-time updates
  Stream<List<MoodEntry>> getMoodEntriesStream() {
    if (userId == null) {
      debugPrint('Cannot stream from Firestore: user not authenticated');
      return Stream.value([]);
    }
    
    return _moodEntriesCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => _moodEntryFromFirestore(doc)).toList()
        );
  }
  
  // Delete mood entry
  Future<void> deleteMoodEntry(String entryId) async {
    if (userId == null) {
      debugPrint('Cannot delete from Firestore: user not authenticated');
      return;
    }
    
    try {
      await _moodEntriesCollection.doc(entryId).delete();
      debugPrint('Mood entry deleted from Firestore: $entryId');
    } catch (e) {
      debugPrint('Error deleting mood entry from Firestore: $e');
    }
  }
  
  // Batch upload mood entries
  Future<void> batchUploadMoodEntries(List<MoodEntry> entries) async {
    if (userId == null) {
      debugPrint('Cannot batch upload to Firestore: user not authenticated');
      return;
    }
    
    try {
      final batch = _firestore.batch();
      
      for (final entry in entries) {
        final docRef = _moodEntriesCollection.doc(entry.id);
        batch.set(docRef, {
          'id': entry.id,
          'mood': entry.mood.value,
          'timestamp': Timestamp.fromDate(entry.timestamp),
          'note': entry.note,
          'activities': entry.activities,
          'sleepDurationMinutes': entry.sleepDuration?.inMinutes,
          'sleepTime': entry.sleepTime != null ? Timestamp.fromDate(entry.sleepTime!) : null,
          'wakeTime': entry.wakeTime != null ? Timestamp.fromDate(entry.wakeTime!) : null,
          'photoPath': entry.photoPath,
          'lastUpdated': FieldValue.serverTimestamp(),
          'userId': userId,
        });
      }
      
      await batch.commit();
      debugPrint('Batch uploaded ${entries.length} entries to Firestore');
    } catch (e) {
      debugPrint('Error batch uploading to Firestore: $e');
      rethrow;
    }
  }
  
  // Get entries by date range
  Future<List<MoodEntry>> getMoodEntriesByDateRange(DateTime start, DateTime end) async {
    if (userId == null) {
      debugPrint('Cannot query Firestore: user not authenticated');
      return [];
    }
    
    try {
      final snapshot = await _moodEntriesCollection
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => _moodEntryFromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error querying Firestore by date range: $e');
      return [];
    }
  }
  
  // Sync status
  Future<SyncStatus> getSyncStatus() async {
    if (userId == null) {
      return SyncStatus(
        lastSync: null,
        localCount: 0,
        cloudCount: 0,
        isSynced: false,
      );
    }
    
    try {
      // Get cloud count
      final cloudSnapshot = await _moodEntriesCollection.count().get();
      final cloudCount = cloudSnapshot.count ?? 0;
      
      // Get last sync timestamp
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final lastSync = userDoc.data()?['lastSync'] as Timestamp?;
      
      return SyncStatus(
        lastSync: lastSync?.toDate(),
        localCount: 0, // Will be set by MoodService
        cloudCount: cloudCount,
        isSynced: false, // Will be determined by MoodService
      );
    } catch (e) {
      debugPrint('Error getting sync status: $e');
      return SyncStatus(
        lastSync: null,
        localCount: 0,
        cloudCount: 0,
        isSynced: false,
      );
    }
  }
  
  // Update last sync timestamp
  Future<void> updateLastSync() async {
    if (userId == null) return;
    
    try {
      await _firestore.collection('users').doc(userId).set({
        'lastSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating last sync: $e');
    }
  }
  
  // Convert Firestore document to MoodEntry
  MoodEntry _moodEntryFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final timestamp = (data['timestamp'] as Timestamp).toDate();
    final sleepTime = data['sleepTime'] != null 
        ? (data['sleepTime'] as Timestamp).toDate() 
        : null;
    final wakeTime = data['wakeTime'] != null 
        ? (data['wakeTime'] as Timestamp).toDate() 
        : null;
    
    return MoodEntry(
      id: data['id'] as String,
      mood: MoodType.values.firstWhere((m) => m.value == data['mood']),
      timestamp: timestamp,
      note: data['note'] as String?,
      activities: List<String>.from(data['activities'] ?? []),
      sleepDuration: data['sleepDurationMinutes'] != null
          ? Duration(minutes: data['sleepDurationMinutes'] as int)
          : null,
      sleepTime: sleepTime,
      wakeTime: wakeTime,
      photoPath: data['photoPath'] as String?,
    );
  }
}

class SyncStatus {
  final DateTime? lastSync;
  final int localCount;
  final int cloudCount;
  final bool isSynced;
  
  SyncStatus({
    required this.lastSync,
    required this.localCount,
    required this.cloudCount,
    required this.isSynced,
  });
}