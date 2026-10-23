import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_smart/core/reminders.dart';
import 'package:scroll_smart/data/db/app_db.dart';
import 'package:scroll_smart/data/models/learn_card.dart';
import 'package:scroll_smart/data/repo/content_repo.dart';
import 'package:scroll_smart/data/settings.dart';
import 'package:scroll_smart/data/stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

LearnCard quizCard(String id, String category) => LearnCard(
  id: id,
  type: CardType.gk,
  category: category,
  headline: id,
  body: 'b',
  quiz: const Quiz(question: 'q', options: ['a', 'b', 'c', 'd'], answer: 0),
);

void main() {
  group('computeStreak', () {
    final today = DateTime(2026, 10, 24, 15);

    test('counts back from today when today is met', () {
      final s = computeStreak({
        '2026-10-22',
        '2026-10-23',
        '2026-10-24',
      }, today);
      expect(s.current, 3);
      expect(s.best, 3);
    });

    test('today not met yet keeps yesterday\'s streak alive', () {
      expect(computeStreak({'2026-10-22', '2026-10-23'}, today).current, 2);
    });

    test('a missed day breaks it; best remembers the longest run', () {
      final s = computeStreak({
        '2026-10-01',
        '2026-10-02',
        '2026-10-03',
        '2026-10-04',
        '2026-10-23',
      }, today);
      expect(s.current, 1);
      expect(s.best, 4);
    });

    test('runs across month boundaries', () {
      final s = computeStreak({
        '2026-09-30',
        '2026-10-01',
      }, DateTime(2026, 10, 1));
      expect(s.current, 2);
    });

    test('empty', () {
      final s = computeStreak({}, today);
      expect((s.current, s.best), (0, 0));
    });
  });

  group('activity logging', () {
    late AppDb db;
    late ContentRepo repo;
    var now = DateTime(2026, 10, 24, 9);
    var goal = 20;

    setUp(() {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      db = AppDb(NativeDatabase.memory());
      repo = ContentRepo(db, dailyGoal: () => goal, clock: () => now);
    });
    tearDown(() => db.close());

    test('first read and every quiz answer count towards today', () async {
      await repo.upsertCards([
        quizCard('a', 'polity'),
        quizCard('b', 'economy'),
      ]);
      await repo.markSeen('a');
      await repo.markSeen('a'); // re-reading doesn't count
      await repo.recordQuiz('b', correct: true);
      await repo.recordQuiz('b', correct: false);

      final log = (await repo.watchDayLogs().first).single;
      expect(log.day, '2026-10-24');
      expect(log.seen, 3);
      expect(log.quizAttempts, 2);
      expect(log.quizCorrect, 1);
      expect(log.goal, 20);
    });

    test('a new day gets its own row with the goal at that time', () async {
      await repo.markSeen('a');
      now = DateTime(2026, 10, 25, 9);
      goal = 10;
      await repo.markSeen('b');
      final logs = await repo.watchDayLogs().first;
      expect(logs.map((l) => (l.day, l.seen, l.goal)), [
        ('2026-10-24', 1, 20),
        ('2026-10-25', 1, 10),
      ]);
      now = DateTime(2026, 10, 24, 9);
      goal = 20;
    });

    test('accuracy is grouped by category', () async {
      await repo.upsertCards([
        quizCard('a', 'polity'),
        quizCard('b', 'economy'),
      ]);
      await repo.recordQuiz('a', correct: true);
      await repo.recordQuiz('a', correct: true);
      await repo.recordQuiz('b', correct: false);
      final acc = {
        for (final c in await repo.categoryAccuracy()) c.category: c,
      };
      expect((acc['polity']!.correct, acc['polity']!.attempts), (2, 2));
      expect(acc['economy']!.accuracy, 0);
    });

    test('recap uses only quiz cards read today', () async {
      await repo.upsertCards([
        quizCard('today', 'polity'),
        quizCard('old', 'polity'),
        const LearnCard(
          id: 'noquiz',
          type: CardType.gk,
          category: 'polity',
          headline: 'x',
          body: 'b',
        ),
      ]);
      now = DateTime(2026, 10, 23, 9);
      await repo.markSeen('old');
      now = DateTime(2026, 10, 24, 9);
      await repo.markSeen('today');
      await repo.markSeen('noquiz');
      expect((await repo.todaysQuizCards()).map((c) => c.id), ['today']);
    });
  });

  test('migrating a v2 database keeps data and backfills days', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final seenAt = DateTime(2026, 10, 22, 10).millisecondsSinceEpoch ~/ 1000;
    final db = AppDb(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute('''
            CREATE TABLE cards (id TEXT NOT NULL PRIMARY KEY, type TEXT NOT NULL,
              category TEXT NOT NULL, date TEXT NULL, payload TEXT NOT NULL,
              added_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)));
            CREATE TABLE card_states (card_id TEXT NOT NULL PRIMARY KEY, seen_at INTEGER NULL,
              saved INTEGER NOT NULL DEFAULT 0, knowledge INTEGER NOT NULL DEFAULT 0,
              review_from INTEGER NULL, review_stage INTEGER NOT NULL DEFAULT 0,
              quiz_attempts INTEGER NOT NULL DEFAULT 0, quiz_correct INTEGER NOT NULL DEFAULT 0);
            CREATE TABLE synced_files (file TEXT NOT NULL PRIMARY KEY, version TEXT NOT NULL);
            INSERT INTO card_states (card_id, seen_at, saved) VALUES ('a', $seenAt, 1), ('b', $seenAt, 0);
          ''');
          raw.userVersion = 2;
        },
      ),
    );
    final repo = ContentRepo(db);
    final logs = await repo.watchDayLogs().first;
    expect(logs.single.day, '2026-10-22');
    expect(logs.single.seen, 2);
    expect((await repo.allStates())['a']!.saved, isTrue);
    await db.close();
  });

  test('settings persist and survive bad stored values', () async {
    SharedPreferences.setMockInitialValues({
      'daily_goal': 7,
      'reminders': ['junk'],
    });
    final prefs = await SharedPreferences.getInstance();
    var container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    var s = container.read(settingsProvider);
    expect(s.dailyGoal, 20);
    expect(s.reminders, AppSettings.defaultReminders);

    final notifier = container.read(settingsProvider.notifier);
    await notifier.setDailyGoal(30);
    await notifier.setReminder(
      1,
      const Reminder(enabled: false, hour: 21, minute: 30),
    );
    await notifier.toggleCategory('sports');
    container.dispose();

    container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    s = container.read(settingsProvider);
    expect(s.dailyGoal, 30);
    expect(s.reminders[1].encode(), '0:21:30');
    expect(s.mutedCategories, {'sports'});
    container.dispose();
  });

  group('reminderMessage', () {
    final date = DateTime(2026, 10, 24, 22);

    test('tonight\'s last reminder warns about the streak', () {
      final (title, _) = reminderMessage(
        slot: 1,
        dayOffset: 0,
        date: date,
        streak: 4,
        lastSlotToday: true,
      );
      expect(title, contains('4-day streak'));
    });

    test('no streak warning on other days, slots or with no streak', () {
      for (final (day, last, streak) in [
        (1, true, 4),
        (0, false, 4),
        (0, true, 0),
      ]) {
        final (title, _) = reminderMessage(
          slot: 1,
          dayOffset: day,
          date: date,
          streak: streak,
          lastSlotToday: last,
        );
        expect(title, isNot(contains('streak')));
      }
    });

    test('messages rotate between days', () {
      final titles = {
        for (var d = 0; d < 5; d++)
          reminderMessage(
            slot: 0,
            dayOffset: d + 1,
            date: date.add(Duration(days: d)),
            streak: 0,
            lastSlotToday: false,
          ).$1,
      };
      expect(titles.length, greaterThan(1));
    });
  });
}
