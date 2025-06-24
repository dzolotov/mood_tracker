# Secure Storage Features in MoodTracker++

## Overview
This branch demonstrates the use of Flutter Secure Storage and Firebase Authentication for secure credential management.

## Key Features

### 1. Firebase Authentication
- **Email/Password Authentication**: Users can register and login with email
- **Password Reset**: Send reset instructions via email
- **Profile Management**: Update display name and email
- **Account Deletion**: Secure deletion with re-authentication

### 2. Flutter Secure Storage
Secure storage is used for sensitive data:
- **Firebase ID Tokens**: Automatically refreshed tokens
- **User Credentials**: Optional "Remember me" for auto-login
- **User ID**: Firebase UID for quick access

Data is stored in:
- iOS/macOS: Keychain
- Android: AES encryption in Keystore
- Windows: Windows Credential Store

### 3. Security Features
- **Token Refresh**: Automatic token refresh on app start
- **Re-authentication**: Required for sensitive operations
- **Secure Logout**: Clears all stored credentials
- **Email Verification**: Required for email changes

### 4. UI Components

#### Login Screen
- Email/Password input
- Registration/Login toggle
- "Remember me" checkbox
- Password reset link

#### Password Reset Screen
- Standalone screen for password recovery
- Email validation
- Success feedback

#### Profile Screen
- Display user info
- Edit profile button
- Secure storage viewer
- Logout with confirmation

#### Edit Profile Screen
- Update display name
- Change email (with verification)
- Delete account (with re-authentication)
- Password required for sensitive changes

## Code Examples

### Saving Secure Data
```dart
// Save Firebase token
await SecureStorageService.saveToken(idToken);

// Save credentials for auto-login
await SecureStorageService.saveCredentials(email, password);
```

### Reading Secure Data
```dart
// Check if token exists
final hasToken = await SecureStorageService.hasToken();

// Get stored credentials
final credentials = await SecureStorageService.getCredentials();
```

### Clear Secure Data
```dart
// Clear all secure storage
await SecureStorageService.clearAll();

// Clear specific data
await SecureStorageService.clearTokens();
```

## Testing

1. **Register New User**:
   - Go to Profile tab → Login
   - Tap "Нет аккаунта? Зарегистрироваться"
   - Enter email and password (min 6 characters)

2. **Test Auto-login**:
   - Login with "Remember me" checked
   - Restart app - should auto-login

3. **Test Password Reset**:
   - On login screen, tap "Забыли пароль?"
   - Enter registered email
   - Check email for reset link

4. **Test Profile Edit**:
   - Login and go to Profile
   - Tap edit button on avatar
   - Change name (no password needed)
   - Change email (password required)

5. **View Secure Storage**:
   - In Profile, tap "Безопасное хранилище"
   - Shows encrypted token status

## Security Considerations

1. **Never log sensitive data** - tokens are never printed
2. **Use re-authentication** - for email/password changes
3. **Clear on logout** - all secure data is wiped
4. **Encrypted storage** - platform-specific encryption
5. **Token expiration** - Firebase handles token refresh

## Differences from SharedPreferences

| Feature | SharedPreferences | Secure Storage |
|---------|-------------------|----------------|
| Encryption | No | Yes |
| Use Case | User preferences | Sensitive data |
| Platform | Same API | Platform-specific |
| Speed | Fast | Slower |
| Persistence | Until app uninstall | Until app uninstall |

## Migration from Previous Branch

From `01_shared_prefs` to `02_secure_storage`:
- Theme preference still uses SharedPreferences
- Authentication moved to Firebase Auth
- Tokens stored in Secure Storage
- Added password reset functionality
- Enhanced profile management