import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scroll_smart/data/db/app_db.dart';
import 'package:scroll_smart/data/repo/content_repo.dart';
import 'package:scroll_smart/data/sync_service.dart';

/// Serves canned files and records which paths were requested.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.files);

  final Map<String, Object> files;
  final requested = <String>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? _, Future<void>? _) async {
    final path = options.uri.path.split('/content/').last;
    requested.add(path);
    final body = files[path];
    if (body == null) return ResponseBody.fromString('not found', 404);
    return ResponseBody.fromString(jsonEncode(body), 200);
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object> cardFile(String id) => {
      'cards': [
        {'id': id, 'type': 'news', 'category': 'economy', 'headline': id, 'body': 'b'},
      ],
    };

void main() {
  late AppDb db;
  late ContentRepo repo;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDb(NativeDatabase.memory());
    repo = ContentRepo(db);
  });
  tearDown(() => db.close());

  SyncService service(FakeAdapter adapter) => SyncService(
        repo,
        baseUrl: 'https://example.com/content/',
        dio: Dio(BaseOptions(
          baseUrl: 'https://example.com/content/',
          responseType: ResponseType.plain,
        ))
          ..httpClientAdapter = adapter,
      );

  test('fetches recent days and only changed packs', () async {
    final adapter = FakeAdapter({
      'manifest.json': {
        'days': ['2026-10-20', '2026-10-21', '2026-10-22', '2026-10-23'],
        'packs': [
          {'file': 'packs/polity.json', 'version': 'v1'},
        ],
      },
      'daily/2026-10-21.json': cardFile('d21'),
      'daily/2026-10-22.json': cardFile('d22'),
      'daily/2026-10-23.json': cardFile('d23'),
      'packs/polity.json': cardFile('p1'),
    });

    expect(await service(adapter).sync(), 4);
    expect(adapter.requested, isNot(contains('daily/2026-10-20.json')));
    expect((await repo.allCards()).map((c) => c.id).toSet(), {'d21', 'd22', 'd23', 'p1'});

    adapter.requested.clear();
    await service(adapter).sync();
    expect(adapter.requested, isNot(contains('packs/polity.json')));
  });

  test('network failure keeps going without throwing', () async {
    final adapter = FakeAdapter({});
    expect(await service(adapter).sync(), 0);
  });

  test('a failed pack is retried next time', () async {
    final files = <String, Object>{
      'manifest.json': {
        'days': <String>[],
        'packs': [
          {'file': 'packs/x.json', 'version': 'v1'},
        ],
      },
    };
    final adapter = FakeAdapter(files);
    await service(adapter).sync();
    files['packs/x.json'] = cardFile('x1');
    adapter.requested.clear();
    expect(await service(adapter).sync(), 1);
  });
}
