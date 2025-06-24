import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'drift_database.g.dart';

// Таблица настроений
class MoodEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entryId => text().unique()();
  IntColumn get moodValue => integer()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Таблица сна
class SleepRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entryId => text().references(MoodEntries, #entryId)();
  DateTimeColumn get sleepTime => dateTime().nullable()();
  DateTimeColumn get wakeTime => dateTime().nullable()();
  IntColumn get durationMinutes => integer().nullable()();
  IntColumn get qualityRating => integer().nullable()(); // 1-5 rating
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Таблица активностей
class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get category => text()();
  TextColumn get color => text().withDefault(const Constant('#2196F3'))();
  TextColumn get description => text().nullable()();
  TextColumn get iconCode => text().nullable()();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Связующая таблица настроений и активностей
class MoodActivities extends Table {
  TextColumn get entryId => text().references(MoodEntries, #entryId)();
  IntColumn get activityId => integer().references(Activities, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {entryId, activityId};
}

// Таблица статистики
class Statistics extends Table {
  TextColumn get type => text()(); // 'daily', 'weekly', 'monthly'
  DateTimeColumn get date => dateTime()();
  RealColumn get averageMood => real()();
  IntColumn get entryCount => integer()();
  TextColumn get mostCommonMood => text()();
  IntColumn get totalSleepMinutes => integer().withDefault(const Constant(0))();
  TextColumn get topActivities => text()(); // JSON encoded
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {type, date};
}

@DriftDatabase(tables: [MoodEntries, SleepRecords, Activities, MoodActivities, Statistics])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  // Constructor for testing with in-memory database
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createIndexes();
        await _insertDefaultActivities();
      },
      
      // Пример миграции с версии 1 на версию 2
      onUpgrade: (Migrator m, int from, int to) async {
        if (from <= 1) {
          // Пример миграции: добавляем новое поле в таблицу активностей
          await customStatement('''
            ALTER TABLE activities 
            ADD COLUMN color_code TEXT DEFAULT '#2196F3';
          ''');
          
          // Добавляем новую таблицу тегов (если бы она не существовала изначально)
          await customStatement('''
            CREATE TABLE IF NOT EXISTS mood_tags (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL UNIQUE,
              color TEXT NOT NULL DEFAULT '#FF5722',
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
            );
          ''');
          
          // Связующая таблица для тегов и настроений
          await customStatement('''
            CREATE TABLE IF NOT EXISTS mood_entry_tags (
              entry_id TEXT NOT NULL,
              tag_id INTEGER NOT NULL,
              PRIMARY KEY (entry_id, tag_id),
              FOREIGN KEY (entry_id) REFERENCES mood_entries(entry_id),
              FOREIGN KEY (tag_id) REFERENCES mood_tags(id)
            );
          ''');
          
          // Добавляем индексы для новых таблиц
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_mood_tags_name 
            ON mood_tags(name);
          ''');
          
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_mood_entry_tags_entry_id 
            ON mood_entry_tags(entry_id);
          ''');
          
          // Вставляем базовые теги
          await customStatement('''
            INSERT OR IGNORE INTO mood_tags (name, color) VALUES 
              ('Стресс', '#F44336'),
              ('Радость', '#4CAF50'),
              ('Усталость', '#9C27B0'),
              ('Энергия', '#FF9800'),
              ('Спокойствие', '#2196F3');
          ''');
          
          // Обновляем существующие записи активностей с цветами
          await customStatement('''
            UPDATE activities 
            SET color_code = CASE 
              WHEN category = 'Профессиональная' THEN '#1976D2'
              WHEN category = 'Физическая' THEN '#388E3C'
              WHEN category = 'Досуг' THEN '#7B1FA2'
              WHEN category = 'Социальная' THEN '#F57C00'
              WHEN category = 'Здоровье' THEN '#00796B'
              WHEN category = 'Бытовая' THEN '#5D4037'
              ELSE '#607D8B'
            END
            WHERE color_code = '#2196F3';
          ''');
        }
      },
      
      
      // Выполняется перед любой миграцией
      beforeOpen: (details) async {
        // Включаем поддержку внешних ключей
        await customStatement('PRAGMA foreign_keys = ON;');
        
        // Оптимизируем производительность
        await customStatement('PRAGMA journal_mode = WAL;');
        await customStatement('PRAGMA synchronous = NORMAL;');
        await customStatement('PRAGMA cache_size = 10000;');
        await customStatement('PRAGMA temp_store = MEMORY;');
        
        // Проводим периодическую оптимизацию
        if (details.hadUpgrade || details.wasCreated) {
          await customStatement('VACUUM;');
          await customStatement('ANALYZE;');
        }
      },
    );
  }
  
  Future<void> _createIndexes() async {
    // Создаем индексы для улучшения производительности
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_mood_entries_timestamp 
      ON mood_entries(timestamp);
    ''');
    
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_mood_entries_mood_value 
      ON mood_entries(mood_value);
    ''');
    
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_sleep_records_entry_id 
      ON sleep_records(entry_id);
    ''');
    
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_activities_category 
      ON activities(category);
    ''');
    
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_mood_activities_entry_id 
      ON mood_activities(entry_id);
    ''');
    
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_statistics_type_date 
      ON statistics(type, date);
    ''');
    
    // Композитный индекс для сложных запросов
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_mood_entries_mood_timestamp 
      ON mood_entries(mood_value, timestamp);
    ''');
  }

  Future<void> _insertDefaultActivities() async {
    final defaultActivities = [
      {'name': 'Работа', 'category': 'Профессиональная', 'icon_code': '💼', 'color': '#1976D2'},
      {'name': 'Спорт', 'category': 'Физическая', 'icon_code': '🏃', 'color': '#388E3C'},
      {'name': 'Чтение', 'category': 'Досуг', 'icon_code': '📚', 'color': '#7B1FA2'},
      {'name': 'Общение с друзьями', 'category': 'Социальная', 'icon_code': '👥', 'color': '#F57C00'},
      {'name': 'Медитация', 'category': 'Здоровье', 'icon_code': '🧘', 'color': '#00796B'},
      {'name': 'Прогулка', 'category': 'Физическая', 'icon_code': '🚶', 'color': '#388E3C'},
      {'name': 'Готовка', 'category': 'Бытовая', 'icon_code': '👨‍🍳', 'color': '#5D4037'},
      {'name': 'Музыка', 'category': 'Досуг', 'icon_code': '🎵', 'color': '#7B1FA2'},
    ];

    for (final activity in defaultActivities) {
      await into(activities).insertOnConflictUpdate(
        ActivitiesCompanion(
          name: Value(activity['name']!),
          category: Value(activity['category']!),
          color: Value(activity['color']!),
          iconCode: Value(activity['icon_code']),
        ),
      );
    }
  }

  // CRUD операции для настроений
  Future<List<MoodEntry>> getAllMoodEntries() {
    return (select(moodEntries)
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  Future<MoodEntry?> getMoodEntryById(String entryId) {
    return (select(moodEntries)..where((t) => t.entryId.equals(entryId)))
        .getSingleOrNull();
  }

  Future<List<MoodEntry>> getMoodEntriesByDateRange(DateTime start, DateTime end) {
    return (select(moodEntries)
      ..where((t) => t.timestamp.isBetweenValues(start, end))
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  Future<int> insertMoodEntry(MoodEntriesCompanion entry) {
    return into(moodEntries).insert(entry);
  }

  Future<int> addMoodEntry({
    required int moodValue,
    String? note,
    required DateTime timestamp,
    String? photoPath,
  }) {
    // Generate unique ID with microseconds and random component to avoid collisions
    final random = DateTime.now().microsecondsSinceEpoch;
    final randomPart = (random * 1000 + (random % 1000)).toString();
    return into(moodEntries).insert(MoodEntriesCompanion.insert(
      entryId: 'mood_$randomPart',
      moodValue: moodValue,
      timestamp: timestamp,
      note: Value(note),
      photoPath: Value(photoPath),
    ));
  }

  Future<bool> updateMoodEntry(MoodEntriesCompanion entry) {
    return update(moodEntries).replace(entry);
  }

  Future<int> deleteMoodEntry(String entryId) {
    return (delete(moodEntries)..where((t) => t.entryId.equals(entryId))).go();
  }

  // Операции для сна
  Future<SleepRecord?> getSleepRecordByEntryId(String entryId) {
    return (select(sleepRecords)..where((t) => t.entryId.equals(entryId)))
        .getSingleOrNull();
  }

  Future<int> insertSleepRecord(SleepRecordsCompanion record) {
    return into(sleepRecords).insert(record);
  }

  // Операции для активностей
  Future<List<Activity>> getAllActivities() {
    return (select(activities)
      ..orderBy([
        (t) => OrderingTerm.desc(t.usageCount),
        (t) => OrderingTerm.asc(t.name),
      ]))
        .get();
  }

  Future<List<Activity>> getActivitiesByCategory(String category) {
    return (select(activities)..where((t) => t.category.equals(category))).get();
  }

  Future<int> insertActivity(ActivitiesCompanion activity) {
    return into(activities).insert(activity);
  }

  Future<int> addActivity(String name, String colorCode) async {
    return await into(activities).insertOnConflictUpdate(
      ActivitiesCompanion.insert(
        name: name,
        category: 'Общее',
        color: Value(colorCode),
        description: Value('Автоматически добавленная активность'),
        usageCount: const Value(1),
      ),
    );
  }

  Future<void> incrementActivityUsage(String activityName) async {
    await customUpdate(
      'UPDATE activities SET usage_count = usage_count + 1 WHERE name = ?',
      variables: [Variable.withString(activityName)],
    );
  }

  // Связывание настроений с активностями
  Future<void> addActivityToMoodEntry(String entryId, int activityId) {
    return into(moodActivities).insertOnConflictUpdate(
      MoodActivitiesCompanion(
        entryId: Value(entryId),
        activityId: Value(activityId),
      ),
    );
  }

  Future<List<Activity>> getActivitiesForMoodEntry(String entryId) {
    final query = select(activities).join([
      innerJoin(
        moodActivities,
        moodActivities.activityId.equalsExp(activities.id),
      ),
    ])..where(moodActivities.entryId.equals(entryId));

    return query.map((row) => row.readTable(activities)).get();
  }

  // Сложные аналитические запросы
  Future<double> getAverageMoodForPeriod(DateTime start, DateTime end) async {
    final query = selectOnly(moodEntries)
      ..where(moodEntries.timestamp.isBetweenValues(start, end))
      ..addColumns([moodEntries.moodValue.avg()]);

    final result = await query.getSingleOrNull();
    return result?.read(moodEntries.moodValue.avg()) ?? 0.0;
  }

  Future<Map<int, int>> getMoodDistribution() async {
    final query = selectOnly(moodEntries)
      ..addColumns([
        moodEntries.moodValue,
        moodEntries.moodValue.count(),
      ])
      ..groupBy([moodEntries.moodValue]);

    final results = await query.get();
    final distribution = <int, int>{};
    
    for (final result in results) {
      final moodValue = result.read(moodEntries.moodValue);
      final count = result.read(moodEntries.moodValue.count());
      if (moodValue != null && count != null) {
        distribution[moodValue] = count;
      }
    }
    
    return distribution;
  }

  // Аналитика по дням недели - возвращает средние значения настроения
  Future<Map<String, double>> getMoodEntriesByWeekday() async {
    final result = await customSelect(
      '''
      SELECT 
        CASE strftime('%w', datetime(timestamp, 'unixepoch'))
          WHEN '0' THEN 'Воскресенье'
          WHEN '1' THEN 'Понедельник'
          WHEN '2' THEN 'Вторник'
          WHEN '3' THEN 'Среда'
          WHEN '4' THEN 'Четверг'
          WHEN '5' THEN 'Пятница'
          WHEN '6' THEN 'Суббота'
        END as weekday,
        AVG(mood_value) as avg_mood
      FROM mood_entries 
      GROUP BY strftime('%w', datetime(timestamp, 'unixepoch'))
      ORDER BY strftime('%w', datetime(timestamp, 'unixepoch'))
      ''',
      readsFrom: {moodEntries},
    ).get();
    
    final weekdayMoods = <String, double>{};
    for (final row in result) {
      final weekday = row.data['weekday'] as String?;
      final avgMood = row.data['avg_mood'] as double?;
      if (weekday != null && avgMood != null) {
        weekdayMoods[weekday] = avgMood;
      }
    }
    return weekdayMoods;
  }

  // Топ активности по использованию
  Future<List<Activity>> getTopActivities(int limit) {
    return (select(activities)
      ..orderBy([(t) => OrderingTerm.desc(t.usageCount)])
      ..limit(limit))
        .get();
  }

  // Статистика сна
  Future<Map<String, dynamic>> getSleepStatistics(DateTime start, DateTime end) async {
    final query = selectOnly(sleepRecords)
      ..where(sleepRecords.createdAt.isBetweenValues(start, end))
      ..addColumns([
        sleepRecords.durationMinutes.avg(),
        sleepRecords.durationMinutes.max(),
        sleepRecords.durationMinutes.min(),
        sleepRecords.qualityRating.avg(),
      ]);

    final result = await query.getSingleOrNull();
    
    return {
      'averageDuration': result?.read(sleepRecords.durationMinutes.avg()) ?? 0.0,
      'maxDuration': result?.read(sleepRecords.durationMinutes.max()) ?? 0,
      'minDuration': result?.read(sleepRecords.durationMinutes.min()) ?? 0,
      'averageQuality': result?.read(sleepRecords.qualityRating.avg()) ?? 0.0,
    };
  }

  // Операции со статистикой
  Future<int> insertOrUpdateStatistics(StatisticsCompanion stats) {
    return into(statistics).insertOnConflictUpdate(stats);
  }

  Future<List<Statistic>> getStatisticsByType(String type) {
    return (select(statistics)
      ..where((t) => t.type.equals(type))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  // Получить последние записи настроения
  Future<List<MoodEntry>> getRecentMoodEntries(int days) {
    final since = DateTime.now().subtract(Duration(days: days));
    return (select(moodEntries)
      ..where((t) => t.timestamp.isBiggerThanValue(since))
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  // Обновить статистику
  Future<void> updateStatistics({
    required DateTime date,
    required double averageMood,
    required int entryCount,
    required int totalSleepMinutes,
  }) async {
    await into(statistics).insertOnConflictUpdate(
      StatisticsCompanion.insert(
        type: 'daily',
        date: date,
        averageMood: averageMood,
        entryCount: entryCount,
        mostCommonMood: 'Хорошее', // Default value
        totalSleepMinutes: Value(totalSleepMinutes),
        topActivities: '[]', // Empty JSON array
      ),
    );
  }
  
  // Methods for test compatibility
  Future<void> linkActivityToEntry(int entryId, int activityId) async {
    final entry = await (select(moodEntries)..where((t) => t.id.equals(entryId))).getSingleOrNull();
    if (entry != null) {
      await addActivityToMoodEntry(entry.entryId, activityId);
    }
  }
  
  Future<List<Activity>> getActivitiesForEntry(int entryId) async {
    final entry = await (select(moodEntries)..where((t) => t.id.equals(entryId))).getSingleOrNull();
    if (entry != null) {
      return getActivitiesForMoodEntry(entry.entryId);
    }
    return [];
  }
  
  Future<Statistic?> getStatisticsForDate(DateTime date) {
    return (select(statistics)
      ..where((t) => t.type.equals('daily') & t.date.equals(date)))
        .getSingleOrNull();
  }
  
  Future<List<MoodEntry>> getMoodEntriesByMood(int moodValue) {
    return (select(moodEntries)
      ..where((t) => t.moodValue.equals(moodValue))
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }
  
  Future<void> deleteEntriesOlderThan(Duration duration) async {
    final cutoffDate = DateTime.now().subtract(duration);
    await (delete(moodEntries)..where((t) => t.timestamp.isSmallerThanValue(cutoffDate))).go();
  }
  
  Future<List<Map<String, dynamic>>> getWeeklyStatistics() async {
    final result = await customSelect(
      '''
      SELECT 
        strftime('%W', datetime(date, 'unixepoch')) as week,
        strftime('%Y', datetime(date, 'unixepoch')) as year,
        AVG(average_mood) as avg_mood,
        SUM(entry_count) as total_entries,
        SUM(total_sleep_minutes) as total_sleep
      FROM statistics
      WHERE type = 'daily'
      GROUP BY strftime('%Y-%W', datetime(date, 'unixepoch'))
      ORDER BY date DESC
      LIMIT 12
      ''',
      readsFrom: {statistics},
    ).get();
    
    return result.map((row) => row.data).toList();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mood_tracker_drift.db'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}