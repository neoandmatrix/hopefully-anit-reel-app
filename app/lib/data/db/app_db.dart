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

/// One row per day with activity: drives streaks and the progress chart.
@DataClassName('DayLogRow')
class DayLogs extends Table {
  /// Local date, `yyyy-MM-dd`.
  TextColumn get day => text()();

  /// Cards read for the first time plus quiz questions answered.
  IntColumn get seen => integer().withDefault(const Constant(0))();

  /// The daily goal in effect that day, so changing it later keeps old streaks.
  IntColumn get goal => integer()();
  IntColumn get quizAttempts => integer().withDefault(const Constant(0))();
  IntColumn get quizCorrect => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {day};
}

/// Every quiz answer, for accuracy per category.
@DataClassName('QuizLogRow')
class QuizLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cardId => text()();
  TextColumn get category => text()();
  BoolColumn get correct => boolean()();
  DateTimeColumn get answeredAt => dateTime()();
}

@DriftDatabase(tables: [Cards, CardStates, SyncedFiles, DayLogs, QuizLogs])
class AppDb extends _$AppDb {
  AppDb([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(syncedFiles);
      if (from < 3) {
        await m.createTable(dayLogs);
        await m.createTable(quizLogs);
        // Backfill days from cards already read, so progress isn't empty.
        await customStatement('''
          INSERT INTO day_logs (day, seen, goal, quiz_attempts, quiz_correct)
          SELECT date(seen_at, 'unixepoch', 'localtime'), COUNT(*), 20, 0, 0
          FROM card_states WHERE seen_at IS NOT NULL GROUP BY 1
        ''');
      }
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
