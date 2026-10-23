import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/learn_card.dart';
import '../../data/providers.dart';
import 'card_shell.dart';

/// Shows a card's MCQ. The answer is recorded once, on the first tap.
class QuizCardView extends ConsumerStatefulWidget {
  const QuizCardView({super.key, required this.card});

  final LearnCard card;

  @override
  ConsumerState<QuizCardView> createState() => _QuizCardViewState();
}

class _QuizCardViewState extends ConsumerState<QuizCardView> {
  int? _picked;

  Quiz get _quiz => widget.card.quiz!;

  void _pick(int index) {
    if (_picked != null) return;
    setState(() => _picked = index);
    ref
        .read(repoProvider)
        .recordQuiz(widget.card.id, correct: index == _quiz.answer);
  }

  @override
  Widget build(BuildContext context) {
    final answered = _picked != null;
    return CardShell(
      card: widget.card,
      label: 'QUICK RECALL',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            _quiz.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < _quiz.options.length; i++)
            QuizOption(
              text: _quiz.options[i],
              state: !answered
                  ? QuizOptionState.idle
                  : i == _quiz.answer
                  ? QuizOptionState.correct
                  : i == _picked
                  ? QuizOptionState.wrong
                  : QuizOptionState.dimmed,
              onTap: () => _pick(i),
            ),
          if (answered)
            ...[
              const SizedBox(height: 12),
              Text(
                _picked == _quiz.answer ? 'Correct! 🎯' : 'Not quite.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_quiz.explain != null) ...[
                const SizedBox(height: 6),
                Text(
                  _quiz.explain!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ].animate(interval: 60.ms).fadeIn(),
        ],
      ),
    );
  }
}

enum QuizOptionState { idle, correct, wrong, dimmed }

class QuizOption extends StatelessWidget {
  const QuizOption({
    super.key,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final QuizOptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, border, icon) = switch (state) {
      QuizOptionState.idle => (
        Colors.white.withValues(alpha: 0.10),
        Colors.white24,
        null,
      ),
      QuizOptionState.correct => (
        const Color(0xFF16A34A).withValues(alpha: 0.35),
        const Color(0xFF22C55E),
        Icons.check_circle,
      ),
      QuizOptionState.wrong => (
        const Color(0xFFDC2626).withValues(alpha: 0.35),
        const Color(0xFFEF4444),
        Icons.cancel,
      ),
      QuizOptionState.dimmed => (
        Colors.white.withValues(alpha: 0.04),
        Colors.white10,
        null,
      ),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: state == QuizOptionState.idle ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: state == QuizOptionState.dimmed
                          ? Colors.white38
                          : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (icon != null) Icon(icon, color: border),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
