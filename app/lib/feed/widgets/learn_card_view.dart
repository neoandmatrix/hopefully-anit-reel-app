import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/learn_card.dart';
import 'card_actions.dart';
import 'card_shell.dart';

const _typeLabels = {
  CardType.news: 'TODAY',
  CardType.gk: 'KNOW INDIA',
  CardType.trivia: 'DID YOU KNOW?',
  CardType.quiz: 'QUIZ',
};

/// A read card: headline, explainer, why it matters, key fact.
class LearnCardView extends StatelessWidget {
  const LearnCardView({super.key, required this.card});

  final LearnCard card;

  @override
  Widget build(BuildContext context) {
    return CardShell(
      card: card,
      label: _typeLabels[card.type]!,
      actions: CardActions(cardId: card.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            card.headline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            card.body,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.45,
            ),
          ),
          if (card.whyItMatters != null) ...[
            const SizedBox(height: 18),
            _Panel(
              title: 'Why it matters',
              icon: Icons.bolt,
              text: card.whyItMatters!,
            ),
          ],
          if (card.keyFact != null) ...[
            const SizedBox(height: 12),
            _KeyFact(text: card.keyFact!),
          ],
          if (card.sourceUrl != null) ...[
            const SizedBox(height: 14),
            _SourceLink(url: card.sourceUrl!),
          ],
        ],
      ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.04, end: 0),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.icon, required this.text});

  final String title;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFFFFB347)),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFFFB347),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyFact extends StatelessWidget {
  const _KeyFact({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB347).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.push_pin, size: 16, color: Color(0xFFFFB347)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceLink extends StatelessWidget {
  const _SourceLink({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final host = Uri.tryParse(url)?.host.replaceFirst('www.', '') ?? url;
    return InkWell(
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.open_in_new, size: 14, color: Colors.white60),
            const SizedBox(width: 6),
            Text(
              'Source: $host',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
