import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../feed/feed_screen.dart';
import '../saved/card_detail_screen.dart';
import '../saved/saved_screen.dart';

final router = GoRouter(
  initialLocation: '/feed',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _HomeShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/feed', builder: (_, _) => const FeedScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/saved', builder: (_, _) => const SavedScreen())],
        ),
      ],
    ),
    GoRoute(
      path: '/card/:id',
      builder: (_, state) => CardDetailScreen(cardId: state.pathParameters['id']!),
    ),
  ],
);

class _HomeShell extends StatelessWidget {
  const _HomeShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        height: 64,
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.swipe_vertical_outlined),
            selectedIcon: Icon(Icons.swipe_vertical),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmarks_outlined),
            selectedIcon: Icon(Icons.bookmarks),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}
