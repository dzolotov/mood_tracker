// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class TagModel extends _TagModel
    with RealmEntity, RealmObjectBase, RealmObject {
  TagModel(
    String name,
    String color,
    DateTime createdAt,
    int usageCount, {
    String? description,
  }) {
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'color', color);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'usageCount', usageCount);
    RealmObjectBase.set(this, 'description', description);
  }

  TagModel._();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get color => RealmObjectBase.get<String>(this, 'color') as String;
  @override
  set color(String value) => RealmObjectBase.set(this, 'color', value);

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
  Stream<RealmObjectChanges<TagModel>> get changes =>
      RealmObjectBase.getChanges<TagModel>(this);

  @override
  Stream<RealmObjectChanges<TagModel>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<TagModel>(this, keyPaths);

  @override
  TagModel freeze() => RealmObjectBase.freezeObject<TagModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'name': name.toEJson(),
      'color': color.toEJson(),
      'createdAt': createdAt.toEJson(),
      'usageCount': usageCount.toEJson(),
      'description': description.toEJson(),
    };
  }

  static EJsonValue _toEJson(TagModel value) => value.toEJson();
  static TagModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'name': EJsonValue name,
        'color': EJsonValue color,
        'createdAt': EJsonValue createdAt,
        'usageCount': EJsonValue usageCount,
      } =>
        TagModel(
          fromEJson(name),
          fromEJson(color),
          fromEJson(createdAt),
          fromEJson(usageCount),
          description: fromEJson(ejson['description']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TagModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, TagModel, 'TagModel', [
      SchemaProperty('name', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('color', RealmPropertyType.string),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
      SchemaProperty('usageCount', RealmPropertyType.int),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}