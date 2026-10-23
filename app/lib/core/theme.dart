import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CategoryStyle {
  const CategoryStyle(this.label, this.icon, this.colors);

  final String label;
  final IconData icon;

  /// Top and bottom of the card's background gradient.
  final List<Color> colors;
}

const _categories = {
  'polity': CategoryStyle('Polity', Icons.account_balance, [
    Color(0xFF1E3A8A),
    Color(0xFF0B1026),
  ]),
  'economy': CategoryStyle('Economy', Icons.currency_rupee, [
    Color(0xFF065F46),
    Color(0xFF04140F),
  ]),
  'geography': CategoryStyle('Geography', Icons.terrain, [
    Color(0xFF92400E),
    Color(0xFF1A0E04),
  ]),
  'history': CategoryStyle('History', Icons.history_edu, [
    Color(0xFF7C2D12),
    Color(0xFF1A0905),
  ]),
  'science': CategoryStyle('Science & Tech', Icons.rocket_launch, [
    Color(0xFF5B21B6),
    Color(0xFF12082A),
  ]),
  'sports': CategoryStyle('Sports', Icons.sports_cricket, [
    Color(0xFFB45309),
    Color(0xFF1C1003),
  ]),
  'international': CategoryStyle('International', Icons.public, [
    Color(0xFF0E7490),
    Color(0xFF041519),
  ]),
  'states': CategoryStyle('States', Icons.map, [
    Color(0xFF9D174D),
    Color(0xFF1C0510),
  ]),
  'culture': CategoryStyle('Culture', Icons.festival, [
    Color(0xFFA21CAF),
    Color(0xFF1B0520),
  ]),
  'environment': CategoryStyle('Environment', Icons.park, [
    Color(0xFF15803D),
    Color(0xFF04160A),
  ]),
};

const _fallback = CategoryStyle('General', Icons.lightbulb, [
  Color(0xFF374151),
  Color(0xFF0B0F14),
]);

CategoryStyle categoryStyle(String category) =>
    _categories[category] ?? _fallback;

List<String> get knownCategories => _categories.keys.toList();

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFFFF9933), // saffron
    brightness: Brightness.dark,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF07090D),
    useMaterial3: true,
  );
}

/// Lets you drag the feed with a mouse/trackpad when running on the web.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
