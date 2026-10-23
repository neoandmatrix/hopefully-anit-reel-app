import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../db/app_db.dart';
import '../models/learn_card.dart';
import '../stats.dart';

/// Single entry point for reading/writing cards and the user's progress.
class ContentRepo {
  ContentRepo(this.db, {int Function()? dailyGoal, DateTime Function()? clock})
    : _dailyGoal = dailyGoal ?? (() => 20),
      _clock = clock ?? DateTime.now;

  final AppDb db;
  final int Function() _dailyGoal;
  final DateTime Function() _clock;

  // ---------------------------------------------------------------- content

  /// Loads the content bundled in `assets/content/` (evergreen packs and a
  /// sample day) into the DB. Safe to call on every launch.
  Future<void> seedFromAssets() async {
    final index = decodeJson(
      await rootBundle.loadString('assets/content/index.json'),
    );
    for (final file in (index['files'] as List).cast<String>()) {
      final raw = await rootBundle.loadString('assets/content/$file');
      await upsertCards(parseCardFile(raw));
    }
  }

  static Map<String, dynamic> decodeJson(String raw) =>
      jsonDecode(raw) as Map<String, dynamic>;

  /// A content file is `{"cards": [...]}` (daily files and packs alike).
  static List<LearnCard> parseCardFile(String raw) {
    final json = decodeJson(raw);
    return (json['cards'] as List)
        .cast<Map<String, dynamic>>()
        .map(LearnCard.fromJson)
        .toList();
  }

  Future<void> upsertCards(List<LearnCard> list) async {
    await db.batch((b) {
      b.insertAllOnConflictUpdate(db.cards, [
        for (final c in list)
          CardsCompanion.insert(
            id: c.id,
            type: c.type.name,
            category: c.category,
            date: Value(c.date),
            payload: c.encode(),
          ),
      ]);
    });
  }

  Future<List<LearnCard>> allCards() async {
    final rows = await db.select(db.cards).get();
    return rows.map((r) => LearnCard.decode(r.payload)).toList();
  }

