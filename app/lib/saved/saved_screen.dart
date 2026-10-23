import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../data/providers.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  String? _category;

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(savedCardsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: saved.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(
              child: Text(
                'Tap the bookmark on any card to keep it here.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          final categories = {for (final c in cards) c.category}.toList()
            ..sort();
          final visible = _category == null
              ? cards
              : cards.where((c) => c.category == _category).toList();
          return Column(
            children: [
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: [
                    _filterChip('All', null),
                    for (final c in categories)
                      _filterChip(categoryStyle(c).label, c),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final card = visible[i];
                    final style = categoryStyle(card.category);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: style.colors.first,
                        child: Icon(style.icon, color: Colors.white, size: 20),
                      ),
                      title: Text(card.headline),
                      subtitle: Text(
                        card.keyFact ?? style.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => context.push('/card/${card.id}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, String? category) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _category == category,
      onSelected: (_) => setState(() => _category = category),
    ),
  );
}
