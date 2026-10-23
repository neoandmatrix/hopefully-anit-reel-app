import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../feed/widgets/learn_card_view.dart';

/// Opens one card full-screen (from Saved).
class CardDetailScreen extends ConsumerWidget {
  const CardDetailScreen({super.key, required this.cardId});

  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(cardByIdProvider(cardId));
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: card.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (c) => c == null
            ? const Center(child: Text('Card not found'))
            : Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight),
                child: LearnCardView(card: c),
              ),
      ),
    );
  }
}
