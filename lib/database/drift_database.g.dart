// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $MoodEntriesTable extends MoodEntries
    with TableInfo<$MoodEntriesTable, MoodEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _moodValueMeta = const VerificationMeta(
    'moodValue',
  );
  @override
  late final GeneratedColumn<int> moodValue = GeneratedColumn<int>(
    'mood_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    moodValue,
    timestamp,
    note,
    photoPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mood_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoodEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('mood_value')) {
      context.handle(
        _moodValueMeta,
        moodValue.isAcceptableOrUnknown(data['mood_value']!, _moodValueMeta),
      );
    } else if (isInserting) {
      context.missing(_moodValueMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoodEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodEntry(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      entryId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entry_id'],
          )!,
      moodValue:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}mood_value'],
          )!,
      timestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}timestamp'],
          )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $MoodEntriesTable createAlias(String alias) {
    return $MoodEntriesTable(attachedDatabase, alias);
  }
}

class MoodEntry extends DataClass implements Insertable<MoodEntry> {
  final int id;
  final String entryId;
  final int moodValue;
  final DateTime timestamp;
  final String? note;
  final String? photoPath;
  final DateTime createdAt;
  const MoodEntry({
    required this.id,
    required this.entryId,
    required this.moodValue,
    required this.timestamp,
    this.note,
    this.photoPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_id'] = Variable<String>(entryId);
    map['mood_value'] = Variable<int>(moodValue);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MoodEntriesCompanion toCompanion(bool nullToAbsent) {
    return MoodEntriesCompanion(
      id: Value(id),
      entryId: Value(entryId),
      moodValue: Value(moodValue),
      timestamp: Value(timestamp),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      photoPath:
          photoPath == null && nullToAbsent
              ? const Value.absent()
              : Value(photoPath),
      createdAt: Value(createdAt),
    );
  }

  factory MoodEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodEntry(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<String>(json['entryId']),
      moodValue: serializer.fromJson<int>(json['moodValue']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      note: serializer.fromJson<String?>(json['note']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<String>(entryId),
      'moodValue': serializer.toJson<int>(moodValue),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'note': serializer.toJson<String?>(note),
      'photoPath': serializer.toJson<String?>(photoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MoodEntry copyWith({
    int? id,
    String? entryId,
    int? moodValue,
    DateTime? timestamp,
    Value<String?> note = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    DateTime? createdAt,
  }) => MoodEntry(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    moodValue: moodValue ?? this.moodValue,
    timestamp: timestamp ?? this.timestamp,
    note: note.present ? note.value : this.note,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    createdAt: createdAt ?? this.createdAt,
  );
  MoodEntry copyWithCompanion(MoodEntriesCompanion data) {
    return MoodEntry(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      moodValue: data.moodValue.present ? data.moodValue.value : this.moodValue,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      note: data.note.present ? data.note.value : this.note,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodEntry(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('moodValue: $moodValue, ')
          ..write('timestamp: $timestamp, ')
          ..write('note: $note, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entryId,
    moodValue,
    timestamp,
    note,
    photoPath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodEntry &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.moodValue == this.moodValue &&
          other.timestamp == this.timestamp &&
          other.note == this.note &&
          other.photoPath == this.photoPath &&
          other.createdAt == this.createdAt);
}

class MoodEntriesCompanion extends UpdateCompanion<MoodEntry> {
  final Value<int> id;
  final Value<String> entryId;
  final Value<int> moodValue;
  final Value<DateTime> timestamp;
  final Value<String?> note;
  final Value<String?> photoPath;
  final Value<DateTime> createdAt;
  const MoodEntriesCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.moodValue = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.note = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MoodEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String entryId,
    required int moodValue,
    required DateTime timestamp,
    this.note = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : entryId = Value(entryId),
       moodValue = Value(moodValue),
       timestamp = Value(timestamp);
  static Insertable<MoodEntry> custom({
    Expression<int>? id,
    Expression<String>? entryId,
    Expression<int>? moodValue,
    Expression<DateTime>? timestamp,
    Expression<String>? note,
    Expression<String>? photoPath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (moodValue != null) 'mood_value': moodValue,
      if (timestamp != null) 'timestamp': timestamp,
      if (note != null) 'note': note,
      if (photoPath != null) 'photo_path': photoPath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MoodEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? entryId,
    Value<int>? moodValue,
    Value<DateTime>? timestamp,
    Value<String?>? note,
    Value<String?>? photoPath,
    Value<DateTime>? createdAt,
  }) {
    return MoodEntriesCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      moodValue: moodValue ?? this.moodValue,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (moodValue.present) {
      map['mood_value'] = Variable<int>(moodValue.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodEntriesCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('moodValue: $moodValue, ')
          ..write('timestamp: $timestamp, ')
          ..write('note: $note, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SleepRecordsTable extends SleepRecords
    with TableInfo<$SleepRecordsTable, SleepRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mood_entries (entry_id)',
    ),
  );
  static const VerificationMeta _sleepTimeMeta = const VerificationMeta(
    'sleepTime',
  );
  @override
  late final GeneratedColumn<DateTime> sleepTime = GeneratedColumn<DateTime>(
    'sleep_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wakeTimeMeta = const VerificationMeta(
    'wakeTime',
  );
  @override
  late final GeneratedColumn<DateTime> wakeTime = GeneratedColumn<DateTime>(
    'wake_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualityRatingMeta = const VerificationMeta(
    'qualityRating',
  );
  @override
  late final GeneratedColumn<int> qualityRating = GeneratedColumn<int>(
    'quality_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    sleepTime,
    wakeTime,
    durationMinutes,
    qualityRating,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('sleep_time')) {
      context.handle(
        _sleepTimeMeta,
        sleepTime.isAcceptableOrUnknown(data['sleep_time']!, _sleepTimeMeta),
      );
    }
    if (data.containsKey('wake_time')) {
      context.handle(
        _wakeTimeMeta,
        wakeTime.isAcceptableOrUnknown(data['wake_time']!, _wakeTimeMeta),
      );
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('quality_rating')) {
      context.handle(
        _qualityRatingMeta,
        qualityRating.isAcceptableOrUnknown(
          data['quality_rating']!,
          _qualityRatingMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepRecord(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      entryId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entry_id'],
          )!,
      sleepTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sleep_time'],
      ),
      wakeTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}wake_time'],
      ),
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      ),
      qualityRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quality_rating'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $SleepRecordsTable createAlias(String alias) {
    return $SleepRecordsTable(attachedDatabase, alias);
  }
}

class SleepRecord extends DataClass implements Insertable<SleepRecord> {
  final int id;
  final String entryId;
  final DateTime? sleepTime;
  final DateTime? wakeTime;
  final int? durationMinutes;
  final int? qualityRating;
  final String? notes;
  final DateTime createdAt;
  const SleepRecord({
    required this.id,
    required this.entryId,
    this.sleepTime,
    this.wakeTime,
    this.durationMinutes,
    this.qualityRating,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_id'] = Variable<String>(entryId);
    if (!nullToAbsent || sleepTime != null) {
      map['sleep_time'] = Variable<DateTime>(sleepTime);
    }
    if (!nullToAbsent || wakeTime != null) {
      map['wake_time'] = Variable<DateTime>(wakeTime);
    }
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    if (!nullToAbsent || qualityRating != null) {
      map['quality_rating'] = Variable<int>(qualityRating);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SleepRecordsCompanion toCompanion(bool nullToAbsent) {
    return SleepRecordsCompanion(
      id: Value(id),
      entryId: Value(entryId),
      sleepTime:
          sleepTime == null && nullToAbsent
              ? const Value.absent()
              : Value(sleepTime),
      wakeTime:
          wakeTime == null && nullToAbsent
              ? const Value.absent()
              : Value(wakeTime),
      durationMinutes:
          durationMinutes == null && nullToAbsent
              ? const Value.absent()
              : Value(durationMinutes),
      qualityRating:
          qualityRating == null && nullToAbsent
              ? const Value.absent()
              : Value(qualityRating),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory SleepRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepRecord(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<String>(json['entryId']),
      sleepTime: serializer.fromJson<DateTime?>(json['sleepTime']),
      wakeTime: serializer.fromJson<DateTime?>(json['wakeTime']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      qualityRating: serializer.fromJson<int?>(json['qualityRating']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<String>(entryId),
      'sleepTime': serializer.toJson<DateTime?>(sleepTime),
      'wakeTime': serializer.toJson<DateTime?>(wakeTime),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'qualityRating': serializer.toJson<int?>(qualityRating),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SleepRecord copyWith({
    int? id,
    String? entryId,
    Value<DateTime?> sleepTime = const Value.absent(),
    Value<DateTime?> wakeTime = const Value.absent(),
    Value<int?> durationMinutes = const Value.absent(),
    Value<int?> qualityRating = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => SleepRecord(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    sleepTime: sleepTime.present ? sleepTime.value : this.sleepTime,
    wakeTime: wakeTime.present ? wakeTime.value : this.wakeTime,
    durationMinutes:
        durationMinutes.present ? durationMinutes.value : this.durationMinutes,
    qualityRating:
        qualityRating.present ? qualityRating.value : this.qualityRating,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  SleepRecord copyWithCompanion(SleepRecordsCompanion data) {
    return SleepRecord(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      sleepTime: data.sleepTime.present ? data.sleepTime.value : this.sleepTime,
      wakeTime: data.wakeTime.present ? data.wakeTime.value : this.wakeTime,
      durationMinutes:
          data.durationMinutes.present
              ? data.durationMinutes.value
              : this.durationMinutes,
      qualityRating:
          data.qualityRating.present
              ? data.qualityRating.value
              : this.qualityRating,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepRecord(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('sleepTime: $sleepTime, ')
          ..write('wakeTime: $wakeTime, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('qualityRating: $qualityRating, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entryId,
    sleepTime,
    wakeTime,
    durationMinutes,
    qualityRating,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepRecord &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.sleepTime == this.sleepTime &&
          other.wakeTime == this.wakeTime &&
          other.durationMinutes == this.durationMinutes &&
          other.qualityRating == this.qualityRating &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class SleepRecordsCompanion extends UpdateCompanion<SleepRecord> {
  final Value<int> id;
  final Value<String> entryId;
  final Value<DateTime?> sleepTime;
  final Value<DateTime?> wakeTime;
  final Value<int?> durationMinutes;
  final Value<int?> qualityRating;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const SleepRecordsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.sleepTime = const Value.absent(),
    this.wakeTime = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.qualityRating = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SleepRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String entryId,
    this.sleepTime = const Value.absent(),
    this.wakeTime = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.qualityRating = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : entryId = Value(entryId);
  static Insertable<SleepRecord> custom({
    Expression<int>? id,
    Expression<String>? entryId,
    Expression<DateTime>? sleepTime,
    Expression<DateTime>? wakeTime,
    Expression<int>? durationMinutes,
    Expression<int>? qualityRating,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (sleepTime != null) 'sleep_time': sleepTime,
      if (wakeTime != null) 'wake_time': wakeTime,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (qualityRating != null) 'quality_rating': qualityRating,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SleepRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? entryId,
    Value<DateTime?>? sleepTime,
    Value<DateTime?>? wakeTime,
    Value<int?>? durationMinutes,
    Value<int?>? qualityRating,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return SleepRecordsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      sleepTime: sleepTime ?? this.sleepTime,
      wakeTime: wakeTime ?? this.wakeTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      qualityRating: qualityRating ?? this.qualityRating,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (sleepTime.present) {
      map['sleep_time'] = Variable<DateTime>(sleepTime.value);
    }
    if (wakeTime.present) {
      map['wake_time'] = Variable<DateTime>(wakeTime.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (qualityRating.present) {
      map['quality_rating'] = Variable<int>(qualityRating.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepRecordsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('sleepTime: $sleepTime, ')
          ..write('wakeTime: $wakeTime, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('qualityRating: $qualityRating, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#2196F3'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<String> iconCode = GeneratedColumn<String>(
    'icon_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usageCountMeta = const VerificationMeta(
    'usageCount',
  );
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
    'usage_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    color,
    description,
    iconCode,
    usageCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Activity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    }
    if (data.containsKey('usage_count')) {
      context.handle(
        _usageCountMeta,
        usageCount.isAcceptableOrUnknown(data['usage_count']!, _usageCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      category:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}category'],
          )!,
      color:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}color'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_code'],
      ),
      usageCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}usage_count'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class Activity extends DataClass implements Insertable<Activity> {
  final int id;
  final String name;
  final String category;
  final String color;
  final String? description;
  final String? iconCode;
  final int usageCount;
  final DateTime createdAt;
  const Activity({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    this.description,
    this.iconCode,
    required this.usageCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || iconCode != null) {
      map['icon_code'] = Variable<String>(iconCode);
    }
    map['usage_count'] = Variable<int>(usageCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      color: Value(color),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      iconCode:
          iconCode == null && nullToAbsent
              ? const Value.absent()
              : Value(iconCode),
      usageCount: Value(usageCount),
      createdAt: Value(createdAt),
    );
  }

  factory Activity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      color: serializer.fromJson<String>(json['color']),
      description: serializer.fromJson<String?>(json['description']),
      iconCode: serializer.fromJson<String?>(json['iconCode']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'color': serializer.toJson<String>(color),
      'description': serializer.toJson<String?>(description),
      'iconCode': serializer.toJson<String?>(iconCode),
      'usageCount': serializer.toJson<int>(usageCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Activity copyWith({
    int? id,
    String? name,
    String? category,
    String? color,
    Value<String?> description = const Value.absent(),
    Value<String?> iconCode = const Value.absent(),
    int? usageCount,
    DateTime? createdAt,
  }) => Activity(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    color: color ?? this.color,
    description: description.present ? description.value : this.description,
    iconCode: iconCode.present ? iconCode.value : this.iconCode,
    usageCount: usageCount ?? this.usageCount,
    createdAt: createdAt ?? this.createdAt,
  );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      color: data.color.present ? data.color.value : this.color,
      description:
          data.description.present ? data.description.value : this.description,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      usageCount:
          data.usageCount.present ? data.usageCount.value : this.usageCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('color: $color, ')
          ..write('description: $description, ')
          ..write('iconCode: $iconCode, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    color,
    description,
    iconCode,
    usageCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.color == this.color &&
          other.description == this.description &&
          other.iconCode == this.iconCode &&
          other.usageCount == this.usageCount &&
          other.createdAt == this.createdAt);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> color;
  final Value<String?> description;
  final Value<String?> iconCode;
  final Value<int> usageCount;
  final Value<DateTime> createdAt;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.color = const Value.absent(),
    this.description = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String category,
    this.color = const Value.absent(),
    this.description = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       category = Value(category);
  static Insertable<Activity> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? color,
    Expression<String>? description,
    Expression<String>? iconCode,
    Expression<int>? usageCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (color != null) 'color': color,
      if (description != null) 'description': description,
      if (iconCode != null) 'icon_code': iconCode,
      if (usageCount != null) 'usage_count': usageCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ActivitiesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? category,
    Value<String>? color,
    Value<String?>? description,
    Value<String?>? iconCode,
    Value<int>? usageCount,
    Value<DateTime>? createdAt,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<String>(iconCode.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('color: $color, ')
          ..write('description: $description, ')
          ..write('iconCode: $iconCode, ')
          ..write('usageCount: $usageCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MoodActivitiesTable extends MoodActivities
    with TableInfo<$MoodActivitiesTable, MoodActivity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mood_entries (entry_id)',
    ),
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<int> activityId = GeneratedColumn<int>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activities (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [entryId, activityId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mood_activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoodActivity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId, activityId};
  @override
  MoodActivity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodActivity(
      entryId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entry_id'],
          )!,
      activityId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}activity_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $MoodActivitiesTable createAlias(String alias) {
    return $MoodActivitiesTable(attachedDatabase, alias);
  }
}

class MoodActivity extends DataClass implements Insertable<MoodActivity> {
  final String entryId;
  final int activityId;
  final DateTime createdAt;
  const MoodActivity({
    required this.entryId,
    required this.activityId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    map['activity_id'] = Variable<int>(activityId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MoodActivitiesCompanion toCompanion(bool nullToAbsent) {
    return MoodActivitiesCompanion(
      entryId: Value(entryId),
      activityId: Value(activityId),
      createdAt: Value(createdAt),
    );
  }

  factory MoodActivity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodActivity(
      entryId: serializer.fromJson<String>(json['entryId']),
      activityId: serializer.fromJson<int>(json['activityId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<String>(entryId),
      'activityId': serializer.toJson<int>(activityId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MoodActivity copyWith({
    String? entryId,
    int? activityId,
    DateTime? createdAt,
  }) => MoodActivity(
    entryId: entryId ?? this.entryId,
    activityId: activityId ?? this.activityId,
    createdAt: createdAt ?? this.createdAt,
  );
  MoodActivity copyWithCompanion(MoodActivitiesCompanion data) {
    return MoodActivity(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      activityId:
          data.activityId.present ? data.activityId.value : this.activityId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodActivity(')
          ..write('entryId: $entryId, ')
          ..write('activityId: $activityId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entryId, activityId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodActivity &&
          other.entryId == this.entryId &&
          other.activityId == this.activityId &&
          other.createdAt == this.createdAt);
}

class MoodActivitiesCompanion extends UpdateCompanion<MoodActivity> {
  final Value<String> entryId;
  final Value<int> activityId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MoodActivitiesCompanion({
    this.entryId = const Value.absent(),
    this.activityId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoodActivitiesCompanion.insert({
    required String entryId,
    required int activityId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       activityId = Value(activityId);
  static Insertable<MoodActivity> custom({
    Expression<String>? entryId,
    Expression<int>? activityId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (activityId != null) 'activity_id': activityId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoodActivitiesCompanion copyWith({
    Value<String>? entryId,
    Value<int>? activityId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MoodActivitiesCompanion(
      entryId: entryId ?? this.entryId,
      activityId: activityId ?? this.activityId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<int>(activityId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodActivitiesCompanion(')
          ..write('entryId: $entryId, ')
          ..write('activityId: $activityId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatisticsTable extends Statistics
    with TableInfo<$StatisticsTable, Statistic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatisticsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageMoodMeta = const VerificationMeta(
    'averageMood',
  );
  @override
  late final GeneratedColumn<double> averageMood = GeneratedColumn<double>(
    'average_mood',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryCountMeta = const VerificationMeta(
    'entryCount',
  );
  @override
  late final GeneratedColumn<int> entryCount = GeneratedColumn<int>(
    'entry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mostCommonMoodMeta = const VerificationMeta(
    'mostCommonMood',
  );
  @override
  late final GeneratedColumn<String> mostCommonMood = GeneratedColumn<String>(
    'most_common_mood',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalSleepMinutesMeta = const VerificationMeta(
    'totalSleepMinutes',
  );
  @override
  late final GeneratedColumn<int> totalSleepMinutes = GeneratedColumn<int>(
    'total_sleep_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _topActivitiesMeta = const VerificationMeta(
    'topActivities',
  );
  @override
  late final GeneratedColumn<String> topActivities = GeneratedColumn<String>(
    'top_activities',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    type,
    date,
    averageMood,
    entryCount,
    mostCommonMood,
    totalSleepMinutes,
    topActivities,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'statistics';
  @override
  VerificationContext validateIntegrity(
    Insertable<Statistic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('average_mood')) {
      context.handle(
        _averageMoodMeta,
        averageMood.isAcceptableOrUnknown(
          data['average_mood']!,
          _averageMoodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageMoodMeta);
    }
    if (data.containsKey('entry_count')) {
      context.handle(
        _entryCountMeta,
        entryCount.isAcceptableOrUnknown(data['entry_count']!, _entryCountMeta),
      );
    } else if (isInserting) {
      context.missing(_entryCountMeta);
    }
    if (data.containsKey('most_common_mood')) {
      context.handle(
        _mostCommonMoodMeta,
        mostCommonMood.isAcceptableOrUnknown(
          data['most_common_mood']!,
          _mostCommonMoodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mostCommonMoodMeta);
    }
    if (data.containsKey('total_sleep_minutes')) {
      context.handle(
        _totalSleepMinutesMeta,
        totalSleepMinutes.isAcceptableOrUnknown(
          data['total_sleep_minutes']!,
          _totalSleepMinutesMeta,
        ),
      );
    }
    if (data.containsKey('top_activities')) {
      context.handle(
        _topActivitiesMeta,
        topActivities.isAcceptableOrUnknown(
          data['top_activities']!,
          _topActivitiesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_topActivitiesMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {type, date};
  @override
  Statistic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Statistic(
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      averageMood:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}average_mood'],
          )!,
      entryCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}entry_count'],
          )!,
      mostCommonMood:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}most_common_mood'],
          )!,
      totalSleepMinutes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}total_sleep_minutes'],
          )!,
      topActivities:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}top_activities'],
          )!,
      lastUpdated:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}last_updated'],
          )!,
    );
  }

  @override
  $StatisticsTable createAlias(String alias) {
    return $StatisticsTable(attachedDatabase, alias);
  }
}

class Statistic extends DataClass implements Insertable<Statistic> {
  final String type;
  final DateTime date;
  final double averageMood;
  final int entryCount;
  final String mostCommonMood;
  final int totalSleepMinutes;
  final String topActivities;
  final DateTime lastUpdated;
  const Statistic({
    required this.type,
    required this.date,
    required this.averageMood,
    required this.entryCount,
    required this.mostCommonMood,
    required this.totalSleepMinutes,
    required this.topActivities,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['type'] = Variable<String>(type);
    map['date'] = Variable<DateTime>(date);
    map['average_mood'] = Variable<double>(averageMood);
    map['entry_count'] = Variable<int>(entryCount);
    map['most_common_mood'] = Variable<String>(mostCommonMood);
    map['total_sleep_minutes'] = Variable<int>(totalSleepMinutes);
    map['top_activities'] = Variable<String>(topActivities);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  StatisticsCompanion toCompanion(bool nullToAbsent) {
    return StatisticsCompanion(
      type: Value(type),
      date: Value(date),
      averageMood: Value(averageMood),
      entryCount: Value(entryCount),
      mostCommonMood: Value(mostCommonMood),
      totalSleepMinutes: Value(totalSleepMinutes),
      topActivities: Value(topActivities),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory Statistic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Statistic(
      type: serializer.fromJson<String>(json['type']),
      date: serializer.fromJson<DateTime>(json['date']),
      averageMood: serializer.fromJson<double>(json['averageMood']),
      entryCount: serializer.fromJson<int>(json['entryCount']),
      mostCommonMood: serializer.fromJson<String>(json['mostCommonMood']),
      totalSleepMinutes: serializer.fromJson<int>(json['totalSleepMinutes']),
      topActivities: serializer.fromJson<String>(json['topActivities']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'type': serializer.toJson<String>(type),
      'date': serializer.toJson<DateTime>(date),
      'averageMood': serializer.toJson<double>(averageMood),
      'entryCount': serializer.toJson<int>(entryCount),
      'mostCommonMood': serializer.toJson<String>(mostCommonMood),
      'totalSleepMinutes': serializer.toJson<int>(totalSleepMinutes),
      'topActivities': serializer.toJson<String>(topActivities),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  Statistic copyWith({
    String? type,
    DateTime? date,
    double? averageMood,
    int? entryCount,
    String? mostCommonMood,
    int? totalSleepMinutes,
    String? topActivities,
    DateTime? lastUpdated,
  }) => Statistic(
    type: type ?? this.type,
    date: date ?? this.date,
    averageMood: averageMood ?? this.averageMood,
    entryCount: entryCount ?? this.entryCount,
    mostCommonMood: mostCommonMood ?? this.mostCommonMood,
    totalSleepMinutes: totalSleepMinutes ?? this.totalSleepMinutes,
    topActivities: topActivities ?? this.topActivities,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  Statistic copyWithCompanion(StatisticsCompanion data) {
    return Statistic(
      type: data.type.present ? data.type.value : this.type,
      date: data.date.present ? data.date.value : this.date,
      averageMood:
          data.averageMood.present ? data.averageMood.value : this.averageMood,
      entryCount:
          data.entryCount.present ? data.entryCount.value : this.entryCount,
      mostCommonMood:
          data.mostCommonMood.present
              ? data.mostCommonMood.value
              : this.mostCommonMood,
      totalSleepMinutes:
          data.totalSleepMinutes.present
              ? data.totalSleepMinutes.value
              : this.totalSleepMinutes,
      topActivities:
          data.topActivities.present
              ? data.topActivities.value
              : this.topActivities,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Statistic(')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('averageMood: $averageMood, ')
          ..write('entryCount: $entryCount, ')
          ..write('mostCommonMood: $mostCommonMood, ')
          ..write('totalSleepMinutes: $totalSleepMinutes, ')
          ..write('topActivities: $topActivities, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    type,
    date,
    averageMood,
    entryCount,
    mostCommonMood,
    totalSleepMinutes,
    topActivities,
    lastUpdated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Statistic &&
          other.type == this.type &&
          other.date == this.date &&
          other.averageMood == this.averageMood &&
          other.entryCount == this.entryCount &&
          other.mostCommonMood == this.mostCommonMood &&
          other.totalSleepMinutes == this.totalSleepMinutes &&
          other.topActivities == this.topActivities &&
          other.lastUpdated == this.lastUpdated);
}

class StatisticsCompanion extends UpdateCompanion<Statistic> {
  final Value<String> type;
  final Value<DateTime> date;
  final Value<double> averageMood;
  final Value<int> entryCount;
  final Value<String> mostCommonMood;
  final Value<int> totalSleepMinutes;
  final Value<String> topActivities;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const StatisticsCompanion({
    this.type = const Value.absent(),
    this.date = const Value.absent(),
    this.averageMood = const Value.absent(),
    this.entryCount = const Value.absent(),
    this.mostCommonMood = const Value.absent(),
    this.totalSleepMinutes = const Value.absent(),
    this.topActivities = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatisticsCompanion.insert({
    required String type,
    required DateTime date,
    required double averageMood,
    required int entryCount,
    required String mostCommonMood,
    this.totalSleepMinutes = const Value.absent(),
    required String topActivities,
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : type = Value(type),
       date = Value(date),
       averageMood = Value(averageMood),
       entryCount = Value(entryCount),
       mostCommonMood = Value(mostCommonMood),
       topActivities = Value(topActivities);
  static Insertable<Statistic> custom({
    Expression<String>? type,
    Expression<DateTime>? date,
    Expression<double>? averageMood,
    Expression<int>? entryCount,
    Expression<String>? mostCommonMood,
    Expression<int>? totalSleepMinutes,
    Expression<String>? topActivities,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (type != null) 'type': type,
      if (date != null) 'date': date,
      if (averageMood != null) 'average_mood': averageMood,
      if (entryCount != null) 'entry_count': entryCount,
      if (mostCommonMood != null) 'most_common_mood': mostCommonMood,
      if (totalSleepMinutes != null) 'total_sleep_minutes': totalSleepMinutes,
      if (topActivities != null) 'top_activities': topActivities,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatisticsCompanion copyWith({
    Value<String>? type,
    Value<DateTime>? date,
    Value<double>? averageMood,
    Value<int>? entryCount,
    Value<String>? mostCommonMood,
    Value<int>? totalSleepMinutes,
    Value<String>? topActivities,
    Value<DateTime>? lastUpdated,
    Value<int>? rowid,
  }) {
    return StatisticsCompanion(
      type: type ?? this.type,
      date: date ?? this.date,
      averageMood: averageMood ?? this.averageMood,
      entryCount: entryCount ?? this.entryCount,
      mostCommonMood: mostCommonMood ?? this.mostCommonMood,
      totalSleepMinutes: totalSleepMinutes ?? this.totalSleepMinutes,
      topActivities: topActivities ?? this.topActivities,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (averageMood.present) {
      map['average_mood'] = Variable<double>(averageMood.value);
    }
    if (entryCount.present) {
      map['entry_count'] = Variable<int>(entryCount.value);
    }
    if (mostCommonMood.present) {
      map['most_common_mood'] = Variable<String>(mostCommonMood.value);
    }
    if (totalSleepMinutes.present) {
      map['total_sleep_minutes'] = Variable<int>(totalSleepMinutes.value);
    }
    if (topActivities.present) {
      map['top_activities'] = Variable<String>(topActivities.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatisticsCompanion(')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('averageMood: $averageMood, ')
          ..write('entryCount: $entryCount, ')
          ..write('mostCommonMood: $mostCommonMood, ')
          ..write('totalSleepMinutes: $totalSleepMinutes, ')
          ..write('topActivities: $topActivities, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MoodEntriesTable moodEntries = $MoodEntriesTable(this);
  late final $SleepRecordsTable sleepRecords = $SleepRecordsTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $MoodActivitiesTable moodActivities = $MoodActivitiesTable(this);
  late final $StatisticsTable statistics = $StatisticsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    moodEntries,
    sleepRecords,
    activities,
    moodActivities,
    statistics,
  ];
}

typedef $$MoodEntriesTableCreateCompanionBuilder =
    MoodEntriesCompanion Function({
      Value<int> id,
      required String entryId,
      required int moodValue,
      required DateTime timestamp,
      Value<String?> note,
      Value<String?> photoPath,
      Value<DateTime> createdAt,
    });
typedef $$MoodEntriesTableUpdateCompanionBuilder =
    MoodEntriesCompanion Function({
      Value<int> id,
      Value<String> entryId,
      Value<int> moodValue,
      Value<DateTime> timestamp,
      Value<String?> note,
      Value<String?> photoPath,
      Value<DateTime> createdAt,
    });

final class $$MoodEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $MoodEntriesTable, MoodEntry> {
  $$MoodEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SleepRecordsTable, List<SleepRecord>>
  _sleepRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sleepRecords,
    aliasName: $_aliasNameGenerator(
      db.moodEntries.entryId,
      db.sleepRecords.entryId,
    ),
  );

  $$SleepRecordsTableProcessedTableManager get sleepRecordsRefs {
    final manager = $$SleepRecordsTableTableManager(
      $_db,
      $_db.sleepRecords,
    ).filter(
      (f) => f.entryId.entryId.sqlEquals($_itemColumn<String>('entry_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_sleepRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MoodActivitiesTable, List<MoodActivity>>
  _moodActivitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.moodActivities,
    aliasName: $_aliasNameGenerator(
      db.moodEntries.entryId,
      db.moodActivities.entryId,
    ),
  );

  $$MoodActivitiesTableProcessedTableManager get moodActivitiesRefs {
    final manager = $$MoodActivitiesTableTableManager(
      $_db,
      $_db.moodActivities,
    ).filter(
      (f) => f.entryId.entryId.sqlEquals($_itemColumn<String>('entry_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_moodActivitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MoodEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MoodEntriesTable> {
  $$MoodEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get moodValue => $composableBuilder(
    column: $table.moodValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sleepRecordsRefs(
    Expression<bool> Function($$SleepRecordsTableFilterComposer f) f,
  ) {
    final $$SleepRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.sleepRecords,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SleepRecordsTableFilterComposer(
            $db: $db,
            $table: $db.sleepRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> moodActivitiesRefs(
    Expression<bool> Function($$MoodActivitiesTableFilterComposer f) f,
  ) {
    final $$MoodActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.moodActivities,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.moodActivities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MoodEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MoodEntriesTable> {
  $$MoodEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get moodValue => $composableBuilder(
    column: $table.moodValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoodEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoodEntriesTable> {
  $$MoodEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<int> get moodValue =>
      $composableBuilder(column: $table.moodValue, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> sleepRecordsRefs<T extends Object>(
    Expression<T> Function($$SleepRecordsTableAnnotationComposer a) f,
  ) {
    final $$SleepRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.sleepRecords,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SleepRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.sleepRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> moodActivitiesRefs<T extends Object>(
    Expression<T> Function($$MoodActivitiesTableAnnotationComposer a) f,
  ) {
    final $$MoodActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.moodActivities,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.moodActivities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MoodEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoodEntriesTable,
          MoodEntry,
          $$MoodEntriesTableFilterComposer,
          $$MoodEntriesTableOrderingComposer,
          $$MoodEntriesTableAnnotationComposer,
          $$MoodEntriesTableCreateCompanionBuilder,
          $$MoodEntriesTableUpdateCompanionBuilder,
          (MoodEntry, $$MoodEntriesTableReferences),
          MoodEntry,
          PrefetchHooks Function({
            bool sleepRecordsRefs,
            bool moodActivitiesRefs,
          })
        > {
  $$MoodEntriesTableTableManager(_$AppDatabase db, $MoodEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MoodEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MoodEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$MoodEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<int> moodValue = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MoodEntriesCompanion(
                id: id,
                entryId: entryId,
                moodValue: moodValue,
                timestamp: timestamp,
                note: note,
                photoPath: photoPath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entryId,
                required int moodValue,
                required DateTime timestamp,
                Value<String?> note = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MoodEntriesCompanion.insert(
                id: id,
                entryId: entryId,
                moodValue: moodValue,
                timestamp: timestamp,
                note: note,
                photoPath: photoPath,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$MoodEntriesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            sleepRecordsRefs = false,
            moodActivitiesRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sleepRecordsRefs) db.sleepRecords,
                if (moodActivitiesRefs) db.moodActivities,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sleepRecordsRefs)
                    await $_getPrefetchedData<
                      MoodEntry,
                      $MoodEntriesTable,
                      SleepRecord
                    >(
                      currentTable: table,
                      referencedTable: $$MoodEntriesTableReferences
                          ._sleepRecordsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$MoodEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).sleepRecordsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.entryId == item.entryId,
                          ),
                      typedResults: items,
                    ),
                  if (moodActivitiesRefs)
                    await $_getPrefetchedData<
                      MoodEntry,
                      $MoodEntriesTable,
                      MoodActivity
                    >(
                      currentTable: table,
                      referencedTable: $$MoodEntriesTableReferences
                          ._moodActivitiesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$MoodEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).moodActivitiesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.entryId == item.entryId,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MoodEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoodEntriesTable,
      MoodEntry,
      $$MoodEntriesTableFilterComposer,
      $$MoodEntriesTableOrderingComposer,
      $$MoodEntriesTableAnnotationComposer,
      $$MoodEntriesTableCreateCompanionBuilder,
      $$MoodEntriesTableUpdateCompanionBuilder,
      (MoodEntry, $$MoodEntriesTableReferences),
      MoodEntry,
      PrefetchHooks Function({bool sleepRecordsRefs, bool moodActivitiesRefs})
    >;
typedef $$SleepRecordsTableCreateCompanionBuilder =
    SleepRecordsCompanion Function({
      Value<int> id,
      required String entryId,
      Value<DateTime?> sleepTime,
      Value<DateTime?> wakeTime,
      Value<int?> durationMinutes,
      Value<int?> qualityRating,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$SleepRecordsTableUpdateCompanionBuilder =
    SleepRecordsCompanion Function({
      Value<int> id,
      Value<String> entryId,
      Value<DateTime?> sleepTime,
      Value<DateTime?> wakeTime,
      Value<int?> durationMinutes,
      Value<int?> qualityRating,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$SleepRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $SleepRecordsTable, SleepRecord> {
  $$SleepRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MoodEntriesTable _entryIdTable(_$AppDatabase db) =>
      db.moodEntries.createAlias(
        $_aliasNameGenerator(db.sleepRecords.entryId, db.moodEntries.entryId),
      );

  $$MoodEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $$MoodEntriesTableTableManager(
      $_db,
      $_db.moodEntries,
    ).filter((f) => f.entryId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SleepRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SleepRecordsTable> {
  $$SleepRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sleepTime => $composableBuilder(
    column: $table.sleepTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get wakeTime => $composableBuilder(
    column: $table.wakeTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qualityRating => $composableBuilder(
    column: $table.qualityRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MoodEntriesTableFilterComposer get entryId {
    final $$MoodEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.moodEntries,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodEntriesTableFilterComposer(
            $db: $db,
            $table: $db.moodEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SleepRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepRecordsTable> {
  $$SleepRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sleepTime => $composableBuilder(
    column: $table.sleepTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get wakeTime => $composableBuilder(
    column: $table.wakeTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qualityRating => $composableBuilder(
    column: $table.qualityRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MoodEntriesTableOrderingComposer get entryId {
    final $$MoodEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.moodEntries,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.moodEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SleepRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepRecordsTable> {
  $$SleepRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get sleepTime =>
      $composableBuilder(column: $table.sleepTime, builder: (column) => column);

  GeneratedColumn<DateTime> get wakeTime =>
      $composableBuilder(column: $table.wakeTime, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qualityRating => $composableBuilder(
    column: $table.qualityRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MoodEntriesTableAnnotationComposer get entryId {
    final $$MoodEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.moodEntries,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.moodEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SleepRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SleepRecordsTable,
          SleepRecord,
          $$SleepRecordsTableFilterComposer,
          $$SleepRecordsTableOrderingComposer,
          $$SleepRecordsTableAnnotationComposer,
          $$SleepRecordsTableCreateCompanionBuilder,
          $$SleepRecordsTableUpdateCompanionBuilder,
          (SleepRecord, $$SleepRecordsTableReferences),
          SleepRecord,
          PrefetchHooks Function({bool entryId})
        > {
  $$SleepRecordsTableTableManager(_$AppDatabase db, $SleepRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SleepRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SleepRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$SleepRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<DateTime?> sleepTime = const Value.absent(),
                Value<DateTime?> wakeTime = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                Value<int?> qualityRating = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SleepRecordsCompanion(
                id: id,
                entryId: entryId,
                sleepTime: sleepTime,
                wakeTime: wakeTime,
                durationMinutes: durationMinutes,
                qualityRating: qualityRating,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entryId,
                Value<DateTime?> sleepTime = const Value.absent(),
                Value<DateTime?> wakeTime = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                Value<int?> qualityRating = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SleepRecordsCompanion.insert(
                id: id,
                entryId: entryId,
                sleepTime: sleepTime,
                wakeTime: wakeTime,
                durationMinutes: durationMinutes,
                qualityRating: qualityRating,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$SleepRecordsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({entryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (entryId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.entryId,
                            referencedTable: $$SleepRecordsTableReferences
                                ._entryIdTable(db),
                            referencedColumn:
                                $$SleepRecordsTableReferences
                                    ._entryIdTable(db)
                                    .entryId,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SleepRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SleepRecordsTable,
      SleepRecord,
      $$SleepRecordsTableFilterComposer,
      $$SleepRecordsTableOrderingComposer,
      $$SleepRecordsTableAnnotationComposer,
      $$SleepRecordsTableCreateCompanionBuilder,
      $$SleepRecordsTableUpdateCompanionBuilder,
      (SleepRecord, $$SleepRecordsTableReferences),
      SleepRecord,
      PrefetchHooks Function({bool entryId})
    >;
typedef $$ActivitiesTableCreateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<int> id,
      required String name,
      required String category,
      Value<String> color,
      Value<String?> description,
      Value<String?> iconCode,
      Value<int> usageCount,
      Value<DateTime> createdAt,
    });
typedef $$ActivitiesTableUpdateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> category,
      Value<String> color,
      Value<String?> description,
      Value<String?> iconCode,
      Value<int> usageCount,
      Value<DateTime> createdAt,
    });

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, Activity> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MoodActivitiesTable, List<MoodActivity>>
  _moodActivitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.moodActivities,
    aliasName: $_aliasNameGenerator(
      db.activities.id,
      db.moodActivities.activityId,
    ),
  );

  $$MoodActivitiesTableProcessedTableManager get moodActivitiesRefs {
    final manager = $$MoodActivitiesTableTableManager(
      $_db,
      $_db.moodActivities,
    ).filter((f) => f.activityId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_moodActivitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> moodActivitiesRefs(
    Expression<bool> Function($$MoodActivitiesTableFilterComposer f) f,
  ) {
    final $$MoodActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moodActivities,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.moodActivities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> moodActivitiesRefs<T extends Object>(
    Expression<T> Function($$MoodActivitiesTableAnnotationComposer a) f,
  ) {
    final $$MoodActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moodActivities,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.moodActivities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          Activity,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (Activity, $$ActivitiesTableReferences),
          Activity,
          PrefetchHooks Function({bool moodActivitiesRefs})
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> iconCode = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                name: name,
                category: category,
                color: color,
                description: description,
                iconCode: iconCode,
                usageCount: usageCount,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String category,
                Value<String> color = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> iconCode = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                id: id,
                name: name,
                category: category,
                color: color,
                description: description,
                iconCode: iconCode,
                usageCount: usageCount,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ActivitiesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({moodActivitiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (moodActivitiesRefs) db.moodActivities,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (moodActivitiesRefs)
                    await $_getPrefetchedData<
                      Activity,
                      $ActivitiesTable,
                      MoodActivity
                    >(
                      currentTable: table,
                      referencedTable: $$ActivitiesTableReferences
                          ._moodActivitiesRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ActivitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).moodActivitiesRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.activityId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      Activity,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (Activity, $$ActivitiesTableReferences),
      Activity,
      PrefetchHooks Function({bool moodActivitiesRefs})
    >;
typedef $$MoodActivitiesTableCreateCompanionBuilder =
    MoodActivitiesCompanion Function({
      required String entryId,
      required int activityId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$MoodActivitiesTableUpdateCompanionBuilder =
    MoodActivitiesCompanion Function({
      Value<String> entryId,
      Value<int> activityId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MoodActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $MoodActivitiesTable, MoodActivity> {
  $$MoodActivitiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MoodEntriesTable _entryIdTable(_$AppDatabase db) =>
      db.moodEntries.createAlias(
        $_aliasNameGenerator(db.moodActivities.entryId, db.moodEntries.entryId),
      );

  $$MoodEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $$MoodEntriesTableTableManager(
      $_db,
      $_db.moodEntries,
    ).filter((f) => f.entryId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) =>
      db.activities.createAlias(
        $_aliasNameGenerator(db.moodActivities.activityId, db.activities.id),
      );

  $$ActivitiesTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<int>('activity_id')!;

    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MoodActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $MoodActivitiesTable> {
  $$MoodActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MoodEntriesTableFilterComposer get entryId {
    final $$MoodEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.moodEntries,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodEntriesTableFilterComposer(
            $db: $db,
            $table: $db.moodEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoodActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $MoodActivitiesTable> {
  $$MoodActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MoodEntriesTableOrderingComposer get entryId {
    final $$MoodEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.moodEntries,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.moodEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableOrderingComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoodActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoodActivitiesTable> {
  $$MoodActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MoodEntriesTableAnnotationComposer get entryId {
    final $$MoodEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.moodEntries,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.moodEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MoodActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoodActivitiesTable,
          MoodActivity,
          $$MoodActivitiesTableFilterComposer,
          $$MoodActivitiesTableOrderingComposer,
          $$MoodActivitiesTableAnnotationComposer,
          $$MoodActivitiesTableCreateCompanionBuilder,
          $$MoodActivitiesTableUpdateCompanionBuilder,
          (MoodActivity, $$MoodActivitiesTableReferences),
          MoodActivity,
          PrefetchHooks Function({bool entryId, bool activityId})
        > {
  $$MoodActivitiesTableTableManager(
    _$AppDatabase db,
    $MoodActivitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MoodActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$MoodActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MoodActivitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entryId = const Value.absent(),
                Value<int> activityId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoodActivitiesCompanion(
                entryId: entryId,
                activityId: activityId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entryId,
                required int activityId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoodActivitiesCompanion.insert(
                entryId: entryId,
                activityId: activityId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$MoodActivitiesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({entryId = false, activityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (entryId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.entryId,
                            referencedTable: $$MoodActivitiesTableReferences
                                ._entryIdTable(db),
                            referencedColumn:
                                $$MoodActivitiesTableReferences
                                    ._entryIdTable(db)
                                    .entryId,
                          )
                          as T;
                }
                if (activityId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.activityId,
                            referencedTable: $$MoodActivitiesTableReferences
                                ._activityIdTable(db),
                            referencedColumn:
                                $$MoodActivitiesTableReferences
                                    ._activityIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MoodActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoodActivitiesTable,
      MoodActivity,
      $$MoodActivitiesTableFilterComposer,
      $$MoodActivitiesTableOrderingComposer,
      $$MoodActivitiesTableAnnotationComposer,
      $$MoodActivitiesTableCreateCompanionBuilder,
      $$MoodActivitiesTableUpdateCompanionBuilder,
      (MoodActivity, $$MoodActivitiesTableReferences),
      MoodActivity,
      PrefetchHooks Function({bool entryId, bool activityId})
    >;
typedef $$StatisticsTableCreateCompanionBuilder =
    StatisticsCompanion Function({
      required String type,
      required DateTime date,
      required double averageMood,
      required int entryCount,
      required String mostCommonMood,
      Value<int> totalSleepMinutes,
      required String topActivities,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });
typedef $$StatisticsTableUpdateCompanionBuilder =
    StatisticsCompanion Function({
      Value<String> type,
      Value<DateTime> date,
      Value<double> averageMood,
      Value<int> entryCount,
      Value<String> mostCommonMood,
      Value<int> totalSleepMinutes,
      Value<String> topActivities,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });

class $$StatisticsTableFilterComposer
    extends Composer<_$AppDatabase, $StatisticsTable> {
  $$StatisticsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageMood => $composableBuilder(
    column: $table.averageMood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mostCommonMood => $composableBuilder(
    column: $table.mostCommonMood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSleepMinutes => $composableBuilder(
    column: $table.totalSleepMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topActivities => $composableBuilder(
    column: $table.topActivities,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StatisticsTableOrderingComposer
    extends Composer<_$AppDatabase, $StatisticsTable> {
  $$StatisticsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageMood => $composableBuilder(
    column: $table.averageMood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mostCommonMood => $composableBuilder(
    column: $table.mostCommonMood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSleepMinutes => $composableBuilder(
    column: $table.totalSleepMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topActivities => $composableBuilder(
    column: $table.topActivities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StatisticsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatisticsTable> {
  $$StatisticsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get averageMood => $composableBuilder(
    column: $table.averageMood,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entryCount => $composableBuilder(
    column: $table.entryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mostCommonMood => $composableBuilder(
    column: $table.mostCommonMood,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalSleepMinutes => $composableBuilder(
    column: $table.totalSleepMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topActivities => $composableBuilder(
    column: $table.topActivities,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$StatisticsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatisticsTable,
          Statistic,
          $$StatisticsTableFilterComposer,
          $$StatisticsTableOrderingComposer,
          $$StatisticsTableAnnotationComposer,
          $$StatisticsTableCreateCompanionBuilder,
          $$StatisticsTableUpdateCompanionBuilder,
          (
            Statistic,
            BaseReferences<_$AppDatabase, $StatisticsTable, Statistic>,
          ),
          Statistic,
          PrefetchHooks Function()
        > {
  $$StatisticsTableTableManager(_$AppDatabase db, $StatisticsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$StatisticsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$StatisticsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$StatisticsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> type = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> averageMood = const Value.absent(),
                Value<int> entryCount = const Value.absent(),
                Value<String> mostCommonMood = const Value.absent(),
                Value<int> totalSleepMinutes = const Value.absent(),
                Value<String> topActivities = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatisticsCompanion(
                type: type,
                date: date,
                averageMood: averageMood,
                entryCount: entryCount,
                mostCommonMood: mostCommonMood,
                totalSleepMinutes: totalSleepMinutes,
                topActivities: topActivities,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String type,
                required DateTime date,
                required double averageMood,
                required int entryCount,
                required String mostCommonMood,
                Value<int> totalSleepMinutes = const Value.absent(),
                required String topActivities,
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatisticsCompanion.insert(
                type: type,
                date: date,
                averageMood: averageMood,
                entryCount: entryCount,
                mostCommonMood: mostCommonMood,
                totalSleepMinutes: totalSleepMinutes,
                topActivities: topActivities,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StatisticsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatisticsTable,
      Statistic,
      $$StatisticsTableFilterComposer,
      $$StatisticsTableOrderingComposer,
      $$StatisticsTableAnnotationComposer,
      $$StatisticsTableCreateCompanionBuilder,
      $$StatisticsTableUpdateCompanionBuilder,
      (Statistic, BaseReferences<_$AppDatabase, $StatisticsTable, Statistic>),
      Statistic,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MoodEntriesTableTableManager get moodEntries =>
      $$MoodEntriesTableTableManager(_db, _db.moodEntries);
  $$SleepRecordsTableTableManager get sleepRecords =>
      $$SleepRecordsTableTableManager(_db, _db.sleepRecords);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$MoodActivitiesTableTableManager get moodActivities =>
      $$MoodActivitiesTableTableManager(_db, _db.moodActivities);
  $$StatisticsTableTableManager get statistics =>
      $$StatisticsTableTableManager(_db, _db.statistics);
}
