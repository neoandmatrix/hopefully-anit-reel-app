/// Local calendar day as `yyyy-MM-dd`, the key used in the day log.
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

class Streak {
  const Streak({required this.current, required this.best});

  final int current;
  final int best;
}

/// [goalMetDays] are the `yyyy-MM-dd` days on which the daily goal was met.
/// Today not being met yet doesn't break the streak: it's still alive until
/// midnight, so counting starts from yesterday in that case.
Streak computeStreak(Set<String> goalMetDays, DateTime today) {
  var day = DateTime(today.year, today.month, today.day);
  if (!goalMetDays.contains(dayKey(day))) {
    day = day.subtract(const Duration(days: 1));
  }
  var current = 0;
  while (goalMetDays.contains(dayKey(day))) {
    current++;
    // Calendar arithmetic (not Duration) so DST changes can't skip a day.
    day = DateTime(day.year, day.month, day.day - 1);
  }

  var best = 0;
  var run = 0;
  DateTime? previous;
  for (final key in goalMetDays.toList()..sort()) {
    final d = DateTime.parse(key);
    final consecutive =
        previous != null &&
        DateTime(previous.year, previous.month, previous.day + 1) == d;
    run = consecutive ? run + 1 : 1;
    if (run > best) best = run;
    previous = d;
  }
  return Streak(current: current, best: best);
}

/// Quiz accuracy for one category.
class CategoryAccuracy {
  const CategoryAccuracy(this.category, this.correct, this.attempts);

  final String category;
  final int correct;
  final int attempts;

  double get accuracy => attempts == 0 ? 0 : correct / attempts;
}
