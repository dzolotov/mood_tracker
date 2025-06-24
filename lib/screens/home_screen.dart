import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mood_service.dart';
import '../services/theme_service.dart';
import 'add_mood_screen.dart';
import 'mood_history_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MoodDashboard(),
    const MoodHistoryScreen(),
    const StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoodTracker++'),
        centerTitle: true,
        actions: [
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return IconButton(
                icon: Icon(
                  themeService.isDarkMode 
                      ? Icons.light_mode 
                      : Icons.dark_mode,
                ),
                onPressed: () => themeService.toggleTheme(),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'История',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Статистика',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddMoodScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class MoodDashboard extends StatelessWidget {
  const MoodDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final moodService = context.watch<MoodService>();
    final todayEntries = moodService.getEntriesByDateRange(
      DateTime.now().copyWith(hour: 0, minute: 0, second: 0),
      DateTime.now(),
    );
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Как вы себя чувствуете сегодня?',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  if (todayEntries.isEmpty)
                    const Text('Вы еще не записали настроение сегодня')
                  else
                    Column(
                      children: todayEntries.map((entry) {
                        return ListTile(
                          leading: Text(
                            entry.mood.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          title: Text(entry.mood.label),
                          subtitle: Text(
                            '${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: entry.note != null
                              ? const Icon(Icons.note)
                              : null,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Статистика',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Всего записей: ${moodService.entries.length}'),
                  Text(
                    'Средний уровень настроения: ${moodService.getAverageMood().toStringAsFixed(1)}',
                  ),
                  if (moodService.getMostFrequentMood() != null)
                    Text(
                      'Наиболее частое настроение: ${moodService.getMostFrequentMood()!.emoji} ${moodService.getMostFrequentMood()!.label}',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}