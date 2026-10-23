import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Reminder {
  const Reminder({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  final bool enabled;
  final int hour;
  final int minute;

  Reminder copyWith({bool? enabled, int? hour, int? minute}) => Reminder(
    enabled: enabled ?? this.enabled,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
  );

  String encode() => '${enabled ? 1 : 0}:$hour:$minute';

  static Reminder? decode(String? raw) {
    final parts = raw?.split(':');
    if (parts == null || parts.length != 3) return null;
    final [e, h, m] = parts.map(int.tryParse).toList();
    if (e == null || h == null || m == null) return null;
    return Reminder(enabled: e == 1, hour: h, minute: m);
  }
}

class AppSettings {
  const AppSettings({
    this.dailyGoal = 20,
    this.reminders = defaultReminders,
    this.mutedCategories = const {},
  });

  static const goalOptions = [10, 20, 30];

  /// Lunch break and bedtime: the usual doomscrolling slots.
  static const defaultReminders = [
    Reminder(enabled: true, hour: 13, minute: 0),
    Reminder(enabled: true, hour: 22, minute: 0),
  ];

  final int dailyGoal;
  final List<Reminder> reminders;
  final Set<String> mutedCategories;

  AppSettings copyWith({
    int? dailyGoal,
    List<Reminder>? reminders,
    Set<String>? mutedCategories,
  }) => AppSettings(
    dailyGoal: dailyGoal ?? this.dailyGoal,
    reminders: reminders ?? this.reminders,
    mutedCategories: mutedCategories ?? this.mutedCategories,
  );
}

/// Overridden in `main()` with the loaded instance.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<AppSettings> {
  static const _goalKey = 'daily_goal';
  static const _remindersKey = 'reminders';
  static const _mutedKey = 'muted_categories';

  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  AppSettings build() {
    final goal = _prefs.getInt(_goalKey);
    final reminders = _prefs
        .getStringList(_remindersKey)
        ?.map(Reminder.decode)
        .whereType<Reminder>()
        .toList();
    return AppSettings(
      dailyGoal: AppSettings.goalOptions.contains(goal) ? goal! : 20,
      reminders: reminders?.length == 2
          ? reminders!
          : AppSettings.defaultReminders,
      mutedCategories: (_prefs.getStringList(_mutedKey) ?? const []).toSet(),
    );
  }

  Future<void> setDailyGoal(int goal) async {
    state = state.copyWith(dailyGoal: goal);
    await _prefs.setInt(_goalKey, goal);
  }

  Future<void> setReminder(int index, Reminder reminder) async {
    final list = [...state.reminders]..[index] = reminder;
    state = state.copyWith(reminders: list);
    await _prefs.setStringList(
      _remindersKey,
      list.map((r) => r.encode()).toList(),
    );
  }

  Future<void> toggleCategory(String category) async {
    final muted = {...state.mutedCategories};
    if (!muted.remove(category)) muted.add(category);
    state = state.copyWith(mutedCategories: muted);
    await _prefs.setStringList(_mutedKey, muted.toList()..sort());
  }
}
