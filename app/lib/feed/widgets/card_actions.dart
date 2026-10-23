import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';

/// Reels-style action column: save, "I knew this", "New to me".
class CardActions extends ConsumerWidget {
  const CardActions({super.key, required this.cardId});

  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cardStateProvider(cardId)).value;
    final repo = ref.read(repoProvider);
    final saved = state?.saved ?? false;
    final knowledge = state?.knowledge ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: saved ? Icons.bookmark : Icons.bookmark_border,
          label: saved ? 'Saved' : 'Save',
          active: saved,
          onTap: () => repo.toggleSaved(cardId),
        ),
        _ActionButton(
          icon: Icons.check_circle_outline,
          label: 'Knew it',
          active: knowledge == 1,
          onTap: () => repo.setKnowledge(cardId, 1),
        ),
        _ActionButton(
          icon: Icons.lightbulb_outline,
          label: 'New to me',
          active: knowledge == 2,
          onTap: () => repo.setKnowledge(cardId, 2),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFFFB347) : Colors.white;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: InkResponse(
        onTap: onTap,
        radius: 30,
        child: SizedBox(
          width: 64,
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
