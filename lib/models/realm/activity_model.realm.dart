// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class ActivityModel extends _ActivityModel
    with RealmEntity, RealmObjectBase, RealmObject {
  ActivityModel(
    String name,
    String category,
    DateTime createdAt,
    int usageCount, {
    String? description,
    String? iconCode,
  }) {
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'category', category);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'usageCount', usageCount);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'iconCode', iconCode);
  }

  ActivityModel._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get category =>
      RealmObjectBase.get<String>(this, 'category') as String;
  @override
  set category(String value) => RealmObjectBase.set(this, 'category', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  int get usageCount => RealmObjectBase.get<int>(this, 'usageCount') as int;
  @override
  set usageCount(int value) => RealmObjectBase.set(this, 'usageCount', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get iconCode =>
      RealmObjectBase.get<String>(this, 'iconCode') as String?;
  @override
  set iconCode(String? value) => RealmObjectBase.set(this, 'iconCode', value);

  @override
  Stream<RealmObjectChanges<ActivityModel>> get changes =>
      RealmObjectBase.getChanges<ActivityModel>(this);

  @override
  Stream<RealmObjectChanges<ActivityModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<ActivityModel>(this, keyPaths);

  @override
  ActivityModel freeze() => RealmObjectBase.freezeObject<ActivityModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
      'category': category.toEJson(),
      'createdAt': createdAt.toEJson(),
      'usageCount': usageCount.toEJson(),
      'description': description.toEJson(),
      'iconCode': iconCode.toEJson(),
    };
  }

  static EJsonValue _toEJson(ActivityModel value) => value.toEJson();
  static ActivityModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'name': EJsonValue name,
        'category': EJsonValue category,
        'createdAt': EJsonValue createdAt,
        'usageCount': EJsonValue usageCount,
      } =>
        ActivityModel(
          fromEJson(name),
          fromEJson(category),
          fromEJson(createdAt),
          fromEJson(usageCount),
          description: fromEJson(ejson['description']),
          iconCode: fromEJson(ejson['iconCode']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ActivityModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      ActivityModel,
      'ActivityModel',
      [
        SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('category', RealmPropertyType.string),
        SchemaProperty('createdAt', RealmPropertyType.timestamp),
        SchemaProperty('usageCount', RealmPropertyType.int),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty('iconCode', RealmPropertyType.string, optional: true),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
