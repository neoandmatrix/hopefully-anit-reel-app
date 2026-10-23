import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../feed/feed_screen.dart';
import '../progress/progress_screen.dart';
import '../saved/card_detail_screen.dart';
import '../saved/saved_screen.dart';
import '../settings/settings_screen.dart';

final router = GoRouter(
  initialLocation: '/feed',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _HomeShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/feed', builder: (_, _) => const FeedScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/saved', builder: (_, _) => const SavedScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              builder: (_, _) => const ProgressScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/card/:id',
      builder: (_, state) =>
          CardDetailScreen(cardId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
  ],
);

class _HomeShell extends ConsumerWidget {
  const _HomeShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider).current;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        height: 64,
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.swipe_vertical_outlined),
            selectedIcon: Icon(Icons.swipe_vertical),
            label: 'Feed',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bookmarks_outlined),
            selectedIcon: Icon(Icons.bookmarks),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: streak > 0 ? '🔥 $streak' : 'Progress',
          ),
        ],
      ),
    );
  }
}
