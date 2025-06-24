# MoodTracker++

Демонстрационное приложение для изучения различных подходов к персистентности во Flutter.

## Описание

MoodTracker++ - это приложение для отслеживания настроения, которое демонстрирует различные библиотеки и подходы к сохранению данных во Flutter. Каждая ветка представляет отдельный подход к персистентности.

## Структура веток

### 00_initial - Базовая версия без персистентности
- Хранение данных только в памяти
- Потеря данных при перезапуске приложения
- Основа для всех последующих реализаций
- **Используемые пакеты:**
  - `provider` - управление состоянием
  - `intl` - форматирование дат

### 01_shared_prefs - SharedPreferences ✅
- Простое key-value хранилище для настроек
- Сохранение темы приложения (светлая/темная)
- Сохранение состояния аутентификации
- Счетчик запусков приложения
- Напоминания для ежедневных записей
- **Используемые пакеты:**
  - `shared_preferences: ^2.3.2` - key-value хранилище
  - Все пакеты из 00_initial

### 02_secure_storage - Secure Storage ✅
- Шифрованное хранилище для чувствительных данных
- Интеграция с Keychain (iOS) и Keystore (Android)
- Хранение токенов аутентификации и паролей
- Firebase Authentication интеграция
- **Используемые пакеты:**
  - `flutter_secure_storage: ^9.2.2` - шифрованное хранилище
  - `firebase_core: ^3.8.0` - Firebase SDK
  - `firebase_auth: ^5.3.4` - аутентификация
  - Все пакеты из предыдущих веток

### 03_files - Файловая система ✅
- Работа с локальными файлами
- Экспорт/импорт данных в JSON и CSV
- Сохранение фотографий к записям настроения
- Резервное копирование и восстановление
- **Используемые пакеты:**
  - `path_provider: ^2.1.5` - доступ к файловой системе
  - `path: ^1.9.1` - работа с путями
  - `file_picker: ^8.1.6` - выбор файлов
  - `image_picker: ^1.2.0` - выбор изображений
  - `permission_handler: ^11.3.1` - управление разрешениями
  - `csv: ^6.0.0` - работа с CSV файлами
  - Все пакеты из предыдущих веток

### 04_nosql - NoSQL базы данных ✅
- Реализация с ObjectBox и Realm
- Высокопроизводительные встраиваемые базы данных
- ObjectBox для основных данных настроения
- Realm для дополнительных данных
- **Используемые пакеты:**
  - `objectbox: ^4.0.3` - NoSQL база данных
  - `objectbox_flutter_libs: ^4.0.3` - нативные библиотеки
  - `realm: ^20.1.1` - NoSQL база данных Realm
  - Все пакеты из предыдущих веток

### 05_sql - SQL база данных ✅
- SQLite через Drift с пятью связанными таблицами
- Миграции схемы базы данных
- Raw SQL запросы для аналитики
- Оптимизированные запросы с JOIN
- **Используемые пакеты:**
  - `drift: ^2.25.0` - ORM для SQLite
  - `sqlite3_flutter_libs: ^0.5.33` - нативные библиотеки SQLite
  - Все пакеты из предыдущих веток

### 06_cloud_storage - Облачное хранилище
- *(Ветка будет добавлена)*
- Firebase Storage и Firestore
- Синхронизация данных между устройствами

### 07_clean_data - Очистка данных
- *(Ветка будет добавлена)*
- Полная очистка всех типов хранилищ
- Безопасный выход из аккаунта

## Функционал приложения

- 📝 Запись настроения с эмодзи и цветовой индикацией
- 📊 Добавление заметок к записям
- 🏃 Отметка активностей
- 💤 Отслеживание сна
- 📷 Прикрепление фотографий
- 📈 История записей
- 📊 Статистика настроений
- 🌙 Темная тема
- ☁️ Облачная синхронизация
- 🔐 Безопасное хранение данных

## Структура проекта

```
lib/
├── main.dart              # Точка входа
├── models/               # Модели данных
│   └── mood_entry.dart
├── database/             # База данных
│   ├── drift_database.dart
│   └── drift_database.g.dart
├── screens/              # Экраны приложения
│   ├── home_screen.dart
│   ├── add_mood_screen.dart
│   ├── mood_history_screen.dart
│   ├── statistics_screen.dart
│   ├── profile_screen.dart
│   └── login_screen.dart
├── services/             # Сервисы
│   ├── mood_service.dart
│   ├── theme_service.dart
│   ├── auth_service.dart
│   └── preferences_service.dart
└── widgets/              # Переиспользуемые виджеты
```

