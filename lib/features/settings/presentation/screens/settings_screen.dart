import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final notificationsEnabled = ref.watch(notificationSettingsProvider);
    final preferences = ref.watch(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          authState.value != null
              ? ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(authState.value!.nickname),
                  subtitle: Text(authState.value!.email),
                  trailing: authState.value!.isSubscriber
                      ? const Chip(label: Text('Premium'))
                      : null,
                )
              : ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Guest Mode'),
                  subtitle: const Text('Sign in to sync across devices'),
                  trailing: TextButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('Sign In'),
                  ),
                ),
          
          if (authState.value != null)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signed out successfully')),
                  );
                }
              },
            ),

          const Divider(),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: Text(_getThemeModeLabel(themeMode)),
            onTap: () => _showThemeDialog(context, ref, themeMode),
          ),

          const Divider(),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive reminders for schedules'),
            value: notificationsEnabled,
            onChanged: (value) {
              ref.read(notificationSettingsProvider.notifier).toggle();
            },
          ),

          const Divider(),

          // Calendar Preferences
          _buildSectionHeader('Calendar'),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Default Schedule Duration'),
            subtitle: Text('${preferences.defaultScheduleDuration} minutes'),
            onTap: () => _showDurationDialog(context, ref, preferences.defaultScheduleDuration),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.calendar_today),
            title: const Text('Show Week Numbers'),
            value: preferences.showWeekNumbers,
            onChanged: (value) {
              ref.read(userPreferencesProvider.notifier).toggleWeekNumbers();
            },
          ),
          ListTile(
            leading: const Icon(Icons.today),
            title: const Text('First Day of Week'),
            subtitle: Text(_getWeekDayLabel(preferences.firstDayOfWeek)),
            onTap: () => _showFirstDayDialog(context, ref, preferences.firstDayOfWeek),
          ),

          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0+1'),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Privacy Policy'),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Terms of Service'),
            onTap: () {
              // TODO: Open terms
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  String _getThemeModeLabel(ThemeModeEnum mode) {
    switch (mode) {
      case ThemeModeEnum.light:
        return 'Light';
      case ThemeModeEnum.dark:
        return 'Dark';
      case ThemeModeEnum.system:
        return 'System Default';
    }
  }

  String _getWeekDayLabel(int day) {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[day];
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeModeEnum current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeModeEnum.values.map((mode) {
            return RadioListTile<ThemeModeEnum>(
              title: Text(_getThemeModeLabel(mode)),
              value: mode,
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDurationDialog(BuildContext context, WidgetRef ref, int current) {
    final durations = [15, 30, 60, 90, 120];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: durations.map((duration) {
            return RadioListTile<int>(
              title: Text('$duration minutes'),
              value: duration,
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  ref.read(userPreferencesProvider.notifier).updateDefaultDuration(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFirstDayDialog(BuildContext context, WidgetRef ref, int current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('First Day of Week'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('Monday'),
              value: 1,
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  ref.read(userPreferencesProvider.notifier).setFirstDayOfWeek(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('Sunday'),
              value: 7,
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  ref.read(userPreferencesProvider.notifier).setFirstDayOfWeek(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
