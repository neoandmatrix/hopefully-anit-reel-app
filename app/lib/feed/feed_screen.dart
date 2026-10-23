import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onPage(List<FeedItem> items, int index) {
    if (index < items.length && !items[index].asQuiz) {
      ref.read(repoProvider).markSeen(items[index].card.id);
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
    return Scaffold(
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load cards:\n$e', textAlign: TextAlign.center),
          ),
        ),
        data: (items) {
          if (items.isNotEmpty) {
            // The first card counts as seen as soon as it's shown.
            WidgetsBinding.instance.addPostFrameCallback((_) => _onPage(items, 0));
          }
          return Focus(
            focusNode: _focus,
            autofocus: true,
            onKeyEvent: _onKey,
            child: PageView.builder(
              controller: _controller,
              scrollDirection: Axis.vertical,
              itemCount: items.length + 1,
              onPageChanged: (i) => _onPage(items, i),
              itemBuilder: (context, i) {
                if (i == items.length) return const _CaughtUp();
                final item = items[i];
                return item.asQuiz
                    ? QuizCardView(key: ValueKey('q-${item.card.id}'), card: item.card)
                    : LearnCardView(key: ValueKey(item.card.id), card: item.card);
              },
            ),
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
