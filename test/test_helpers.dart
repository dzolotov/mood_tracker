import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_tracker_plus/services/auth_service.dart';
import 'package:mood_tracker_plus/services/mood_service.dart';
import 'package:mood_tracker_plus/services/theme_service.dart';
import 'package:mood_tracker_plus/services/preferences_service.dart';
import 'package:mood_tracker_plus/services/file_service.dart';

// Mock classes
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class MockAuthService extends Mock implements AuthService {}
class MockMoodService extends Mock implements MoodService {}
class MockFileService extends Mock implements FileService {}

// Test data
const testEmail = 'test@example.com';
const testPassword = 'password123';
const testDisplayName = 'Test User';
const testUserId = 'test-user-id';

// Helper functions
MockFirebaseAuth createMockFirebaseAuth({
  MockUser? mockUser,
  bool isSignedIn = false,
}) {
  return MockFirebaseAuth(
    mockUser: mockUser ??
        MockUser(
          isAnonymous: false,
          uid: testUserId,
          email: testEmail,
          displayName: testDisplayName,
        ),
    signedIn: isSignedIn,
  );
}

void initializeSharedPreferences({Map<String, Object>? values}) {
  SharedPreferences.setMockInitialValues(values ?? {});
}

Widget createTestApp({
  required Widget child,
  MoodService? moodService,
  ThemeService? themeService,
  AuthService? authService,
  PreferencesService? preferencesService,
  FileService? fileService,
  List<NavigatorObserver>? navigatorObservers,
}) {
  return MaterialApp(
    navigatorObservers: navigatorObservers ?? [],
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: moodService ?? MoodService(),
        ),
        ChangeNotifierProvider.value(
          value: themeService ?? ThemeService(),
        ),
        ChangeNotifierProvider.value(
          value: authService ?? AuthService(),
        ),
        ChangeNotifierProvider.value(
          value: preferencesService ?? PreferencesService(),
        ),
        ChangeNotifierProvider.value(
          value: fileService ?? FileService(),
        ),
      ],
      child: child,
    ),
  );
}

Widget createTestAppWithRoute({
  required Map<String, WidgetBuilder> routes,
  String initialRoute = '/',
  MoodService? moodService,
  ThemeService? themeService,
  AuthService? authService,
  PreferencesService? preferencesService,
  FileService? fileService,
  List<NavigatorObserver>? navigatorObservers,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: moodService ?? MoodService(),
      ),
      ChangeNotifierProvider.value(
        value: themeService ?? ThemeService(),
      ),
      ChangeNotifierProvider.value(
        value: authService ?? AuthService(),
      ),
      ChangeNotifierProvider.value(
        value: preferencesService ?? PreferencesService(),
      ),
      ChangeNotifierProvider.value(
        value: fileService ?? FileService(),
      ),
    ],
    child: MaterialApp(
      navigatorObservers: navigatorObservers ?? [],
      initialRoute: initialRoute,
      routes: routes,
    ),
  );
}

// Test extensions
extension WidgetTesterExtensions on WidgetTester {
  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    bool found = false;
    final endTime = DateTime.now().add(timeout);

    while (!found && DateTime.now().isBefore(endTime)) {
      await pump();
      found = finder.evaluate().isNotEmpty;
    }

    if (!found) {
      throw TestFailure('Could not find widget: $finder');
    }
  }

  Future<void> scrollUntilVisible(
    Finder finder,
    double delta, {
    Finder? scrollable,
    int maxScrolls = 50,
  }) async {
    final scrollableFinder = scrollable ?? find.byType(Scrollable).first;
    
    for (int i = 0; i < maxScrolls; i++) {
      if (finder.evaluate().isNotEmpty) {
        try {
          await ensureVisible(finder);
          return;
        } catch (_) {
          // Widget found but not visible, continue scrolling
        }
      }
      await drag(scrollableFinder, Offset(0, delta));
      await pump();
    }
    
    throw TestFailure('Could not scroll to find widget: $finder');
  }
}

// Firebase test utilities
Future<void> signInWithMockUser(
  MockFirebaseAuth mockAuth, {
  String email = testEmail,
  String password = testPassword,
}) async {
  await mockAuth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}

Future<void> createMockUser(
  MockFirebaseAuth mockAuth, {
  String email = testEmail,
  String password = testPassword,
}) async {
  await mockAuth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
}