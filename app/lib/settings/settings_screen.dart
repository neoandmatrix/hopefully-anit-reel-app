import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/reminders.dart';
import '../core/theme.dart';
import '../data/providers.dart';
import '../data/settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const _Header('Daily goal'),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: SegmentedButton<int>(
                  segments: [
                    for (final g in AppSettings.goalOptions)
                      ButtonSegment(value: g, label: Text('$g cards')),
                  ],
                  selected: {settings.dailyGoal},
                  onSelectionChanged: (s) => notifier.setDailyGoal(s.first),
                ),
              ),
              const _Header('Reminders'),
              if (!Reminders.supported)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Reminders work in the Android app.',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
              for (var i = 0; i < settings.reminders.length; i++)
                _ReminderTile(index: i, reminder: settings.reminders[i]),
              const _Header('Categories in your feed'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in knownCategories)
                      FilterChip(
                        avatar: Icon(categoryStyle(c).icon, size: 16),
                        label: Text(categoryStyle(c).label),
                        selected: !settings.mutedCategories.contains(c),
                        onSelected: (_) => notifier.toggleCategory(c),
                      ),
                  ],
                ),
              ),
              const _Header('Content'),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh content now'),
                subtitle: const Text('Download the latest news and packs'),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final count = await ref.read(syncServiceProvider).sync();
                  ref.invalidate(feedProvider);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        count == 0
                            ? 'Already up to date (or offline)'
                            : 'Downloaded $count cards',
                      ),
                    ),
                  );
                },
              ),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('About'),
                subtitle: Text(
                  'News summarised daily from The Hindu, Indian Express, LiveMint '
                  'and PIB. Always check the source link for details.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    ),
  );
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile({required this.index, required this.reminder});

  final int index;
  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);
    final time = TimeOfDay(hour: reminder.hour, minute: reminder.minute);
    return SwitchListTile(
      secondary: Icon(
        index == 0 ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
      ),
      title: InkWell(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time,
          );
          if (picked != null) {
            await notifier.setReminder(
              index,
              reminder.copyWith(hour: picked.hour, minute: picked.minute),
            );
          }
        },
        child: Text(
          time.format(context),
          style: const TextStyle(
            fontSize: 18,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      subtitle: Text(
        index == 0 ? 'Daytime nudge' : 'Evening nudge (mentions your streak)',
      ),
      value: reminder.enabled,
      onChanged: (on) async {
        if (on && !await Reminders.requestPermission() && Reminders.supported) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Allow notifications in Android settings to get reminders',
                ),
              ),
            );
          }
        }
        await notifier.setReminder(index, reminder.copyWith(enabled: on));
      },
    );
  }
}
