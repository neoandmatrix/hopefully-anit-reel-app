import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feed/feed_builder.dart';
import 'db/app_db.dart';
import 'models/learn_card.dart';
import 'repo/content_repo.dart';
import 'settings.dart';
import 'stats.dart';
import 'sync_service.dart';

final dbProvider = Provider<AppDb>((ref) {
  final db = AppDb();
  ref.onDispose(db.close);
  return db;
});

final repoProvider = Provider<ContentRepo>(
  (ref) => ContentRepo(
    ref.watch(dbProvider),
    // Read lazily so changing the goal doesn't rebuild the repo.
    dailyGoal: () => ref.read(settingsProvider).dailyGoal,
  ),
);

final syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(ref.watch(repoProvider)),
);

/// The feed is built once per app session (refresh with `ref.invalidate`), so
/// bookmarking or marking a card doesn't reshuffle what you're swiping.
final feedProvider = FutureProvider<List<FeedItem>>((ref) async {
  final repo = ref.watch(repoProvider);
  await repo.seedFromAssets();
  // Don't block startup on a slow network; a late sync is picked up on the
  // next refresh.
  await ref
      .watch(syncServiceProvider)
      .sync()
      .timeout(const Duration(seconds: 6), onTimeout: () => 0);

  final muted = ref.watch(settingsProvider.select((s) => s.mutedCategories));
  final now = DateTime.now();
  final states = await repo.allStates();
  return buildFeed(
    cards: [
      for (final c in await repo.allCards())
        if (!muted.contains(c.category)) c,
    ],
    progress: {
      for (final s in states.values)
        s.cardId: CardProgress(
          seen: s.seenAt != null,
          reviewDue: isReviewDue(
            reviewFrom: s.reviewFrom,
            stage: s.reviewStage,
            now: now,
          ),
        ),
    },
    now: now,
  );
});

final cardStateProvider = StreamProvider.family<CardStateRow?, String>(
  (ref, cardId) => ref.watch(repoProvider).watchState(cardId),
);

final savedCardsProvider = StreamProvider<List<LearnCard>>(
  (ref) => ref.watch(repoProvider).watchSaved(),
);

final cardByIdProvider = FutureProvider.family<LearnCard?, String>(
  (ref, id) => ref.watch(repoProvider).cardById(id),
);

// ---------------------------------------------------------------- progress

final dayLogsProvider = StreamProvider<List<DayLogRow>>(
  (ref) => ref.watch(repoProvider).watchDayLogs(),
);

/// Today's count and goal, for the feed's progress bar and the recap trigger.
final todayProvider = Provider<({int seen, int goal})>((ref) {
  final goal = ref.watch(settingsProvider.select((s) => s.dailyGoal));
  final today = dayKey(DateTime.now());
  final logs = ref.watch(dayLogsProvider).value ?? const [];
  final row = logs.where((d) => d.day == today).firstOrNull;
  return (seen: row?.seen ?? 0, goal: goal);
});

final streakProvider = Provider<Streak>((ref) {
  final logs = ref.watch(dayLogsProvider).value ?? const [];
  return computeStreak({
    for (final d in logs)
      if (d.seen >= d.goal) d.day,
  }, DateTime.now());
});

typedef ProgressStats = ({
  List<CategoryAccuracy> categories,
  ({int read, int saved, int learning, int mastered}) totals,
});

/// Recomputed whenever the day log changes (i.e. after any activity).
final progressStatsProvider = FutureProvider<ProgressStats>((ref) async {
  ref.watch(dayLogsProvider);
  final repo = ref.watch(repoProvider);
  return (
    categories: await repo.categoryAccuracy(),
    totals: await repo.totals(),
  );
});

/// Questions for today's recap; fetched once when the recap is first shown.
final recapCardsProvider = FutureProvider.autoDispose<List<LearnCard>>(
  (ref) => ref.watch(repoProvider).todaysQuizCards(),
);
