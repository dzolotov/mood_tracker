import 'package:realm/realm.dart';
import '../models/realm/activity_model.dart';
import '../models/realm/tag_model.dart';
import '../models/realm/statistics_model.dart';

class RealmService {
  static RealmService? _instance;
  static Realm? _realm;

  RealmService._();

  static RealmService get instance {
    _instance ??= RealmService._();
    return _instance!;
  }

  static Future<void> initialize() async {
    if (_realm != null) return;
    
    final config = Configuration.local([
      ActivityModel.schema,
      TagModel.schema,
      StatisticsModel.schema,
    ]);
    
    _realm = Realm(config);
  }

  Realm get realm {
    if (_realm == null) {
      throw StateError('RealmService not initialized. Call initialize() first.');
    }
    return _realm!;
  }

  // Activity operations
  Future<void> saveActivity(ActivityModel activity) async {
    realm.write(() {
      realm.add(activity);
    });
  }

  Future<List<ActivityModel>> getAllActivities() async {
    return realm.all<ActivityModel>().toList();
  }

  Future<ActivityModel?> getActivityByName(String name) async {
    return realm.find<ActivityModel>(name);
  }

  Future<void> updateActivityUsage(String activityName) async {
    final activity = realm.query<ActivityModel>('name == \$0', [activityName]).firstOrNull;
    if (activity != null) {
      realm.write(() {
        activity.usageCount++;
      });
    } else {
      // Create new activity if it doesn't exist
      final newActivity = ActivityModel(
        activityName,
        'user_defined',
        DateTime.now(),
        1,
      );
      realm.write(() {
        realm.add(newActivity);
      });
    }
  }

  Future<List<ActivityModel>> getMostUsedActivities(int limit) async {
    return realm.query<ActivityModel>('TRUEPREDICATE SORT(usageCount DESC)')
        .take(limit)
        .toList();
  }

  // Tag operations
  Future<void> saveTag(TagModel tag) async {
    realm.write(() {
      realm.add(tag);
    });
  }

  Future<List<TagModel>> getAllTags() async {
    return realm.all<TagModel>().toList();
  }

  Future<void> updateTagUsage(String tagName) async {
    final tag = realm.query<TagModel>('name == \$0', [tagName]).firstOrNull;
    if (tag != null) {
      realm.write(() {
        tag.usageCount++;
      });
    }
  }

  // Statistics operations
  Future<void> saveStatistics(StatisticsModel stats) async {
    realm.write(() {
      realm.add(stats, update: true);
    });
  }

  Future<StatisticsModel?> getStatistics(String id) async {
    return realm.find<StatisticsModel>(id);
  }

  Future<List<StatisticsModel>> getStatisticsByType(String type) async {
    return realm.query<StatisticsModel>('type == \$0 SORT(date DESC)', [type]).toList();
  }

  Future<StatisticsModel?> getLatestStatistics(String type) async {
    return realm.query<StatisticsModel>('type == \$0 SORT(date DESC)', [type]).firstOrNull;
  }

  Future<void> updateDailyStatistics({
    required DateTime date,
    required double averageMood,
    required int entryCount,
    required String mostCommonMood,
    required int totalSleepMinutes,
    required List<String> topActivities,
  }) async {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final id = 'daily_$dateKey';
    
    final stats = StatisticsModel(
      id,
      'daily',
      date,
      averageMood,
      entryCount,
      mostCommonMood,
      totalSleepMinutes,
      _encodeActivities(topActivities),
      DateTime.now(),
    );
    
    realm.write(() {
      realm.add(stats, update: true);
    });
  }

  Future<void> updateWeeklyStatistics({
    required DateTime weekStart,
    required double averageMood,
    required int entryCount,
    required String mostCommonMood,
    required int totalSleepMinutes,
    required List<String> topActivities,
  }) async {
    final weekKey = '${weekStart.year}-W${_getWeekNumber(weekStart)}';
    final id = 'weekly_$weekKey';
    
    final stats = StatisticsModel(
      id,
      'weekly',
      weekStart,
      averageMood,
      entryCount,
      mostCommonMood,
      totalSleepMinutes,
      _encodeActivities(topActivities),
      DateTime.now(),
    );
    
    realm.write(() {
      realm.add(stats, update: true);
    });
  }

  Future<void> updateMonthlyStatistics({
    required DateTime month,
    required double averageMood,
    required int entryCount,
    required String mostCommonMood,
    required int totalSleepMinutes,
    required List<String> topActivities,
  }) async {
    final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    final id = 'monthly_$monthKey';
    
    final stats = StatisticsModel(
      id,
      'monthly',
      month,
      averageMood,
      entryCount,
      mostCommonMood,
      totalSleepMinutes,
      _encodeActivities(topActivities),
      DateTime.now(),
    );
    
    realm.write(() {
      realm.add(stats, update: true);
    });
  }

  Future<void> clearAllData() async {
    realm.write(() {
      realm.deleteAll<ActivityModel>();
      realm.deleteAll<TagModel>();
      realm.deleteAll<StatisticsModel>();
    });
  }

  void dispose() {
    _realm?.close();
    _realm = null;
  }

  // Helper methods
  String _encodeActivities(List<String> activities) {
    return activities.map((a) => '"$a"').join(',');
  }

  List<String> _decodeActivities(String encoded) {
    if (encoded.isEmpty || encoded == '[]') return [];
    return encoded
        .split(',')
        .map((a) => a.trim().replaceAll('"', ''))
        .where((a) => a.isNotEmpty)
        .toList();
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return (daysDifference / 7).ceil() + 1;
  }
}