import 'package:realm/realm.dart';

part 'statistics_model.realm.dart';

@RealmModel()
class _StatisticsModel {
  @PrimaryKey()
  late String id;
  late String type; // 'daily', 'weekly', 'monthly'
  late DateTime date;
  late double averageMood;
  late int entryCount;
  late String mostCommonMood;
  late int totalSleepMinutes;
  late String topActivities; // JSON encoded
  late DateTime lastUpdated;
}