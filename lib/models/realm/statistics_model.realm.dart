// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class StatisticsModel extends _StatisticsModel
    with RealmEntity, RealmObjectBase, RealmObject {
  StatisticsModel(
    String id,
    String type,
    DateTime date,
    double averageMood,
    int entryCount,
    String mostCommonMood,
    int totalSleepMinutes,
    String topActivities,
    DateTime lastUpdated,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'averageMood', averageMood);
    RealmObjectBase.set(this, 'entryCount', entryCount);
    RealmObjectBase.set(this, 'mostCommonMood', mostCommonMood);
    RealmObjectBase.set(this, 'totalSleepMinutes', totalSleepMinutes);
    RealmObjectBase.set(this, 'topActivities', topActivities);
    RealmObjectBase.set(this, 'lastUpdated', lastUpdated);
  }

  StatisticsModel._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  double get averageMood =>
      RealmObjectBase.get<double>(this, 'averageMood') as double;
  @override
  set averageMood(double value) =>
      RealmObjectBase.set(this, 'averageMood', value);

  @override
  int get entryCount => RealmObjectBase.get<int>(this, 'entryCount') as int;
  @override
  set entryCount(int value) => RealmObjectBase.set(this, 'entryCount', value);

  @override
  String get mostCommonMood =>
      RealmObjectBase.get<String>(this, 'mostCommonMood') as String;
  @override
  set mostCommonMood(String value) =>
      RealmObjectBase.set(this, 'mostCommonMood', value);

  @override
  int get totalSleepMinutes =>
      RealmObjectBase.get<int>(this, 'totalSleepMinutes') as int;
  @override
  set totalSleepMinutes(int value) =>
      RealmObjectBase.set(this, 'totalSleepMinutes', value);

  @override
  String get topActivities =>
      RealmObjectBase.get<String>(this, 'topActivities') as String;
  @override
  set topActivities(String value) =>
      RealmObjectBase.set(this, 'topActivities', value);

  @override
  DateTime get lastUpdated =>
      RealmObjectBase.get<DateTime>(this, 'lastUpdated') as DateTime;
  @override
  set lastUpdated(DateTime value) =>
      RealmObjectBase.set(this, 'lastUpdated', value);

  @override
  Stream<RealmObjectChanges<StatisticsModel>> get changes =>
      RealmObjectBase.getChanges<StatisticsModel>(this);

  @override
  Stream<RealmObjectChanges<StatisticsModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<StatisticsModel>(this, keyPaths);

  @override
  StatisticsModel freeze() =>
      RealmObjectBase.freezeObject<StatisticsModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'type': type.toEJson(),
      'date': date.toEJson(),
      'averageMood': averageMood.toEJson(),
      'entryCount': entryCount.toEJson(),
      'mostCommonMood': mostCommonMood.toEJson(),
      'totalSleepMinutes': totalSleepMinutes.toEJson(),
      'topActivities': topActivities.toEJson(),
      'lastUpdated': lastUpdated.toEJson(),
    };
  }

  static EJsonValue _toEJson(StatisticsModel value) => value.toEJson();
  static StatisticsModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'type': EJsonValue type,
        'date': EJsonValue date,
        'averageMood': EJsonValue averageMood,
        'entryCount': EJsonValue entryCount,
        'mostCommonMood': EJsonValue mostCommonMood,
        'totalSleepMinutes': EJsonValue totalSleepMinutes,
        'topActivities': EJsonValue topActivities,
        'lastUpdated': EJsonValue lastUpdated,
      } =>
        StatisticsModel(
          fromEJson(id),
          fromEJson(type),
          fromEJson(date),
          fromEJson(averageMood),
          fromEJson(entryCount),
          fromEJson(mostCommonMood),
          fromEJson(totalSleepMinutes),
          fromEJson(topActivities),
          fromEJson(lastUpdated),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(StatisticsModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      StatisticsModel,
      'StatisticsModel',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty('date', RealmPropertyType.timestamp),
        SchemaProperty('averageMood', RealmPropertyType.double),
        SchemaProperty('entryCount', RealmPropertyType.int),
        SchemaProperty('mostCommonMood', RealmPropertyType.string),
        SchemaProperty('totalSleepMinutes', RealmPropertyType.int),
        SchemaProperty('topActivities', RealmPropertyType.string),
        SchemaProperty('lastUpdated', RealmPropertyType.timestamp),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
