import 'dart:io';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../models/mood_entry.dart';

class CloudStorageService {
  static final CloudStorageService _instance = CloudStorageService._internal();
  factory CloudStorageService() => _instance;
  CloudStorageService._internal();
  
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? get userId => _auth.currentUser?.uid;
  
  // Photo operations
  Future<String?> uploadPhoto(File photoFile) async {
    if (userId == null) {
      debugPrint('Cannot upload photo: user not authenticated');
      return null;
    }
    
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(photoFile.path)}';
      final ref = _storage.ref().child('users/$userId/photos/$fileName');
      
      final uploadTask = ref.putFile(photoFile);
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        debugPrint('Upload progress: ${progress.toStringAsFixed(2)}%');
      });
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('Photo uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      return null;
    }
  }
  
  Future<File?> downloadPhoto(String photoUrl, String localPath) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      final file = File(localPath);
      
      await ref.writeToFile(file);
      debugPrint('Photo downloaded successfully to: $localPath');
      return file;
    } catch (e) {
      debugPrint('Error downloading photo: $e');
      return null;
    }
  }
  
  Future<bool> deletePhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
      debugPrint('Photo deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      return false;
    }
  }
  
  // Backup operations
  Future<bool> backupMoodEntries(List<MoodEntry> entries) async {
    if (userId == null) {
      debugPrint('Cannot backup: user not authenticated');
      return false;
    }
    
    try {
      final timestamp = DateTime.now().toIso8601String();
      final backupData = {
        'version': 1,
        'timestamp': timestamp,
        'entries': entries.map((e) => e.toJson()).toList(),
      };
      
      final jsonData = jsonEncode(backupData);
      final bytes = utf8.encode(jsonData);
      
      final ref = _storage.ref().child('users/$userId/backups/mood_backup_$timestamp.json');
      await ref.putData(Uint8List.fromList(bytes));
      
      debugPrint('Backup completed successfully');
      return true;
    } catch (e) {
      debugPrint('Error creating backup: $e');
      return false;
    }
  }
  
  Future<List<MoodEntry>?> restoreLatestBackup() async {
    if (userId == null) {
      debugPrint('Cannot restore: user not authenticated');
      return null;
    }
    
    try {
      final backupsRef = _storage.ref().child('users/$userId/backups');
      final listResult = await backupsRef.listAll();
      
      if (listResult.items.isEmpty) {
        debugPrint('No backups found');
        return null;
      }
      
      // Sort by name (which includes timestamp) to get latest
      listResult.items.sort((a, b) => b.name.compareTo(a.name));
      final latestBackupRef = listResult.items.first;
      
      final data = await latestBackupRef.getData();
      if (data == null) return null;
      
      final jsonString = utf8.decode(data);
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      final entriesJson = backupData['entries'] as List;
      final entries = entriesJson.map((json) => MoodEntry.fromJson(json)).toList();
      
      debugPrint('Restored ${entries.length} entries from backup');
      return entries;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      return null;
    }
  }
  
  Future<List<BackupInfo>> listBackups() async {
    if (userId == null) {
      debugPrint('Cannot list backups: user not authenticated');
      return [];
    }
    
    try {
      final backupsRef = _storage.ref().child('users/$userId/backups');
      final listResult = await backupsRef.listAll();
      
      final backups = <BackupInfo>[];
      for (final item in listResult.items) {
        final metadata = await item.getMetadata();
        backups.add(BackupInfo(
          name: item.name,
          path: item.fullPath,
          size: metadata.size ?? 0,
          createdAt: metadata.timeCreated ?? DateTime.now(),
        ));
      }
      
      // Sort by creation date, newest first
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return backups;
    } catch (e) {
      debugPrint('Error listing backups: $e');
      return [];
    }
  }
  
  Future<bool> deleteBackup(String backupPath) async {
    try {
      final ref = _storage.ref().child(backupPath);
      await ref.delete();
      debugPrint('Backup deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting backup: $e');
      return false;
    }
  }
  
  // Sync operations
  Future<bool> uploadSyncData(Map<String, dynamic> syncData) async {
    if (userId == null) {
      debugPrint('Cannot sync: user not authenticated');
      return false;
    }
    
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      syncData['lastSync'] = timestamp;
      syncData['userId'] = userId;
      
      final jsonData = jsonEncode(syncData);
      final bytes = utf8.encode(jsonData);
      
      final ref = _storage.ref().child('users/$userId/sync/mood_data.json');
      await ref.putData(Uint8List.fromList(bytes));
      
      debugPrint('Sync data uploaded successfully');
      return true;
    } catch (e) {
      debugPrint('Error uploading sync data: $e');
      return false;
    }
  }
  
  Future<Map<String, dynamic>?> downloadSyncData() async {
    if (userId == null) {
      debugPrint('Cannot download sync: user not authenticated');
      return null;
    }
    
    try {
      final ref = _storage.ref().child('users/$userId/sync/mood_data.json');
      final data = await ref.getData();
      
      if (data == null) return null;
      
      final jsonString = utf8.decode(data);
      final syncData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      debugPrint('Sync data downloaded successfully');
      return syncData;
    } catch (e) {
      debugPrint('Error downloading sync data: $e');
      return null;
    }
  }
  
  // Storage usage
  Future<StorageUsage> getStorageUsage() async {
    if (userId == null) {
      return StorageUsage(photosSize: 0, backupsSize: 0, totalSize: 0);
    }
    
    try {
      int photosSize = 0;
      int backupsSize = 0;
      
      // Calculate photos size
      final photosRef = _storage.ref().child('users/$userId/photos');
      final photosResult = await photosRef.listAll();
      for (final item in photosResult.items) {
        final metadata = await item.getMetadata();
        photosSize += metadata.size ?? 0;
      }
      
      // Calculate backups size
      final backupsRef = _storage.ref().child('users/$userId/backups');
      final backupsResult = await backupsRef.listAll();
      for (final item in backupsResult.items) {
        final metadata = await item.getMetadata();
        backupsSize += metadata.size ?? 0;
      }
      
      return StorageUsage(
        photosSize: photosSize,
        backupsSize: backupsSize,
        totalSize: photosSize + backupsSize,
      );
    } catch (e) {
      debugPrint('Error calculating storage usage: $e');
      return StorageUsage(photosSize: 0, backupsSize: 0, totalSize: 0);
    }
  }
}

class BackupInfo {
  final String name;
  final String path;
  final int size;
  final DateTime createdAt;
  
  BackupInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.createdAt,
  });
}

class StorageUsage {
  final int photosSize;
  final int backupsSize;
  final int totalSize;
  
  StorageUsage({
    required this.photosSize,
    required this.backupsSize,
    required this.totalSize,
  });
  
  String get photosSizeFormatted => _formatBytes(photosSize);
  String get backupsSizeFormatted => _formatBytes(backupsSize);
  String get totalSizeFormatted => _formatBytes(totalSize);
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}