  Future<LearnCard?> cardById(String id) async {
    final row = await (db.select(
      db.cards,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    return row == null ? null : LearnCard.decode(row.payload);
  }

  Future<String?> syncedVersion(String file) async {
    final row = await (db.select(
      db.syncedFiles,
    )..where((f) => f.file.equals(file))).getSingleOrNull();
    return row?.version;
  }

  Future<void> markSynced(String file, String version) => db
      .into(db.syncedFiles)
      .insertOnConflictUpdate(
        SyncedFilesCompanion.insert(file: file, version: version),
      );

  // ------------------------------------------------------------ user state

  Future<Map<String, CardStateRow>> allStates() async {
    final rows = await db.select(db.cardStates).get();
    return {for (final r in rows) r.cardId: r};
  }

  Stream<CardStateRow?> watchState(String cardId) => (db.select(
    db.cardStates,
  )..where((s) => s.cardId.equals(cardId))).watchSingleOrNull();

  Stream<List<LearnCard>> watchSaved() {
    final query =
        db.select(db.cards).join([
            innerJoin(
              db.cardStates,
              db.cardStates.cardId.equalsExp(db.cards.id),
            ),
          ])
          ..where(db.cardStates.saved.equals(true))
          ..orderBy([OrderingTerm.desc(db.cards.date)]);
    return query.watch().map(
      (rows) => rows
          .map((r) => LearnCard.decode(r.readTable(db.cards).payload))
          .toList(),
    );
  }

  Future<CardStateRow> _state(String cardId) async {
    await db
        .into(db.cardStates)
        .insert(
          CardStatesCompanion.insert(cardId: cardId),
          mode: InsertMode.insertOrIgnore,
        );
    return (db.select(
      db.cardStates,
    )..where((s) => s.cardId.equals(cardId))).getSingle();
  }

  Future<void> _update(String cardId, CardStatesCompanion changes) async {
    await _state(cardId);
    await (db.update(
      db.cardStates,
    )..where((s) => s.cardId.equals(cardId))).write(changes);
  }

  /// Marks a card read. Only the first time counts towards today's goal.
  Future<void> markSeen(String cardId) async {
    final s = await _state(cardId);
    if (s.seenAt != null) return;
    await _update(cardId, CardStatesCompanion(seenAt: Value(_clock())));
    await _logDay(seen: 1);
  }

  Future<void> toggleSaved(String cardId) async {
    final s = await _state(cardId);
    await _update(cardId, CardStatesCompanion(saved: Value(!s.saved)));
  }

  /// [knowledge]: 1 = knew it, 2 = new to me. Tapping the active one again
  /// clears it. Marking "new" schedules the card for quiz reviews.
  Future<void> setKnowledge(String cardId, int knowledge) async {
    final s = await _state(cardId);
    final next = s.knowledge == knowledge ? 0 : knowledge;
    await _update(
      cardId,
      CardStatesCompanion(
        knowledge: Value(next),
        reviewFrom: Value(next == 2 ? _clock() : null),
        reviewStage: const Value(0),
      ),
    );
  }

  /// Records a quiz answer. Correct answers move the card to the next review
  /// interval; wrong answers restart the schedule from today.
  Future<void> recordQuiz(String cardId, {required bool correct}) async {
    final s = await _state(cardId);
    final card = await cardById(cardId);
    await db
        .into(db.quizLogs)
        .insert(
          QuizLogsCompanion.insert(
            cardId: cardId,
            category: card?.category ?? 'general',
            correct: correct,
            answeredAt: _clock(),
          ),
        );
    await _logDay(seen: 1, attempts: 1, correct: correct ? 1 : 0);
    await _update(
      cardId,
      CardStatesCompanion(
        quizAttempts: Value(s.quizAttempts + 1),
        quizCorrect: Value(s.quizCorrect + (correct ? 1 : 0)),
        reviewStage: Value(
          s.reviewFrom == null
              ? s.reviewStage
              : (correct ? s.reviewStage + 1 : 0),
        ),
        reviewFrom: Value(
          s.reviewFrom == null || correct ? s.reviewFrom : _clock(),
        ),
      ),
    );
  }

  // -------------------------------------------------------------- activity

  Future<void> _logDay({
    int seen = 0,
    int attempts = 0,
    int correct = 0,
  }) async {
    final day = dayKey(_clock());
    await db
        .into(db.dayLogs)
        .insert(
          DayLogsCompanion.insert(day: day, goal: _dailyGoal()),
          mode: InsertMode.insertOrIgnore,
        );
    await db.customUpdate(
      'UPDATE day_logs SET seen = seen + ?, quiz_attempts = quiz_attempts + ?, '
      'quiz_correct = quiz_correct + ?, goal = ? WHERE day = ?',
      variables: [
        Variable.withInt(seen),
        Variable.withInt(attempts),
        Variable.withInt(correct),
        Variable.withInt(_dailyGoal()),
        Variable.withString(day),
      ],
      updates: {db.dayLogs},
    );
  }

  Stream<List<DayLogRow>> watchDayLogs() => (db.select(
    db.dayLogs,
  )..orderBy([(d) => OrderingTerm.asc(d.day)])).watch();

  Future<List<CategoryAccuracy>> categoryAccuracy() async {
    final correct = db.quizLogs.correct.cast<int>().sum();
    final attempts = db.quizLogs.id.count();
    final rows =
        await (db.selectOnly(db.quizLogs)
              ..addColumns([db.quizLogs.category, correct, attempts])
              ..groupBy([db.quizLogs.category]))
            .get();
    return [
      for (final r in rows)
        CategoryAccuracy(
          r.read(db.quizLogs.category)!,
          r.read(correct) ?? 0,
          r.read(attempts) ?? 0,
        ),
    ];
  }

  Future<({int read, int saved, int learning, int mastered})> totals() async {
    final rows = await db.select(db.cardStates).get();
    return (
      read: rows.where((r) => r.seenAt != null).length,
      saved: rows.where((r) => r.saved).length,
      learning: rows.where((r) => r.knowledge == 2 && r.reviewStage < 3).length,
      mastered: rows
          .where((r) => r.knowledge == 2 && r.reviewStage >= 3)
          .length,
    );
  }

  /// Up to [count] quiz cards read today, for the daily recap.
  Future<List<LearnCard>> todaysQuizCards({int count = 5}) async {
    final now = _clock();
    final start = DateTime(now.year, now.month, now.day);
    final query = db.select(db.cards).join([
      innerJoin(db.cardStates, db.cardStates.cardId.equalsExp(db.cards.id)),
    ])..where(db.cardStates.seenAt.isBiggerOrEqualValue(start));
    final cards =
        (await query.get())
            .map((r) => LearnCard.decode(r.readTable(db.cards).payload))
            .where((c) => c.quiz != null)
            .toList()
          ..shuffle();
    return cards.take(count).toList();
  }
}
