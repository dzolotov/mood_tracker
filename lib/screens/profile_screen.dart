import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/preferences_service.dart';
import '../services/secure_storage_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getInitial(AuthService authService) {
    final displayName = authService.user?.displayName?.trim();
    final email = authService.userEmail?.trim();
    final username = authService.username?.trim();
    
    if (displayName != null && displayName.isNotEmpty) {
      return displayName[0].toUpperCase();
    }
    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    if (username != null && username.isNotEmpty) {
      return username[0].toUpperCase();
    }
    return 'U';
  }

  String _getDisplayName(AuthService authService) {
    final displayName = authService.user?.displayName?.trim();
    final username = authService.username?.trim();
    
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    if (username != null && username.isNotEmpty) {
      return username;
    }
    return 'Пользователь';
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final themeService = context.watch<ThemeService>();
    final preferencesService = context.watch<PreferencesService>();

    if (!authService.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              'Вы не авторизованы',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Войти'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const SizedBox(height: 32),
        Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  _getInitial(authService),
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _getDisplayName(authService),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (authService.userEmail != null)
          Text(
            authService.userEmail!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        const SizedBox(height: 32),
        Card(
          child: Column(
            children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(authService.userEmail ?? 'Не указан'),
                ),
                if (authService.user?.uid != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.fingerprint),
                    title: const Text('User ID'),
                    subtitle: Text(authService.user!.uid),
                  ),
                ],
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(
                    themeService.isDarkMode 
                        ? Icons.dark_mode 
                        : Icons.light_mode,
                  ),
                  title: const Text('Темная тема'),
                  subtitle: Text(
                    themeService.isDarkMode ? 'Включена' : 'Выключена',
                  ),
                  value: themeService.isDarkMode,
                  onChanged: (_) => themeService.toggleTheme(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text('Уведомления'),
                  subtitle: Text(
                    preferencesService.notificationsEnabled ? 'Включены' : 'Выключены',
                  ),
                  value: preferencesService.notificationsEnabled,
                  onChanged: (value) => preferencesService.setNotificationsEnabled(value),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('Напоминание о настроении'),
                  subtitle: Text('Каждые ${preferencesService.defaultMoodReminder.toInt()} часов'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final hours = await showDialog<double>(
                      context: context,
                      builder: (context) => _ReminderDialog(
                        currentValue: preferencesService.defaultMoodReminder,
                      ),
                    );
                    if (hours != null) {
                      await preferencesService.setDefaultMoodReminder(hours);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('О приложении'),
                  subtitle: const Text('MoodTracker++ v1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'MoodTracker++',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.mood, size: 48),
                      children: const [
                        Text(
                          'Приложение для отслеживания настроения и сна.\n\n'
                          'Демонстрация работы с SharedPreferences.',
                        ),
                      ],
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('Статистика использования'),
                  subtitle: Text('Приложение открыто ${preferencesService.appOpenCount} раз'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Безопасное хранилище'),
                  subtitle: const Text('Просмотр сохраненных данных'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final hasToken = await SecureStorageService.hasToken();
                    final userId = await SecureStorageService.getUserId();
                    
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Secure Storage'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Firebase Token: ${hasToken ? "Сохранен" : "Отсутствует"}'),
                              const SizedBox(height: 8),
                              Text('User ID: ${userId ?? "Не сохранен"}'),
                              const SizedBox(height: 8),
                              const Text(
                                'Данные зашифрованы и хранятся в Keychain (iOS/macOS) или Keystore (Android)',
                                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Закрыть'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Выход'),
                    content: const Text('Вы уверены, что хотите выйти?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Выйти'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await authService.logout();
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Выйти'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.red,
              ),
            ),
          const SizedBox(height: 16),
      ],
    );
  }
}

class _ReminderDialog extends StatefulWidget {
  final double currentValue;
  
  const _ReminderDialog({required this.currentValue});
  
  @override
  State<_ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<_ReminderDialog> {
  late double _value;
  
  @override
  void initState() {
    super.initState();
    _value = widget.currentValue;
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Интервал напоминаний'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${_value.toInt()} часов'),
          Slider(
            value: _value,
            min: 1,
            max: 48,
            divisions: 47,
            label: '${_value.toInt()} ч',
            onChanged: (value) => setState(() => _value = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _value),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}