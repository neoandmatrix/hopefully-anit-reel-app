import 'package:dio/dio.dart';

import 'repo/content_repo.dart';

/// Where the content pipeline publishes JSON (GitHub Pages). Override with
/// `--dart-define=CONTENT_BASE_URL=...`; pass an empty value to stay offline.
const contentBaseUrl = String.fromEnvironment(
  'CONTENT_BASE_URL',
  defaultValue: 'https://neoandmatrix.github.io/hopefully-anit-reel-app/',
);

/// Downloads what `manifest.json` lists:
/// `{"days": ["2026-10-23", ...], "packs": [{"file": "packs/polity.json", "version": "ab12"}]}`.
/// Recent days are always re-fetched (cheap); packs only when their version changes.
class SyncService {
  SyncService(this.repo, {Dio? dio, String baseUrl = contentBaseUrl})
      : _baseUrl = baseUrl,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 30),
              responseType: ResponseType.plain,
            ));

  final ContentRepo repo;
  final Dio _dio;
  final String _baseUrl;

  bool get isConfigured => _baseUrl.isNotEmpty;

  /// Returns the number of cards fetched. Never throws: the app works offline
  /// with whatever is already stored.
  Future<int> sync({int recentDays = 3}) async {
    if (!isConfigured) return 0;
    var count = 0;
    try {
      final manifest = ContentRepo.decodeJson(await _get('manifest.json'));
      final days = (manifest['days'] as List? ?? const []).cast<String>()..sort();
      for (final day in days.reversed.take(recentDays)) {
        count += await _fetchCards('daily/$day.json');
      }
      for (final pack in manifest['packs'] as List? ?? const []) {
        final file = pack['file'] as String;
        final version = pack['version'] as String;
        if (await repo.syncedVersion(file) == version) continue;
        count += await _fetchCards(file);
        await repo.markSynced(file, version);
      }
    } on Exception {
      // Network errors and malformed files alike: keep the offline content.
    }
    return count;
  }

  Future<String> _get(String path) async =>
      (await _dio.get<String>(path)).data!;

  Future<int> _fetchCards(String path) async {
    final cards = ContentRepo.parseCardFile(await _get(path));
    await repo.upsertCards(cards);
    return cards.length;
  }
}
