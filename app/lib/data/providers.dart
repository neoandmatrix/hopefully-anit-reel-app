import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feed/feed_builder.dart';
import 'db/app_db.dart';
import 'models/learn_card.dart';
import 'repo/content_repo.dart';
import 'sync_service.dart';

final dbProvider = Provider<AppDb>((ref) {
  final db = AppDb();
  ref.onDispose(db.close);
  return db;
});

final repoProvider = Provider<ContentRepo>(
  (ref) => ContentRepo(ref.watch(dbProvider)),
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

  final now = DateTime.now();
  final states = await repo.allStates();
  return buildFeed(
    cards: await repo.allCards(),
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
