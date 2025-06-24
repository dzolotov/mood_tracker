import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_tracker_plus/services/mood_service.dart';
import 'package:mood_tracker_plus/services/theme_service.dart';
import 'package:mood_tracker_plus/services/preferences_service.dart';
import 'package:mood_tracker_plus/services/auth_service.dart';

/// Инициализирует SharedPreferences для тестов
void initializeSharedPreferences() {
  SharedPreferences.setMockInitialValues({});
}

/// Создает виджет с необходимыми провайдерами для тестирования
Widget createTestApp({
  required Widget child,
  MoodService? moodService,
  ThemeService? themeService,
  PreferencesService? preferencesService,
  AuthService? authService,
}) {
  return MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: moodService ?? MoodService(),
        ),
        ChangeNotifierProvider.value(
          value: themeService ?? ThemeService(),
        ),
        ChangeNotifierProvider.value(
          value: preferencesService ?? PreferencesService(),
        ),
        ChangeNotifierProvider.value(
          value: authService ?? AuthService(),
        ),
      ],
      child: child,
    ),
  );
}