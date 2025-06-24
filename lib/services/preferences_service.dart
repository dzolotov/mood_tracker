import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _lastOpenedKey = 'last_opened';
  static const String _appOpenCountKey = 'app_open_count';
  static const String _favoriteActivitiesKey = 'favorite_activities';
  static const String _defaultMoodReminderKey = 'default_mood_reminder';
  
  bool _notificationsEnabled = true;
  DateTime? _lastOpened;
  int _appOpenCount = 0;
  List<String> _favoriteActivities = [];
  double _defaultMoodReminder = 20.0; // время напоминания в часах
  
  bool get notificationsEnabled => _notificationsEnabled;
  DateTime? get lastOpened => _lastOpened;
  int get appOpenCount => _appOpenCount;
  List<String> get favoriteActivities => _favoriteActivities;
  double get defaultMoodReminder => _defaultMoodReminder;
  
  PreferencesService() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Пример getBool с дефолтным значением
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    
    // Пример getInt
    _appOpenCount = prefs.getInt(_appOpenCountKey) ?? 0;
    _appOpenCount++; // Увеличиваем счетчик при каждом запуске
    await prefs.setInt(_appOpenCountKey, _appOpenCount);
    
    // Пример getString и парсинг DateTime
    final lastOpenedString = prefs.getString(_lastOpenedKey);
    if (lastOpenedString != null) {
      _lastOpened = DateTime.tryParse(lastOpenedString);
    }
    
    // Сохраняем текущее время открытия
    await prefs.setString(_lastOpenedKey, DateTime.now().toIso8601String());
    
    // Пример getStringList
    _favoriteActivities = prefs.getStringList(_favoriteActivitiesKey) ?? [];
    
    // Пример getDouble
    _defaultMoodReminder = prefs.getDouble(_defaultMoodReminderKey) ?? 20.0;
    
    notifyListeners();
  }
  
  // Пример setBool
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }
  
  // Пример setStringList
  Future<void> updateFavoriteActivities(List<String> activities) async {
    _favoriteActivities = List.from(activities);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteActivitiesKey, activities);
    notifyListeners();
  }
  
  // Пример setDouble
  Future<void> setDefaultMoodReminder(double hours) async {
    _defaultMoodReminder = hours;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_defaultMoodReminderKey, hours);
    notifyListeners();
  }
  
  // Пример containsKey
  Future<bool> hasUserOpenedAppBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_lastOpenedKey);
  }
  
  // Пример getKeys
  Future<Set<String>> getAllPreferenceKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys();
  }
  
  // Пример clear (очистка всех настроек)
  Future<void> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Перезагружаем дефолтные значения
    _notificationsEnabled = true;
    _lastOpened = null;
    _appOpenCount = 0;
    _favoriteActivities = [];
    _defaultMoodReminder = 20.0;
    
    notifyListeners();
  }
  
  // Пример reload (перезагрузка настроек с диска)
  Future<void> reloadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    await _loadPreferences();
  }
}