## Ветка 05_sql

В этой ветке реализовано хранение данных с использованием SQLite через Drift ORM:

### Реализованные функции:
- 🗜️ **5 связанных таблиц** - нормализованная структура БД
- 🔄 **Миграции** - автоматические обновления схемы
- 📋 **Raw SQL** - прямые SQL запросы для аналитики
- 🔗 **JOIN запросы** - сложные выборки с объединениями
- 📊 **Агрегация** - GROUP BY, COUNT, AVG для статистики
- 💡 **DDL команды** - CREATE, ALTER, DROP таблиц

### Таблицы базы данных:

1. **mood_entries** - основные записи настроения
   - id (TEXT PRIMARY KEY)
   - mood_value (INTEGER)
   - note (TEXT)
   - photo_path (TEXT)
   - created_at (INTEGER)

2. **sleep_records** - записи о сне
   - id (INTEGER PRIMARY KEY AUTOINCREMENT)
   - mood_entry_id (TEXT REFERENCES mood_entries)
   - hours (REAL)
   - quality (INTEGER)

3. **activities** - справочник активностей
   - id (INTEGER PRIMARY KEY)
   - name (TEXT UNIQUE)
   - icon (TEXT)

4. **mood_activities** - связь many-to-many
   - mood_entry_id (TEXT)
   - activity_id (INTEGER)

5. **statistics** - кешированная статистика
   - id (INTEGER PRIMARY KEY)
   - date (INTEGER)
   - avg_mood (REAL)
   - entry_count (INTEGER)

### Технические детали:
- Type-safe SQL через Drift
- Автоматическая генерация кода
- Поддержка транзакций
- Миграции с версии 1 на 2
- Оптимизированные индексы
- Batch операции

### Примеры SQL запросов:
```sql
-- Получение статистики по дням недели
SELECT strftime('%w', datetime(created_at/1000, 'unixepoch')) as weekday,
       AVG(mood_value) as avg_mood,
       COUNT(*) as count
FROM mood_entries
GROUP BY weekday;

-- Самые популярные активности
SELECT a.name, COUNT(*) as usage_count
FROM activities a
JOIN mood_activities ma ON a.id = ma.activity_id
GROUP BY a.id
ORDER BY usage_count DESC
LIMIT 5;
```

### Тестирование:
- 🧪 **Комплексное покрытие** SQL базы данных (Drift + SQLite)
- ✅ **260+ unit тестов** включая SQL-специфичные тесты и миграции
- 📦 **Полное тестирование** Drift моделей и SQL запросов
- 🔄 **Интеграционные тесты** для трех баз данных (ObjectBox + Realm + SQLite)
- 📊 **SQL Analytics тесты** для сложных JOIN запросов и агрегаций
- 🏗️ **Миграционные тесты** для schema versioning и DDL команд
- ⚡ **Mock объекты** для изоляции unit тестов всех слоев
- 📋 **Полное покрытие** Realm моделей (StatisticsModel, TagModel)
- 🔧 **Method channel мокинг** для Flutter плагинов

**Примечание:** База данных создается автоматически при первом запуске с начальными данными. Поддерживается полная совместимость с предыдущими ветками.

## Запуск проекта

```bash
# Клонирование репозитория
git clone https://github.com/dzolotov/moodtracker.git
cd moodtracker

# Переключение на нужную ветку
git checkout 05_sql

# Установка зависимостей
flutter pub get

# Генерация кода для Drift
flutter pub run build_runner build --delete-conflicting-outputs

# Запуск приложения
flutter run
```

## Требования

- Flutter 3.7.2 или выше
- Dart SDK 3.7.2 или выше
- Для некоторых веток:
  - Firebase проект (для веток с Firebase)
  - Android Studio / Xcode (для нативных функций)

## Использование

Каждая ветка содержит README с подробным описанием реализованного функционала и используемых технологий. Переключайтесь между ветками для изучения различных подходов к персистентности.

## Лицензия

MIT License
