import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker_plus/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeService', () {
    late ThemeService themeService;

    // Функция для инициализации SharedPreferences с моком
    Future<void> initSharedPreferences([Map<String, Object>? values]) async {
      SharedPreferences.setMockInitialValues(values ?? {});
      themeService = ThemeService();
      // Даем время для загрузки темы
      await Future.delayed(const Duration(milliseconds: 100));
    }

    tearDown(() {
      // Очищаем мок после каждого теста
      SharedPreferences.setMockInitialValues({});
    });

    test('should start with light theme when no saved preference', () async {
      await initSharedPreferences();
      
      expect(themeService.themeMode, ThemeMode.light);
      expect(themeService.isDarkMode, false);
    });

    test('should load saved dark theme preference', () async {
      await initSharedPreferences({'theme_mode': true});
      
      expect(themeService.themeMode, ThemeMode.dark);
      expect(themeService.isDarkMode, true);
    });

    test('should load saved light theme preference', () async {
      await initSharedPreferences({'theme_mode': false});
      
      expect(themeService.themeMode, ThemeMode.light);
      expect(themeService.isDarkMode, false);
    });

    group('toggleTheme', () {
      test('should toggle from light to dark and save preference', () async {
        await initSharedPreferences();
        
        await themeService.toggleTheme();
        
        expect(themeService.themeMode, ThemeMode.dark);
        expect(themeService.isDarkMode, true);
        
        // Проверяем, что значение сохранено
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('theme_mode'), true);
      });

      test('should toggle from dark to light and save preference', () async {
        await initSharedPreferences({'theme_mode': true});
        
        await themeService.toggleTheme();
        
        expect(themeService.themeMode, ThemeMode.light);
        expect(themeService.isDarkMode, false);
        
        // Проверяем, что значение сохранено
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('theme_mode'), false);
      });

      test('should notify listeners when toggled', () async {
        await initSharedPreferences();
        
        bool notified = false;
        themeService.addListener(() => notified = true);
        
        await themeService.toggleTheme();
        
        expect(notified, true);
      });
    });

    group('setThemeMode', () {
      test('should set theme to dark and save preference', () async {
        await initSharedPreferences();
        
        await themeService.setThemeMode(ThemeMode.dark);
        
        expect(themeService.themeMode, ThemeMode.dark);
        expect(themeService.isDarkMode, true);
        
        // Проверяем, что значение сохранено
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('theme_mode'), true);
      });

      test('should set theme to light and save preference', () async {
        await initSharedPreferences({'theme_mode': true});
        
        await themeService.setThemeMode(ThemeMode.light);
        
        expect(themeService.themeMode, ThemeMode.light);
        expect(themeService.isDarkMode, false);
        
        // Проверяем, что значение сохранено
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('theme_mode'), false);
      });

      test('should set theme to system', () async {
        await initSharedPreferences();
        
        await themeService.setThemeMode(ThemeMode.system);
        
        expect(themeService.themeMode, ThemeMode.system);
        expect(themeService.isDarkMode, false); // system != dark
      });

      test('should notify listeners when theme is set', () async {
        await initSharedPreferences();
        
        bool notified = false;
        themeService.addListener(() => notified = true);
        
        await themeService.setThemeMode(ThemeMode.dark);
        
        expect(notified, true);
      });

      test('should notify listeners even when setting same theme', () async {
        await initSharedPreferences();
        
        int notificationCount = 0;
        themeService.addListener(() => notificationCount++);
        
        await themeService.setThemeMode(ThemeMode.light);
        expect(notificationCount, 1);
        
        await themeService.setThemeMode(ThemeMode.light);
        expect(notificationCount, 2);
      });
    });

    group('isDarkMode getter', () {
      test('should return false for light mode', () async {
        await initSharedPreferences();
        
        await themeService.setThemeMode(ThemeMode.light);
        expect(themeService.isDarkMode, false);
      });

      test('should return true for dark mode', () async {
        await initSharedPreferences();
        
        await themeService.setThemeMode(ThemeMode.dark);
        expect(themeService.isDarkMode, true);
      });

      test('should return false for system mode', () async {
        await initSharedPreferences();
        
        await themeService.setThemeMode(ThemeMode.system);
        expect(themeService.isDarkMode, false);
      });
    });

    group('persistence', () {
      test('should persist theme choice across service instances', () async {
        // Первый экземпляр сервиса
        await initSharedPreferences();
        await themeService.setThemeMode(ThemeMode.dark);
        
        // Создаем новый экземпляр сервиса
        final newThemeService = ThemeService();
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Проверяем, что тема загрузилась правильно
        expect(newThemeService.themeMode, ThemeMode.dark);
        expect(newThemeService.isDarkMode, true);
      });
    });
  });
}