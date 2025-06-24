# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MoodTracker++ is a Flutter demonstration app for teaching different persistence approaches. This branch (01_shared_prefs) demonstrates SharedPreferences usage for persisting user preferences and authentication state.

## Common Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run static analysis
flutter analyze

# Run tests
flutter test

# Build for specific platforms
flutter build apk     # Android
flutter build ios     # iOS (requires macOS)
flutter build web     # Web
```

## Architecture

The app follows a clean architecture pattern with Provider for state management:

- **State Management**: Provider pattern with ChangeNotifier (MoodService, ThemeService)
- **Data Flow**: Unidirectional - UI reads from services, modifications go through service methods
- **Models**: Immutable data classes with copyWith pattern (MoodEntry)
- **Screens**: Separate screens for different features (home, add mood, history, statistics)

### Key Components

- `MoodService` (lib/services/mood_service.dart): Central state management, handles all mood entries in memory
- `ThemeService` (lib/services/theme_service.dart): Theme management with SharedPreferences persistence
- `AuthService` (lib/services/auth_service.dart): User authentication with SharedPreferences persistence
- `MoodEntry` (lib/models/mood_entry.dart): Data model with MoodType enum and sleep tracking fields (sleepTime, wakeTime, sleepDuration)
- App uses Material 3 design system with Russian localization for dates

### Features

- Mood tracking with emojis and color indicators
- Sleep tracking (sleep time, wake time, duration)
- Activity tagging
- Notes for each mood entry
- Dark/light theme switching (persisted in SharedPreferences)
- User authentication with login/logout (persisted in SharedPreferences)
- Profile screen showing logged-in user
- Statistics and mood history

### Authentication

- Login with any username and password "password"
- Authentication state persisted in SharedPreferences
- Green indicator on profile icon when logged in

### Dependencies

- provider: ^6.1.2 - State management
- intl: ^0.19.0 - Date formatting with Russian locale
- shared_preferences: ^2.3.2 - Local key-value storage

## Important Notes

- This is a teaching project meant to demonstrate different persistence libraries in separate branches
- Current branch (01_shared_prefs) demonstrates SharedPreferences for user preferences
- Only theme preference and authentication state are persisted
- Mood entries are still stored in memory only
- The app is localized for Russian language (date formatting)
- Flutter SDK requirement: ^3.7.2