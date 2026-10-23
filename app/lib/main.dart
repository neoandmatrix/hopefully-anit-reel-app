import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/reminders.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'data/providers.dart';
import 'data/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const ScrollSmartApp(),
    ),
  );
}

/// What the reminder schedule depends on; rescheduled whenever it changes.
final _reminderPlanProvider =
    Provider<({List<Reminder> reminders, bool goalMet, int streak})?>((ref) {
      if (!ref.watch(dayLogsProvider).hasValue) return null;
      final today = ref.watch(todayProvider);
      return (
        reminders: ref.watch(settingsProvider.select((s) => s.reminders)),
        goalMet: today.seen >= today.goal,
        streak: ref.watch(streakProvider).current,
      );
    });

class ScrollSmartApp extends ConsumerStatefulWidget {
  const ScrollSmartApp({super.key});

  @override
  ConsumerState<ScrollSmartApp> createState() => _ScrollSmartAppState();
}

class _ScrollSmartAppState extends ConsumerState<ScrollSmartApp> {
  static const _askedKey = 'asked_notification_permission';

  @override
  void initState() {
    super.initState();
    _askPermissionOnce();
    ref.listenManual(_reminderPlanProvider, (_, plan) {
      if (plan == null) return;
      Reminders.reschedule(
        reminders: plan.reminders,
        goalMetToday: plan.goalMet,
        streak: plan.streak,
      );
    }, fireImmediately: true);
  }

  /// Reminders are on by default, so ask for the Android 13+ permission once.
  Future<void> _askPermissionOnce() async {
    final prefs = ref.read(sharedPrefsProvider);
    if (!Reminders.supported || (prefs.getBool(_askedKey) ?? false)) return;
    await prefs.setBool(_askedKey, true);
    await Reminders.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Scroll Smart',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      scrollBehavior: const AppScrollBehavior(),
      routerConfig: router,
    );
  }
}
