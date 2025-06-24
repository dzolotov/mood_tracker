import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mood_tracker_plus/main.dart';
import 'package:mood_tracker_plus/screens/home_screen.dart';
import 'package:mood_tracker_plus/services/mood_service.dart';
import 'package:mood_tracker_plus/services/theme_service.dart';

void main() {
  group('MyApp', () {
    testWidgets('app starts correctly with all providers', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify that the app starts with HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Verify app title in AppBar
      expect(find.text('MoodTracker++'), findsOneWidget);

      // Verify that the FloatingActionButton is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
      
      // Verify that the add icon is present
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('app provides MoodService', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify MoodService is available
      final context = tester.element(find.byType(HomeScreen));
      final moodService = Provider.of<MoodService>(context, listen: false);
      expect(moodService, isNotNull);
      expect(moodService.entries, isEmpty);
    });

    testWidgets('app provides ThemeService', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify ThemeService is available
      final context = tester.element(find.byType(HomeScreen));
      final themeService = Provider.of<ThemeService>(context, listen: false);
      expect(themeService, isNotNull);
      expect(themeService.themeMode, ThemeMode.light);
    });

    testWidgets('app uses Material3 design', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Get the MaterialApp
      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      
      // Verify Material3 is enabled
      expect(materialApp.theme?.useMaterial3, true);
      expect(materialApp.darkTheme?.useMaterial3, true);
    });

    testWidgets('app has correct theme configuration', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Get the MaterialApp
      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      
      // Verify theme configuration
      expect(materialApp.title, 'MoodTracker++');
      expect(materialApp.theme?.colorScheme.primary, isNotNull);
      expect(materialApp.darkTheme?.colorScheme.brightness, Brightness.dark);
    });

    testWidgets('app responds to theme changes', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Get theme service and verify initial state
      final context = tester.element(find.byType(HomeScreen));
      final themeService = Provider.of<ThemeService>(context, listen: false);
      
      // Initial theme should be light
      var materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(materialApp.themeMode, ThemeMode.light);

      // Change theme
      themeService.toggleTheme();
      await tester.pump();

      // Verify theme changed
      materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(materialApp.themeMode, ThemeMode.dark);
    });

    testWidgets('app has bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify bottom navigation exists
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verify navigation items
      expect(find.text('Главная'), findsOneWidget);
      expect(find.text('История'), findsOneWidget);
      // 'Статистика' может встречаться несколько раз
      expect(find.text('Статистика'), findsWidgets);
    });

    testWidgets('app has theme toggle button', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify theme toggle button exists
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });
  });
}
