import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker_plus/services/theme_service.dart';

void main() {
  group('ThemeService', () {
    late ThemeService themeService;

    setUp(() {
      themeService = ThemeService();
    });

    test('should start with light theme', () {
      expect(themeService.themeMode, ThemeMode.light);
      expect(themeService.isDarkMode, false);
    });

    group('toggleTheme', () {
      test('should toggle from light to dark', () {
        themeService.toggleTheme();
        
        expect(themeService.themeMode, ThemeMode.dark);
        expect(themeService.isDarkMode, true);
      });

      test('should toggle from dark to light', () {
        themeService.toggleTheme();
        themeService.toggleTheme();
        
        expect(themeService.themeMode, ThemeMode.light);
        expect(themeService.isDarkMode, false);
      });

      test('should notify listeners when toggled', () {
        bool notified = false;
        themeService.addListener(() => notified = true);
        
        themeService.toggleTheme();
        
        expect(notified, true);
      });
    });

    group('setThemeMode', () {
      test('should set theme to dark', () {
        themeService.setThemeMode(ThemeMode.dark);
        
        expect(themeService.themeMode, ThemeMode.dark);
        expect(themeService.isDarkMode, true);
      });

      test('should set theme to light', () {
        themeService.setThemeMode(ThemeMode.dark);
        themeService.setThemeMode(ThemeMode.light);
        
        expect(themeService.themeMode, ThemeMode.light);
        expect(themeService.isDarkMode, false);
      });

      test('should set theme to system', () {
        themeService.setThemeMode(ThemeMode.system);
        
        expect(themeService.themeMode, ThemeMode.system);
        expect(themeService.isDarkMode, false); // system != dark
      });

      test('should notify listeners when theme is set', () {
        bool notified = false;
        themeService.addListener(() => notified = true);
        
        themeService.setThemeMode(ThemeMode.dark);
        
        expect(notified, true);
      });

      test('should notify listeners even when setting same theme', () {
        int notificationCount = 0;
        themeService.addListener(() => notificationCount++);
        
        themeService.setThemeMode(ThemeMode.light);
        expect(notificationCount, 1);
        
        themeService.setThemeMode(ThemeMode.light);
        expect(notificationCount, 2);
      });
    });

    group('isDarkMode getter', () {
      test('should return false for light mode', () {
        themeService.setThemeMode(ThemeMode.light);
        expect(themeService.isDarkMode, false);
      });

      test('should return true for dark mode', () {
        themeService.setThemeMode(ThemeMode.dark);
        expect(themeService.isDarkMode, true);
      });

      test('should return false for system mode', () {
        themeService.setThemeMode(ThemeMode.system);
        expect(themeService.isDarkMode, false);
      });
    });
  });
}