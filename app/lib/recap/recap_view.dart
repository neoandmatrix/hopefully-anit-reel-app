import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/learn_card.dart';
import '../data/providers.dart';
import '../feed/widgets/quiz_card_view.dart';

/// Shown in the feed once the daily goal is reached: a celebration, the
/// streak, and a 5-question quiz on cards read today.
class RecapView extends ConsumerStatefulWidget {
  const RecapView({super.key});

  @override
  ConsumerState<RecapView> createState() => _RecapViewState();
}

class _RecapViewState extends ConsumerState<RecapView> {
  int _index = 0;
  int? _picked;
  int _score = 0;

  void _pick(LearnCard card, int option) {
    if (_picked != null) return;
    final correct = option == card.quiz!.answer;
    setState(() {
      _picked = option;
      if (correct) _score++;
    });
    ref.read(repoProvider).recordQuiz(card.id, correct: correct);
  }

  void _next() => setState(() {
    _index++;
    _picked = null;
  });

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final streak = ref.watch(streakProvider).current;
    final cards = ref.watch(recapCardsProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB45309), Color(0xFF1C1003)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎯',
                    style: TextStyle(fontSize: 48),
                  ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 8),
                  Text(
                    'You learned ${today.seen} things today',
                    style: const TextStyle(
                      fontSize: 28,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    streak > 0
                        ? '🔥 $streak-day streak. Daily goal of ${today.goal} reached.'
                        : 'Daily goal of ${today.goal} reached.',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: cards.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (list) => list.isEmpty
                          ? const _Done(score: null, total: 0)
                          : _index >= list.length
                          ? _Done(score: _score, total: list.length)
                          : _question(list, list[_index]),
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

  Widget _question(List<LearnCard> list, LearnCard card) {
    final quiz = card.quiz!;
    final answered = _picked != null;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK RECAP · ${_index + 1}/${list.length}',
            style: const TextStyle(
              color: Color(0xFFFFB347),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            quiz.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < quiz.options.length; i++)
            QuizOption(
              text: quiz.options[i],
              state: !answered
                  ? QuizOptionState.idle
                  : i == quiz.answer
                  ? QuizOptionState.correct
                  : i == _picked
                  ? QuizOptionState.wrong
                  : QuizOptionState.dimmed,
              onTap: () => _pick(card, i),
            ),
          if (answered) ...[
            if (quiz.explain != null)
              Text(
                quiz.explain!,
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _next,
                child: Text(_index + 1 < list.length ? 'Next' : 'See score'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.score, required this.total});

  final int? score;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (score != null)
          Text(
            'Recap score: $score/$total',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ).animate().fadeIn(),
        const SizedBox(height: 12),
        const Text(
          "That's a good place to stop. Swipe up if you want more, or come "
          'back tomorrow for fresh news.',
          style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
        ),
      ],
    );
  }
}
