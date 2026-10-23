import 'dart:math';

import '../data/models/learn_card.dart';

/// Days after marking a card "new to me" at which it comes back as a quiz.
const reviewIntervalsDays = [1, 3, 7];

/// Whether a card marked "new to me" is due for a quiz review.
bool isReviewDue({
  required DateTime? reviewFrom,
  required int stage,
  required DateTime now,
}) {
  if (reviewFrom == null || stage >= reviewIntervalsDays.length) return false;
  return !now.isBefore(reviewFrom.add(Duration(days: reviewIntervalsDays[stage])));
}

/// How a card is shown in the feed.
class FeedItem {
  const FeedItem(this.card, {this.asQuiz = false});

  final LearnCard card;
  final bool asQuiz;
}

/// Minimal per-card state the builder needs (decoupled from the DB row).
class CardProgress {
  const CardProgress({this.seen = false, this.reviewDue = false});

  final bool seen;
  final bool reviewDue;
}

/// 20-slot pattern: 10 news, 6 GK, 3 quiz, 1 trivia ≈ 50/30/15/5.
const _pattern = 'NGNQNGNTNGQNGNQNGNGN';

/// Builds the swipe feed. Unseen cards come first, newest news first; GK order
/// is shuffled with a per-day seed so the feed is stable within a day. Empty
/// buckets are backfilled from the others so the feed never stalls.
List<FeedItem> buildFeed({
  required List<LearnCard> cards,
  required Map<String, CardProgress> progress,
  required DateTime now,
  int limit = 100,
}) {
  bool seen(LearnCard c) => progress[c.id]?.seen ?? false;
  int unseenFirst(LearnCard a, LearnCard b) =>
      (seen(a) ? 1 : 0) - (seen(b) ? 1 : 0);

  final news = cards.where((c) => c.type == CardType.news).toList()
    ..sort((a, b) {
      final s = unseenFirst(a, b);
      return s != 0 ? s : (b.date ?? '').compareTo(a.date ?? '');
    });

  final seed = now.year * 10000 + now.month * 100 + now.day;
  List<LearnCard> shuffled(CardType t) =>
      (cards.where((c) => c.type == t).toList()..shuffle(Random(seed)))
        ..sort(unseenFirst); // List.sort is stable in Dart.

  final gk = shuffled(CardType.gk);
  final trivia = shuffled(CardType.trivia);

  // Quiz bucket: cards due for spaced-repetition review, then unseen
  // quiz-only content cards.
  final quiz = <FeedItem>[
    for (final c in cards)
      if (c.quiz != null && (progress[c.id]?.reviewDue ?? false))
        FeedItem(c, asQuiz: true),
    for (final c in shuffled(CardType.quiz))
      if (c.quiz != null && !seen(c)) FeedItem(c, asQuiz: true),
  ];

  final buckets = <String, List<FeedItem>>{
    'N': news.map(FeedItem.new).toList(),
    'G': gk.map(FeedItem.new).toList(),
    'T': trivia.map(FeedItem.new).toList(),
    'Q': quiz,
  };
  const fallback = ['N', 'G', 'T'];

  final out = <FeedItem>[];
  final used = <String>{};
  var i = 0;
  while (out.length < limit && buckets.values.any((b) => b.isNotEmpty)) {
    final slot = _pattern[i++ % _pattern.length];
    final order = slot == 'Q' ? ['Q'] : [slot, ...fallback.where((f) => f != slot)];
    for (final key in order) {
      final bucket = buckets[key]!;
      // A card can appear once as a read card and once as a quiz.
      final idx = bucket.indexWhere(
        (item) => !used.contains('${item.card.id}:${item.asQuiz}'),
      );
      if (idx == -1) {
        bucket.clear();
        continue;
      }
      final item = bucket.removeAt(idx);
      used.add('${item.card.id}:${item.asQuiz}');
      out.add(item);
      break;
    }
  }
  return out;
}
