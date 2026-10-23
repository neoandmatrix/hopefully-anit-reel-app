import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/settings.dart';

const _messages = [
  (
    '📰 India today, in 2 minutes',
    'Fresh news cards are waiting. Swipe those instead.',
  ),
  ('🧠 Quick swipe?', 'A few cards now beats an hour of reels.'),
  (
    '🇮🇳 Know your country',
    "Today's current affairs and a bit of GK are ready.",
  ),
  (
    '🎯 Your daily goal is waiting',
    'Swipe through a few cards and keep the habit going.',
  ),
  ('⚡ Reels can wait', 'Learn 5 new things about India first.'),
];

/// Picks the reminder text. Rotates by day and slot so it doesn't feel
/// repetitive. Tonight's last reminder warns about a streak at risk.
(String, String) reminderMessage({
  required int slot,
  required int dayOffset,
  required DateTime date,
  required int streak,
  required bool lastSlotToday,
}) {
  if (dayOffset == 0 && lastSlotToday && streak > 0) {
    return (
      '🔥 Your $streak-day streak ends at midnight',
      'A few cards now keeps it alive.',
    );
  }
  final dayOfYear = date.difference(DateTime(date.year)).inDays;
  return _messages[(dayOfYear * 2 + slot) % _messages.length];
}

/// Daily reminder notifications (Android only).
///
/// Instead of one repeating alarm, each reminder is scheduled as one-off
/// notifications for the next 7 days. That lets today's reminders be skipped
/// once the goal is met and the evening one mention the streak. Rescheduled on
/// every app open, settings change and when the goal is reached.
class Reminders {
  Reminders._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static const _days = 7;

  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> init() async {
    if (!supported || _ready) return;
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_notify'),
      ),
    );
    _ready = true;
  }

  /// Asks for the Android 13+ notification permission. Returns false if denied.
  static Future<bool> requestPermission() async {
    if (!supported) return false;
    await init();
    return await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;
  }

  static Future<void> reschedule({
    required List<Reminder> reminders,
    required bool goalMetToday,
    required int streak,
  }) async {
    if (!supported) return;
    await init();
    await _plugin.cancelAll();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminders',
        'Daily reminders',
        channelDescription: 'Nudges to swipe learning cards instead of reels',
        importance: Importance.defaultImportance,
        icon: 'ic_stat_notify',
      ),
    );

    final now = tz.TZDateTime.now(tz.local);
    final enabled = [
      for (var i = 0; i < reminders.length; i++)
        if (reminders[i].enabled) i,
    ];
    for (var day = 0; day < _days; day++) {
      if (day == 0 && goalMetToday) continue;
      for (final slot in enabled) {
        final r = reminders[slot];
        final at = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + day,
          r.hour,
          r.minute,
        );
        if (!at.isAfter(now)) continue;
        final lastSlotToday =
            slot ==
            enabled.reduce(
              (a, b) =>
                  _minutes(reminders[a]) >= _minutes(reminders[b]) ? a : b,
            );
        final (title, body) = reminderMessage(
          slot: slot,
          dayOffset: day,
          date: at,
          streak: streak,
          lastSlotToday: lastSlotToday,
        );
        await _plugin.zonedSchedule(
          id: slot * 100 + day,
          scheduledDate: at,
          notificationDetails: details,
          // Inexact: no special alarm permission needed; may arrive a few minutes late.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: title,
          body: body,
        );
      }
    }
  }

  static int _minutes(Reminder r) => r.hour * 60 + r.minute;
}
