import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_smart/data/db/app_db.dart';
import 'package:scroll_smart/data/models/learn_card.dart';
import 'package:scroll_smart/data/repo/content_repo.dart';

void main() {
  late AppDb db;
  late ContentRepo repo;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDb(NativeDatabase.memory());
    repo = ContentRepo(db);
  });
  tearDown(() => db.close());

  const a = LearnCard(id: 'a', type: CardType.gk, category: 'polity', headline: 'A', body: 'x');

  test('upsert replaces existing cards instead of duplicating', () async {
    await repo.upsertCards([a]);
    await repo.upsertCards([
      const LearnCard(id: 'a', type: CardType.gk, category: 'polity', headline: 'A2', body: 'x'),
    ]);
    final all = await repo.allCards();
    expect(all.single.headline, 'A2');
  });

  test('save toggles and shows up in the saved list', () async {
    await repo.upsertCards([a]);
    await repo.toggleSaved('a');
    expect((await repo.watchSaved().first).single.id, 'a');
    await repo.toggleSaved('a');
    expect(await repo.watchSaved().first, isEmpty);
  });

  test('"new to me" schedules reviews; quiz answers move the schedule', () async {
    await repo.upsertCards([a]);
    await repo.setKnowledge('a', 2);
    var s = (await repo.allStates())['a']!;
    expect(s.knowledge, 2);
    expect(s.reviewFrom, isNotNull);
    expect(s.reviewStage, 0);

    await repo.recordQuiz('a', correct: true);
    s = (await repo.allStates())['a']!;
    expect(s.reviewStage, 1);
    expect(s.quizCorrect, 1);

    await repo.recordQuiz('a', correct: false);
    s = (await repo.allStates())['a']!;
    expect(s.reviewStage, 0);
    expect(s.quizAttempts, 2);
  });

  test('tapping the same knowledge button again clears it', () async {
    await repo.setKnowledge('a', 1);
    await repo.setKnowledge('a', 1);
    expect((await repo.allStates())['a']!.knowledge, 0);
  });

  test('markSeen keeps the first seen time', () async {
    await repo.markSeen('a');
    final first = (await repo.allStates())['a']!.seenAt;
    await repo.markSeen('a');
    expect((await repo.allStates())['a']!.seenAt, first);
  });
}
