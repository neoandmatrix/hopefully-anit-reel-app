import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../db/app_db.dart';
import '../models/learn_card.dart';

/// Single entry point for reading/writing cards and the user's progress.
class ContentRepo {
  ContentRepo(this.db);

  final AppDb db;

  // ---------------------------------------------------------------- content

  /// Loads the content bundled in `assets/content/` (evergreen packs and a
  /// sample day) into the DB. Safe to call on every launch.
  Future<void> seedFromAssets() async {
    final index =
        decodeJson(await rootBundle.loadString('assets/content/index.json'));
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
      b.insertAllOnConflictUpdate(
        db.cards,
        [
          for (final c in list)
            CardsCompanion.insert(
              id: c.id,
              type: c.type.name,
              category: c.category,
              date: Value(c.date),
              payload: c.encode(),
            ),
        ],
      );
    });
  }

  Future<List<LearnCard>> allCards() async {
    final rows = await db.select(db.cards).get();
    return rows.map((r) => LearnCard.decode(r.payload)).toList();
  }

  Future<LearnCard?> cardById(String id) async {
    final row = await (db.select(db.cards)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : LearnCard.decode(row.payload);
  }

  Future<String?> syncedVersion(String file) async {
    final row = await (db.select(db.syncedFiles)..where((f) => f.file.equals(file)))
        .getSingleOrNull();
    return row?.version;
  }

  Future<void> markSynced(String file, String version) => db
      .into(db.syncedFiles)
      .insertOnConflictUpdate(SyncedFilesCompanion.insert(file: file, version: version));

  // ------------------------------------------------------------ user state

  Future<Map<String, CardStateRow>> allStates() async {
    final rows = await db.select(db.cardStates).get();
    return {for (final r in rows) r.cardId: r};
  }

  Stream<CardStateRow?> watchState(String cardId) =>
      (db.select(db.cardStates)..where((s) => s.cardId.equals(cardId)))
          .watchSingleOrNull();

  Stream<List<LearnCard>> watchSaved() {
    final query = db.select(db.cards).join([
      innerJoin(db.cardStates, db.cardStates.cardId.equalsExp(db.cards.id)),
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
    await db.into(db.cardStates).insert(
          CardStatesCompanion.insert(cardId: cardId),
          mode: InsertMode.insertOrIgnore,
        );
    return (db.select(db.cardStates)..where((s) => s.cardId.equals(cardId)))
        .getSingle();
  }

  Future<void> _update(String cardId, CardStatesCompanion changes) async {
    await _state(cardId);
    await (db.update(db.cardStates)..where((s) => s.cardId.equals(cardId)))
        .write(changes);
  }

  Future<void> markSeen(String cardId) async {
    final s = await _state(cardId);
    if (s.seenAt != null) return;
    await _update(cardId, CardStatesCompanion(seenAt: Value(DateTime.now())));
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
        reviewFrom: Value(next == 2 ? DateTime.now() : null),
        reviewStage: const Value(0),
      ),
    );
  }

  /// Records a quiz answer. Correct answers move the card to the next review
  /// interval; wrong answers restart the schedule from today.
  Future<void> recordQuiz(String cardId, {required bool correct}) async {
    final s = await _state(cardId);
    await _update(
      cardId,
      CardStatesCompanion(
        quizAttempts: Value(s.quizAttempts + 1),
        quizCorrect: Value(s.quizCorrect + (correct ? 1 : 0)),
        reviewStage: Value(
          s.reviewFrom == null ? s.reviewStage : (correct ? s.reviewStage + 1 : 0),
        ),
        reviewFrom: Value(
          s.reviewFrom == null || correct ? s.reviewFrom : DateTime.now(),
        ),
      ),
    );
  }
}
