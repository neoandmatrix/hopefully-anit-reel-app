import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_smart/data/models/learn_card.dart';
import 'package:scroll_smart/data/repo/content_repo.dart';
import 'package:scroll_smart/feed/feed_builder.dart';

LearnCard card(String id, CardType type, {String? date, bool quiz = true}) => LearnCard(
      id: id,
      type: type,
      category: 'polity',
      headline: id,
      body: '',
      date: date,
      quiz: quiz ? const Quiz(question: 'q', options: ['a', 'b'], answer: 0) : null,
    );

void main() {
  final now = DateTime(2026, 10, 23, 9);

  group('isReviewDue', () {
    test('follows the 1 / 3 / 7 day schedule', () {
      final marked = DateTime(2026, 10, 20, 9);
      expect(isReviewDue(reviewFrom: marked, stage: 0, now: marked), isFalse);
      expect(isReviewDue(reviewFrom: marked, stage: 0, now: marked.add(const Duration(days: 1))), isTrue);
      expect(isReviewDue(reviewFrom: marked, stage: 1, now: marked.add(const Duration(days: 2))), isFalse);
      expect(isReviewDue(reviewFrom: marked, stage: 1, now: marked.add(const Duration(days: 3))), isTrue);
      expect(isReviewDue(reviewFrom: marked, stage: 2, now: marked.add(const Duration(days: 7))), isTrue);
    });

    test('finished or unmarked cards are never due', () {
      expect(isReviewDue(reviewFrom: null, stage: 0, now: now), isFalse);
      expect(isReviewDue(reviewFrom: DateTime(2020), stage: 3, now: now), isFalse);
    });
  });

  group('buildFeed', () {
    final cards = [
      for (var i = 0; i < 30; i++) card('n$i', CardType.news, date: '2026-10-${10 + (i % 14)}'),
      for (var i = 0; i < 30; i++) card('g$i', CardType.gk),
      for (var i = 0; i < 5; i++) card('t$i', CardType.trivia),
      for (var i = 0; i < 5; i++) card('q$i', CardType.quiz),
    ];

    test('mixes roughly 50 / 30 / 15 / 5 in the first 20 cards', () {
      final feed = buildFeed(cards: cards, progress: const {}, now: now).take(20).toList();
      int count(bool Function(FeedItem) f) => feed.where(f).length;
      expect(count((i) => i.card.type == CardType.news && !i.asQuiz), 10);
      expect(count((i) => i.card.type == CardType.gk && !i.asQuiz), 6);
      expect(count((i) => i.asQuiz), 3);
      expect(count((i) => i.card.type == CardType.trivia), 1);
    });

    test('newest unseen news comes first; seen cards go last', () {
      final feed = buildFeed(
        cards: [
          card('old', CardType.news, date: '2026-10-01'),
          card('new', CardType.news, date: '2026-10-23'),
          card('seen', CardType.news, date: '2026-10-23'),
        ],
        progress: const {'seen': CardProgress(seen: true)},
        now: now,
      );
      expect(feed.map((i) => i.card.id), ['new', 'old', 'seen']);
    });

    test('due reviews appear as quizzes alongside their read card', () {
      final feed = buildFeed(
        cards: cards,
        progress: const {'g3': CardProgress(seen: true, reviewDue: true)},
        now: now,
      );
      final firstQuiz = feed.firstWhere((i) => i.asQuiz);
      expect(firstQuiz.card.id, 'g3');
      expect(feed.where((i) => i.card.id == 'g3').length, 2);
    });

    test('never repeats an item and stops when content runs out', () {
      final feed = buildFeed(cards: cards, progress: const {}, now: now);
      final keys = feed.map((i) => '${i.card.id}:${i.asQuiz}').toList();
      expect(keys.toSet().length, keys.length);
      expect(feed.length, 70);
    });

    test('backfills from other buckets when one is empty', () {
      final feed = buildFeed(
        cards: [for (var i = 0; i < 5; i++) card('g$i', CardType.gk)],
        progress: const {},
        now: now,
      );
      expect(feed.length, 5);
    });

    test('order is stable within a day', () {
      List<String> ids() =>
          buildFeed(cards: cards, progress: const {}, now: now).map((i) => i.card.id).toList();
      expect(ids(), ids());
    });
  });

  test('bundled content files parse and have valid quizzes', () {
    for (final path in ['assets/content/packs/starter.json', 'assets/content/sample_daily.json']) {
      final parsed = ContentRepo.parseCardFile(File(path).readAsStringSync());
      expect(parsed, isNotEmpty, reason: path);
      expect(parsed.map((c) => c.id).toSet().length, parsed.length, reason: 'duplicate ids in $path');
      for (final c in parsed) {
        final q = c.quiz;
        if (q != null) {
          expect(q.answer, inInclusiveRange(0, q.options.length - 1), reason: c.id);
        }
        expect(LearnCard.decode(c.encode()).toJson(), c.toJson(), reason: c.id);
      }
    }
  });
}
