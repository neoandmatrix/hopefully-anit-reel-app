import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/learn_card.dart';

/// Full-screen gradient background plus the top label row shared by all cards.
class CardShell extends StatelessWidget {
  const CardShell({
    super.key,
    required this.card,
    required this.label,
    required this.child,
    this.actions,
  });

  final LearnCard card;
  final String label;
  final Widget child;

  /// Vertical action column on the right edge, like Reels.
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyle(card.category);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: style.colors,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Keeps it phone-shaped on a wide browser window.
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Chip(icon: style.icon, text: style.label),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      if (card.date != null)
                        Text(
                          card.date!,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: child),
                        if (actions != null) ...[
                          const SizedBox(width: 8),
                          actions!,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
