import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../recap/recap_view.dart';
import 'feed_builder.dart';
import 'widgets/learn_card_view.dart';
import 'widgets/quiz_card_view.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _controller = PageController();
  final _focus = FocusNode();
  int _page = 0;

  /// Today's count when the feed opened; the recap only appears if the goal is
  /// crossed during this session (not when reopening after already meeting it).
  int? _baseline;

  /// Page index where the recap was inserted, once the goal is reached.
  int? _recapAt;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Maps a page index to a feed item, accounting for the inserted recap.
  FeedItem? _itemAt(List<FeedItem> items, int page) {
    final recap = _recapAt;
    if (recap != null && page == recap) return null;
    final i = recap != null && page > recap ? page - 1 : page;
    return i < items.length ? items[i] : null;
  }

  void _onPage(List<FeedItem> items, int page) {
    _page = page;
    final item = _itemAt(items, page);
    if (item != null && !item.asQuiz) {
      ref.read(repoProvider).markSeen(item.card.id);
    }
  }

  /// Arrow keys / j-k / space flip cards when using a keyboard on the web.
  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent || !_controller.hasClients) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    const duration = Duration(milliseconds: 280);
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.keyJ ||
        key == LogicalKeyboardKey.space) {
      _controller.nextPage(duration: duration, curve: Curves.easeOut);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyK) {
      _controller.previousPage(duration: duration, curve: Curves.easeOut);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    final today = ref.watch(todayProvider);
    if (_baseline == null && ref.watch(dayLogsProvider).hasValue) {
      _baseline = today.seen;
    }
    ref.listen(todayProvider, (_, next) {
      final baseline = _baseline;
      if (baseline == null) return;
      if (_recapAt == null && baseline < next.goal && next.seen >= next.goal) {
        setState(() => _recapAt = _page + 1);
      }
    });
    return Scaffold(
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load cards:\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (items) {
          if (items.isNotEmpty) {
            // The first card counts as seen as soon as it's shown.
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _onPage(items, 0),
            );
          }
          final pages = items.length + 1 + (_recapAt == null ? 0 : 1);
          return Stack(
            children: [
              Focus(
                focusNode: _focus,
                autofocus: true,
                onKeyEvent: _onKey,
                child: PageView.builder(
                  controller: _controller,
                  scrollDirection: Axis.vertical,
                  itemCount: pages,
                  onPageChanged: (i) => _onPage(items, i),
                  itemBuilder: (context, i) {
                    if (i == _recapAt) return const RecapView();
                    final item = _itemAt(items, i);
                    if (item == null) return const _CaughtUp();
                    return item.asQuiz
                        ? QuizCardView(
                            key: ValueKey('q-${item.card.id}'),
                            card: item.card,
                          )
                        : LearnCardView(
                            key: ValueKey(item.card.id),
                            card: item.card,
                          );
                  },
                ),
              ),
              // Thin daily-goal bar along the top, like story progress.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: LinearProgressIndicator(
                    value: (today.seen / today.goal).clamp(0, 1).toDouble(),
                    minHeight: 3,
                    backgroundColor: Colors.white10,
                    color: const Color(0xFFFF9933),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CaughtUp extends ConsumerWidget {
  const _CaughtUp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            const Text(
              "You're all caught up",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'New cards arrive every morning. Go do something offline!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(feedProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh feed'),
            ),
          ],
        ),
      ),
    );
  }
}
