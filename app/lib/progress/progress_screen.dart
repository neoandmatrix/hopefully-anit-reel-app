import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../data/db/app_db.dart';
import '../data/providers.dart';
import '../data/stats.dart';

const _saffron = Color(0xFFFF9933);

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final today = ref.watch(todayProvider);
    final logs = ref.watch(dayLogsProvider).value ?? const <DayLogRow>[];
    final stats = ref.watch(progressStatsProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      value: '🔥 ${streak.current}',
                      label: 'day streak',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      value: '${streak.best}',
                      label: 'best streak',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      value: '${today.seen}/${today.goal}',
                      label: 'today',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Last 14 days'),
              const SizedBox(height: 12),
              _DaysChart(logs: logs, goal: today.goal),
              const SizedBox(height: 28),
              if (stats != null) ...[
                const _SectionTitle('Totals'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SmallStat('${stats.totals.read}', 'cards read'),
                    _SmallStat(_accuracy(stats.categories), 'quiz accuracy'),
                    _SmallStat('${stats.totals.saved}', 'saved'),
                    _SmallStat('${stats.totals.learning}', 'learning'),
                    _SmallStat('${stats.totals.mastered}', 'mastered'),
                  ],
                ),
                const SizedBox(height: 28),
                const _SectionTitle('Quiz accuracy by category'),
                const SizedBox(height: 4),
                _CategoryList(stats.categories),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _accuracy(List<CategoryAccuracy> categories) {
    final attempts = categories.fold(0, (sum, c) => sum + c.attempts);
    if (attempts == 0) return '–';
    final correct = categories.fold(0, (sum, c) => sum + c.correct);
    return '${(100 * correct / attempts).round()}%';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  const _SmallStat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Bars for cards per day; days that met their goal are saffron.
class _DaysChart extends StatelessWidget {
  const _DaysChart({required this.logs, required this.goal});

  final List<DayLogRow> logs;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final byDay = {for (final l in logs) l.day: l};
    final now = DateTime.now();
    final days = [
      for (var i = 13; i >= 0; i--) DateTime(now.year, now.month, now.day - i),
    ];
    final maxSeen = [
      goal,
      ...days.map((d) => byDay[dayKey(d)]?.seen ?? 0),
    ].reduce((a, b) => a > b ? a : b);
    const height = 120.0;

    return SizedBox(
      height: height + 36,
      child: Stack(
        children: [
          // Goal line.
          Positioned(
            left: 0,
            right: 0,
            bottom: 36 + height * goal / maxSeen,
            child: Container(height: 1, color: Colors.white24),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final d in days)
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final log = byDay[dayKey(d)];
                      final seen = log?.seen ?? 0;
                      final met = log != null && seen >= log.goal;
                      return Tooltip(
                        message: '${dayKey(d)}: $seen cards',
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: seen == 0 ? 2 : height * seen / maxSeen,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: met ? _saffron : Colors.white30,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'MTWTFSS'[d.weekday - 1],
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '${d.day}',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList(this.categories);

  final List<CategoryAccuracy> categories;

  @override
  Widget build(BuildContext context) {
    // Need a few answers before a category's accuracy means anything.
    final ranked = categories.where((c) => c.attempts >= 3).toList()
      ..sort((a, b) => b.accuracy.compareTo(a.accuracy));
    if (ranked.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Answer a few quizzes in each category to see your strengths.',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }
    return Column(
      children: [
        for (final c in ranked)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  categoryStyle(c.category).icon,
                  size: 18,
                  color: Colors.white70,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 110,
                  child: Text(categoryStyle(c.category).label),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: c.accuracy,
                      minHeight: 8,
                      backgroundColor: Colors.white10,
                      color: categoryStyle(c.category).colors.first,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  child: Text(
                    '${(c.accuracy * 100).round()}% · ${c.attempts}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                if (c == ranked.first && ranked.length > 1)
                  const Text(' 💪')
                else if (c == ranked.last && ranked.length > 1)
                  const Text(' 📚')
                else
                  const SizedBox(width: 22),
              ],
            ),
          ),
      ],
    );
  }
}
