import 'dart:convert';

enum CardType { news, gk, quiz, trivia }

CardType _parseType(String? raw) =>
    CardType.values.firstWhere((t) => t.name == raw, orElse: () => CardType.gk);

class Quiz {
  const Quiz({
    required this.question,
    required this.options,
    required this.answer,
    this.explain,
  });

  final String question;
  final List<String> options;
  final int answer;
  final String? explain;

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
    question: json['q'] as String,
    options: (json['options'] as List).cast<String>(),
    answer: json['answer'] as int,
    explain: json['explain'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'q': question,
    'options': options,
    'answer': answer,
    if (explain != null) 'explain': explain,
  };
}

/// One swipeable card. Matches the JSON schema shared with the pipeline.
class LearnCard {
  const LearnCard({
    required this.id,
    required this.type,
    required this.category,
    required this.headline,
    required this.body,
    this.whyItMatters,
    this.keyFact,
    this.sourceUrl,
    this.date,
    this.quiz,
    this.tags = const [],
  });

  final String id;
  final CardType type;
  final String category;
  final String headline;
  final String body;
  final String? whyItMatters;
  final String? keyFact;
  final String? sourceUrl;
  final String? date;
  final Quiz? quiz;
  final List<String> tags;

  factory LearnCard.fromJson(Map<String, dynamic> json) => LearnCard(
    id: json['id'] as String,
    type: _parseType(json['type'] as String?),
    category: (json['category'] as String? ?? 'general').toLowerCase(),
    headline: json['headline'] as String,
    body: json['body'] as String? ?? '',
    whyItMatters: json['why_it_matters'] as String?,
    keyFact: json['key_fact'] as String?,
    sourceUrl: json['source_url'] as String?,
    date: json['date'] as String?,
    quiz: json['quiz'] == null
        ? null
        : Quiz.fromJson(json['quiz'] as Map<String, dynamic>),
    tags: (json['tags'] as List?)?.cast<String>() ?? const [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'category': category,
    'headline': headline,
    'body': body,
    if (whyItMatters != null) 'why_it_matters': whyItMatters,
    if (keyFact != null) 'key_fact': keyFact,
    if (sourceUrl != null) 'source_url': sourceUrl,
    if (date != null) 'date': date,
    if (quiz != null) 'quiz': quiz!.toJson(),
    if (tags.isNotEmpty) 'tags': tags,
  };

  String encode() => jsonEncode(toJson());

  static LearnCard decode(String raw) =>
      LearnCard.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
