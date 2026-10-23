import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_db.g.dart';

/// Every card we know about. The full card is stored as JSON in [payload] so
/// schema changes in the content pipeline don't need DB migrations.
@DataClassName('CardRow')
class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get date => text().nullable()();
  TextColumn get payload => text()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// What the user did with a card.
@DataClassName('CardStateRow')
class CardStates extends Table {
  TextColumn get cardId => text()();
  DateTimeColumn get seenAt => dateTime().nullable()();
  BoolColumn get saved => boolean().withDefault(const Constant(false))();

  /// 0 = not marked, 1 = "I knew this", 2 = "New to me".
  IntColumn get knowledge => integer().withDefault(const Constant(0))();

  /// Spaced repetition: when the card was marked new (or last failed) and how
  /// many reviews have been passed since.
  DateTimeColumn get reviewFrom => dateTime().nullable()();
  IntColumn get reviewStage => integer().withDefault(const Constant(0))();

  IntColumn get quizAttempts => integer().withDefault(const Constant(0))();
  IntColumn get quizCorrect => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {cardId};
}

/// Content files already downloaded, so unchanged packs aren't re-fetched.
@DataClassName('SyncedFileRow')
class SyncedFiles extends Table {
  TextColumn get file => text()();
  TextColumn get version => text()();

  @override
  Set<Column> get primaryKey => {file};
}

@DriftDatabase(tables: [Cards, CardStates, SyncedFiles])
class AppDb extends _$AppDb {
  AppDb([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(syncedFiles);
        },
      );

  static QueryExecutor _open() => driftDatabase(
        name: 'scroll_smart',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );
}
