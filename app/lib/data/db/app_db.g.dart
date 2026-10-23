// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $CardsTable extends Cards with TableInfo<$CardsTable, CardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    category,
    date,
    payload,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class CardRow extends DataClass implements Insertable<CardRow> {
  final String id;
  final String type;
  final String category;
  final String? date;
  final String payload;
  final DateTime addedAt;
  const CardRow({
    required this.id,
    required this.type,
    required this.category,
    this.date,
    required this.payload,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<String>(date);
    }
    map['payload'] = Variable<String>(payload);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      type: Value(type),
      category: Value(category),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      payload: Value(payload),
      addedAt: Value(addedAt),
    );
  }

  factory CardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      date: serializer.fromJson<String?>(json['date']),
      payload: serializer.fromJson<String>(json['payload']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'date': serializer.toJson<String?>(date),
      'payload': serializer.toJson<String>(payload),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  CardRow copyWith({
    String? id,
    String? type,
    String? category,
    Value<String?> date = const Value.absent(),
    String? payload,
    DateTime? addedAt,
  }) => CardRow(
    id: id ?? this.id,
    type: type ?? this.type,
    category: category ?? this.category,
    date: date.present ? date.value : this.date,
    payload: payload ?? this.payload,
    addedAt: addedAt ?? this.addedAt,
  );
  CardRow copyWithCompanion(CardsCompanion data) {
    return CardRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      date: data.date.present ? data.date.value : this.date,
      payload: data.payload.present ? data.payload.value : this.payload,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('payload: $payload, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, category, date, payload, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.category == this.category &&
          other.date == this.date &&
          other.payload == this.payload &&
          other.addedAt == this.addedAt);
}

class CardsCompanion extends UpdateCompanion<CardRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> category;
  final Value<String?> date;
  final Value<String> payload;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.date = const Value.absent(),
    this.payload = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsCompanion.insert({
    required String id,
    required String type,
    required String category,
    this.date = const Value.absent(),
    required String payload,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       category = Value(category),
       payload = Value(payload);
  static Insertable<CardRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? date,
    Expression<String>? payload,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (date != null) 'date': date,
      if (payload != null) 'payload': payload,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? category,
    Value<String?>? date,
    Value<String>? payload,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      payload: payload ?? this.payload,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('payload: $payload, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardStatesTable extends CardStates
    with TableInfo<$CardStatesTable, CardStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seenAtMeta = const VerificationMeta('seenAt');
  @override
  late final GeneratedColumn<DateTime> seenAt = GeneratedColumn<DateTime>(
    'seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savedMeta = const VerificationMeta('saved');
  @override
  late final GeneratedColumn<bool> saved = GeneratedColumn<bool>(
    'saved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("saved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _knowledgeMeta = const VerificationMeta(
    'knowledge',
  );
  @override
  late final GeneratedColumn<int> knowledge = GeneratedColumn<int>(
    'knowledge',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reviewFromMeta = const VerificationMeta(
    'reviewFrom',
  );
  @override
  late final GeneratedColumn<DateTime> reviewFrom = GeneratedColumn<DateTime>(
    'review_from',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewStageMeta = const VerificationMeta(
    'reviewStage',
  );
  @override
  late final GeneratedColumn<int> reviewStage = GeneratedColumn<int>(
    'review_stage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _quizAttemptsMeta = const VerificationMeta(
    'quizAttempts',
  );
  @override
  late final GeneratedColumn<int> quizAttempts = GeneratedColumn<int>(
    'quiz_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _quizCorrectMeta = const VerificationMeta(
    'quizCorrect',
  );
  @override
  late final GeneratedColumn<int> quizCorrect = GeneratedColumn<int>(
    'quiz_correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    cardId,
    seenAt,
    saved,
    knowledge,
    reviewFrom,
    reviewStage,
    quizAttempts,
    quizCorrect,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('seen_at')) {
      context.handle(
        _seenAtMeta,
        seenAt.isAcceptableOrUnknown(data['seen_at']!, _seenAtMeta),
      );
    }
    if (data.containsKey('saved')) {
      context.handle(
        _savedMeta,
        saved.isAcceptableOrUnknown(data['saved']!, _savedMeta),
      );
    }
    if (data.containsKey('knowledge')) {
      context.handle(
        _knowledgeMeta,
        knowledge.isAcceptableOrUnknown(data['knowledge']!, _knowledgeMeta),
      );
    }
    if (data.containsKey('review_from')) {
      context.handle(
        _reviewFromMeta,
        reviewFrom.isAcceptableOrUnknown(data['review_from']!, _reviewFromMeta),
      );
    }
    if (data.containsKey('review_stage')) {
      context.handle(
        _reviewStageMeta,
        reviewStage.isAcceptableOrUnknown(
          data['review_stage']!,
          _reviewStageMeta,
        ),
      );
    }
    if (data.containsKey('quiz_attempts')) {
      context.handle(
        _quizAttemptsMeta,
        quizAttempts.isAcceptableOrUnknown(
          data['quiz_attempts']!,
          _quizAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('quiz_correct')) {
      context.handle(
        _quizCorrectMeta,
        quizCorrect.isAcceptableOrUnknown(
          data['quiz_correct']!,
          _quizCorrectMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId};
  @override
  CardStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardStateRow(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      seenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}seen_at'],
      ),
      saved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}saved'],
      )!,
      knowledge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}knowledge'],
      )!,
      reviewFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}review_from'],
      ),
      reviewStage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_stage'],
      )!,
      quizAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiz_attempts'],
      )!,
      quizCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiz_correct'],
      )!,
    );
  }

  @override
  $CardStatesTable createAlias(String alias) {
    return $CardStatesTable(attachedDatabase, alias);
  }
}

class CardStateRow extends DataClass implements Insertable<CardStateRow> {
  final String cardId;
  final DateTime? seenAt;
  final bool saved;

  /// 0 = not marked, 1 = "I knew this", 2 = "New to me".
  final int knowledge;

  /// Spaced repetition: when the card was marked new (or last failed) and how
  /// many reviews have been passed since.
  final DateTime? reviewFrom;
  final int reviewStage;
  final int quizAttempts;
  final int quizCorrect;
  const CardStateRow({
    required this.cardId,
    this.seenAt,
    required this.saved,
    required this.knowledge,
    this.reviewFrom,
    required this.reviewStage,
    required this.quizAttempts,
    required this.quizCorrect,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    if (!nullToAbsent || seenAt != null) {
      map['seen_at'] = Variable<DateTime>(seenAt);
    }
    map['saved'] = Variable<bool>(saved);
    map['knowledge'] = Variable<int>(knowledge);
    if (!nullToAbsent || reviewFrom != null) {
      map['review_from'] = Variable<DateTime>(reviewFrom);
    }
    map['review_stage'] = Variable<int>(reviewStage);
    map['quiz_attempts'] = Variable<int>(quizAttempts);
    map['quiz_correct'] = Variable<int>(quizCorrect);
    return map;
  }

  CardStatesCompanion toCompanion(bool nullToAbsent) {
    return CardStatesCompanion(
      cardId: Value(cardId),
      seenAt: seenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(seenAt),
      saved: Value(saved),
      knowledge: Value(knowledge),
      reviewFrom: reviewFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewFrom),
      reviewStage: Value(reviewStage),
      quizAttempts: Value(quizAttempts),
      quizCorrect: Value(quizCorrect),
    );
  }

  factory CardStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardStateRow(
      cardId: serializer.fromJson<String>(json['cardId']),
      seenAt: serializer.fromJson<DateTime?>(json['seenAt']),
      saved: serializer.fromJson<bool>(json['saved']),
      knowledge: serializer.fromJson<int>(json['knowledge']),
      reviewFrom: serializer.fromJson<DateTime?>(json['reviewFrom']),
      reviewStage: serializer.fromJson<int>(json['reviewStage']),
      quizAttempts: serializer.fromJson<int>(json['quizAttempts']),
      quizCorrect: serializer.fromJson<int>(json['quizCorrect']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'seenAt': serializer.toJson<DateTime?>(seenAt),
      'saved': serializer.toJson<bool>(saved),
      'knowledge': serializer.toJson<int>(knowledge),
      'reviewFrom': serializer.toJson<DateTime?>(reviewFrom),
      'reviewStage': serializer.toJson<int>(reviewStage),
      'quizAttempts': serializer.toJson<int>(quizAttempts),
      'quizCorrect': serializer.toJson<int>(quizCorrect),
    };
  }

  CardStateRow copyWith({
    String? cardId,
    Value<DateTime?> seenAt = const Value.absent(),
    bool? saved,
    int? knowledge,
    Value<DateTime?> reviewFrom = const Value.absent(),
    int? reviewStage,
    int? quizAttempts,
    int? quizCorrect,
  }) => CardStateRow(
    cardId: cardId ?? this.cardId,
    seenAt: seenAt.present ? seenAt.value : this.seenAt,
    saved: saved ?? this.saved,
    knowledge: knowledge ?? this.knowledge,
    reviewFrom: reviewFrom.present ? reviewFrom.value : this.reviewFrom,
    reviewStage: reviewStage ?? this.reviewStage,
    quizAttempts: quizAttempts ?? this.quizAttempts,
    quizCorrect: quizCorrect ?? this.quizCorrect,
  );
  CardStateRow copyWithCompanion(CardStatesCompanion data) {
    return CardStateRow(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      seenAt: data.seenAt.present ? data.seenAt.value : this.seenAt,
      saved: data.saved.present ? data.saved.value : this.saved,
      knowledge: data.knowledge.present ? data.knowledge.value : this.knowledge,
      reviewFrom: data.reviewFrom.present
          ? data.reviewFrom.value
          : this.reviewFrom,
      reviewStage: data.reviewStage.present
          ? data.reviewStage.value
          : this.reviewStage,
      quizAttempts: data.quizAttempts.present
          ? data.quizAttempts.value
          : this.quizAttempts,
      quizCorrect: data.quizCorrect.present
          ? data.quizCorrect.value
          : this.quizCorrect,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardStateRow(')
          ..write('cardId: $cardId, ')
          ..write('seenAt: $seenAt, ')
          ..write('saved: $saved, ')
          ..write('knowledge: $knowledge, ')
          ..write('reviewFrom: $reviewFrom, ')
          ..write('reviewStage: $reviewStage, ')
          ..write('quizAttempts: $quizAttempts, ')
          ..write('quizCorrect: $quizCorrect')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    cardId,
    seenAt,
    saved,
    knowledge,
    reviewFrom,
    reviewStage,
    quizAttempts,
    quizCorrect,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardStateRow &&
          other.cardId == this.cardId &&
          other.seenAt == this.seenAt &&
          other.saved == this.saved &&
          other.knowledge == this.knowledge &&
          other.reviewFrom == this.reviewFrom &&
          other.reviewStage == this.reviewStage &&
          other.quizAttempts == this.quizAttempts &&
          other.quizCorrect == this.quizCorrect);
}

class CardStatesCompanion extends UpdateCompanion<CardStateRow> {
  final Value<String> cardId;
  final Value<DateTime?> seenAt;
  final Value<bool> saved;
  final Value<int> knowledge;
  final Value<DateTime?> reviewFrom;
  final Value<int> reviewStage;
  final Value<int> quizAttempts;
  final Value<int> quizCorrect;
  final Value<int> rowid;
  const CardStatesCompanion({
    this.cardId = const Value.absent(),
    this.seenAt = const Value.absent(),
    this.saved = const Value.absent(),
    this.knowledge = const Value.absent(),
    this.reviewFrom = const Value.absent(),
    this.reviewStage = const Value.absent(),
    this.quizAttempts = const Value.absent(),
    this.quizCorrect = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardStatesCompanion.insert({
    required String cardId,
    this.seenAt = const Value.absent(),
    this.saved = const Value.absent(),
    this.knowledge = const Value.absent(),
    this.reviewFrom = const Value.absent(),
    this.reviewStage = const Value.absent(),
    this.quizAttempts = const Value.absent(),
    this.quizCorrect = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId);
  static Insertable<CardStateRow> custom({
    Expression<String>? cardId,
    Expression<DateTime>? seenAt,
    Expression<bool>? saved,
    Expression<int>? knowledge,
    Expression<DateTime>? reviewFrom,
    Expression<int>? reviewStage,
    Expression<int>? quizAttempts,
    Expression<int>? quizCorrect,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (seenAt != null) 'seen_at': seenAt,
      if (saved != null) 'saved': saved,
      if (knowledge != null) 'knowledge': knowledge,
      if (reviewFrom != null) 'review_from': reviewFrom,
      if (reviewStage != null) 'review_stage': reviewStage,
      if (quizAttempts != null) 'quiz_attempts': quizAttempts,
      if (quizCorrect != null) 'quiz_correct': quizCorrect,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardStatesCompanion copyWith({
    Value<String>? cardId,
    Value<DateTime?>? seenAt,
    Value<bool>? saved,
    Value<int>? knowledge,
    Value<DateTime?>? reviewFrom,
    Value<int>? reviewStage,
    Value<int>? quizAttempts,
    Value<int>? quizCorrect,
    Value<int>? rowid,
  }) {
    return CardStatesCompanion(
      cardId: cardId ?? this.cardId,
      seenAt: seenAt ?? this.seenAt,
      saved: saved ?? this.saved,
      knowledge: knowledge ?? this.knowledge,
      reviewFrom: reviewFrom ?? this.reviewFrom,
      reviewStage: reviewStage ?? this.reviewStage,
      quizAttempts: quizAttempts ?? this.quizAttempts,
      quizCorrect: quizCorrect ?? this.quizCorrect,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (seenAt.present) {
      map['seen_at'] = Variable<DateTime>(seenAt.value);
    }
    if (saved.present) {
      map['saved'] = Variable<bool>(saved.value);
    }
    if (knowledge.present) {
      map['knowledge'] = Variable<int>(knowledge.value);
    }
    if (reviewFrom.present) {
      map['review_from'] = Variable<DateTime>(reviewFrom.value);
    }
    if (reviewStage.present) {
      map['review_stage'] = Variable<int>(reviewStage.value);
    }
    if (quizAttempts.present) {
      map['quiz_attempts'] = Variable<int>(quizAttempts.value);
    }
    if (quizCorrect.present) {
      map['quiz_correct'] = Variable<int>(quizCorrect.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardStatesCompanion(')
          ..write('cardId: $cardId, ')
          ..write('seenAt: $seenAt, ')
          ..write('saved: $saved, ')
          ..write('knowledge: $knowledge, ')
          ..write('reviewFrom: $reviewFrom, ')
          ..write('reviewStage: $reviewStage, ')
          ..write('quizAttempts: $quizAttempts, ')
          ..write('quizCorrect: $quizCorrect, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncedFilesTable extends SyncedFiles
    with TableInfo<$SyncedFilesTable, SyncedFileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncedFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fileMeta = const VerificationMeta('file');
  @override
  late final GeneratedColumn<String> file = GeneratedColumn<String>(
    'file',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [file, version];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'synced_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncedFileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('file')) {
      context.handle(
        _fileMeta,
        file.isAcceptableOrUnknown(data['file']!, _fileMeta),
      );
    } else if (isInserting) {
      context.missing(_fileMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {file};
  @override
  SyncedFileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncedFileRow(
      file: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $SyncedFilesTable createAlias(String alias) {
    return $SyncedFilesTable(attachedDatabase, alias);
  }
}

class SyncedFileRow extends DataClass implements Insertable<SyncedFileRow> {
  final String file;
  final String version;
  const SyncedFileRow({required this.file, required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file'] = Variable<String>(file);
    map['version'] = Variable<String>(version);
    return map;
  }

  SyncedFilesCompanion toCompanion(bool nullToAbsent) {
    return SyncedFilesCompanion(file: Value(file), version: Value(version));
  }

  factory SyncedFileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncedFileRow(
      file: serializer.fromJson<String>(json['file']),
      version: serializer.fromJson<String>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'file': serializer.toJson<String>(file),
      'version': serializer.toJson<String>(version),
    };
  }

  SyncedFileRow copyWith({String? file, String? version}) =>
      SyncedFileRow(file: file ?? this.file, version: version ?? this.version);
  SyncedFileRow copyWithCompanion(SyncedFilesCompanion data) {
    return SyncedFileRow(
      file: data.file.present ? data.file.value : this.file,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncedFileRow(')
          ..write('file: $file, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(file, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncedFileRow &&
          other.file == this.file &&
          other.version == this.version);
}

class SyncedFilesCompanion extends UpdateCompanion<SyncedFileRow> {
  final Value<String> file;
  final Value<String> version;
  final Value<int> rowid;
  const SyncedFilesCompanion({
    this.file = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncedFilesCompanion.insert({
    required String file,
    required String version,
    this.rowid = const Value.absent(),
  }) : file = Value(file),
       version = Value(version);
  static Insertable<SyncedFileRow> custom({
    Expression<String>? file,
    Expression<String>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (file != null) 'file': file,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncedFilesCompanion copyWith({
    Value<String>? file,
    Value<String>? version,
    Value<int>? rowid,
  }) {
    return SyncedFilesCompanion(
      file: file ?? this.file,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (file.present) {
      map['file'] = Variable<String>(file.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncedFilesCompanion(')
          ..write('file: $file, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $CardStatesTable cardStates = $CardStatesTable(this);
  late final $SyncedFilesTable syncedFiles = $SyncedFilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cards,
    cardStates,
    syncedFiles,
  ];
}

typedef $$CardsTableCreateCompanionBuilder = CardsCompanion Function({
  required String id,
  required String type,
  required String category,
  Value<String?> date,
  required String payload,
  Value<DateTime> addedAt,
  Value<int> rowid,
});
typedef $$CardsTableUpdateCompanionBuilder = CardsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> category,
  Value<String?> date,
  Value<String> payload,
  Value<DateTime> addedAt,
  Value<int> rowid,
});

class $$CardsTableFilterComposer extends Composer<_$AppDb, $CardsTable> {
  $$CardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardsTableOrderingComposer extends Composer<_$AppDb, $CardsTable> {
  $$CardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardsTableAnnotationComposer extends Composer<_$AppDb, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $CardsTable,
          CardRow,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (CardRow, BaseReferences<_$AppDb, $CardsTable, CardRow>),
          CardRow,
          PrefetchHooks Function()
        > {
  $$CardsTableTableManager(_$AppDb db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> date = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                type: type,
                category: category,
                date: date,
                payload: payload,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String category,
                Value<String?> date = const Value.absent(),
                required String payload,
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                type: type,
                category: category,
                date: date,
                payload: payload,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardsTable, CardRow>(table),
                  BaseReferences<_$AppDb, $CardsTable, CardRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $CardsTable,
      CardRow,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (CardRow, BaseReferences<_$AppDb, $CardsTable, CardRow>),
      CardRow,
      PrefetchHooks Function()
    >;
typedef $$CardStatesTableCreateCompanionBuilder = CardStatesCompanion Function({
  required String cardId,
  Value<DateTime?> seenAt,
  Value<bool> saved,
  Value<int> knowledge,
  Value<DateTime?> reviewFrom,
  Value<int> reviewStage,
  Value<int> quizAttempts,
  Value<int> quizCorrect,
  Value<int> rowid,
});
typedef $$CardStatesTableUpdateCompanionBuilder = CardStatesCompanion Function({
  Value<String> cardId,
  Value<DateTime?> seenAt,
  Value<bool> saved,
  Value<int> knowledge,
  Value<DateTime?> reviewFrom,
  Value<int> reviewStage,
  Value<int> quizAttempts,
  Value<int> quizCorrect,
  Value<int> rowid,
});

class $$CardStatesTableFilterComposer
    extends Composer<_$AppDb, $CardStatesTable> {
  $$CardStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get seenAt => $composableBuilder(
    column: $table.seenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get saved => $composableBuilder(
    column: $table.saved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get knowledge => $composableBuilder(
    column: $table.knowledge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewFrom => $composableBuilder(
    column: $table.reviewFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewStage => $composableBuilder(
    column: $table.reviewStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quizAttempts => $composableBuilder(
    column: $table.quizAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quizCorrect => $composableBuilder(
    column: $table.quizCorrect,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardStatesTableOrderingComposer
    extends Composer<_$AppDb, $CardStatesTable> {
  $$CardStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get seenAt => $composableBuilder(
    column: $table.seenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get saved => $composableBuilder(
    column: $table.saved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get knowledge => $composableBuilder(
    column: $table.knowledge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewFrom => $composableBuilder(
    column: $table.reviewFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewStage => $composableBuilder(
    column: $table.reviewStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quizAttempts => $composableBuilder(
    column: $table.quizAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quizCorrect => $composableBuilder(
    column: $table.quizCorrect,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardStatesTableAnnotationComposer
    extends Composer<_$AppDb, $CardStatesTable> {
  $$CardStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<DateTime> get seenAt =>
      $composableBuilder(column: $table.seenAt, builder: (column) => column);

  GeneratedColumn<bool> get saved =>
      $composableBuilder(column: $table.saved, builder: (column) => column);

  GeneratedColumn<int> get knowledge =>
      $composableBuilder(column: $table.knowledge, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewFrom => $composableBuilder(
    column: $table.reviewFrom,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewStage => $composableBuilder(
    column: $table.reviewStage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quizAttempts => $composableBuilder(
    column: $table.quizAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quizCorrect => $composableBuilder(
    column: $table.quizCorrect,
    builder: (column) => column,
  );
}

class $$CardStatesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $CardStatesTable,
          CardStateRow,
          $$CardStatesTableFilterComposer,
          $$CardStatesTableOrderingComposer,
          $$CardStatesTableAnnotationComposer,
          $$CardStatesTableCreateCompanionBuilder,
          $$CardStatesTableUpdateCompanionBuilder,
          (
            CardStateRow,
            BaseReferences<_$AppDb, $CardStatesTable, CardStateRow>,
          ),
          CardStateRow,
          PrefetchHooks Function()
        > {
  $$CardStatesTableTableManager(_$AppDb db, $CardStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<DateTime?> seenAt = const Value.absent(),
                Value<bool> saved = const Value.absent(),
                Value<int> knowledge = const Value.absent(),
                Value<DateTime?> reviewFrom = const Value.absent(),
                Value<int> reviewStage = const Value.absent(),
                Value<int> quizAttempts = const Value.absent(),
                Value<int> quizCorrect = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardStatesCompanion(
                cardId: cardId,
                seenAt: seenAt,
                saved: saved,
                knowledge: knowledge,
                reviewFrom: reviewFrom,
                reviewStage: reviewStage,
                quizAttempts: quizAttempts,
                quizCorrect: quizCorrect,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                Value<DateTime?> seenAt = const Value.absent(),
                Value<bool> saved = const Value.absent(),
                Value<int> knowledge = const Value.absent(),
                Value<DateTime?> reviewFrom = const Value.absent(),
                Value<int> reviewStage = const Value.absent(),
                Value<int> quizAttempts = const Value.absent(),
                Value<int> quizCorrect = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardStatesCompanion.insert(
                cardId: cardId,
                seenAt: seenAt,
                saved: saved,
                knowledge: knowledge,
                reviewFrom: reviewFrom,
                reviewStage: reviewStage,
                quizAttempts: quizAttempts,
                quizCorrect: quizCorrect,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardStatesTable, CardStateRow>(table),
                  BaseReferences<_$AppDb, $CardStatesTable, CardStateRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $CardStatesTable,
      CardStateRow,
      $$CardStatesTableFilterComposer,
      $$CardStatesTableOrderingComposer,
      $$CardStatesTableAnnotationComposer,
      $$CardStatesTableCreateCompanionBuilder,
      $$CardStatesTableUpdateCompanionBuilder,
      (CardStateRow, BaseReferences<_$AppDb, $CardStatesTable, CardStateRow>),
      CardStateRow,
      PrefetchHooks Function()
    >;
typedef $$SyncedFilesTableCreateCompanionBuilder =
    SyncedFilesCompanion Function({
      required String file,
      required String version,
      Value<int> rowid,
    });
typedef $$SyncedFilesTableUpdateCompanionBuilder =
    SyncedFilesCompanion Function({
      Value<String> file,
      Value<String> version,
      Value<int> rowid,
    });

class $$SyncedFilesTableFilterComposer
    extends Composer<_$AppDb, $SyncedFilesTable> {
  $$SyncedFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get file => $composableBuilder(
    column: $table.file,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncedFilesTableOrderingComposer
    extends Composer<_$AppDb, $SyncedFilesTable> {
  $$SyncedFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get file => $composableBuilder(
    column: $table.file,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncedFilesTableAnnotationComposer
    extends Composer<_$AppDb, $SyncedFilesTable> {
  $$SyncedFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get file =>
      $composableBuilder(column: $table.file, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$SyncedFilesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $SyncedFilesTable,
          SyncedFileRow,
          $$SyncedFilesTableFilterComposer,
          $$SyncedFilesTableOrderingComposer,
          $$SyncedFilesTableAnnotationComposer,
          $$SyncedFilesTableCreateCompanionBuilder,
          $$SyncedFilesTableUpdateCompanionBuilder,
          (
            SyncedFileRow,
            BaseReferences<_$AppDb, $SyncedFilesTable, SyncedFileRow>,
          ),
          SyncedFileRow,
          PrefetchHooks Function()
        > {
  $$SyncedFilesTableTableManager(_$AppDb db, $SyncedFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncedFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncedFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncedFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> file = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncedFilesCompanion(
                file: file,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String file,
                required String version,
                Value<int> rowid = const Value.absent(),
              }) => SyncedFilesCompanion.insert(
                file: file,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncedFilesTable, SyncedFileRow>(table),
                  BaseReferences<_$AppDb, $SyncedFilesTable, SyncedFileRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncedFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $SyncedFilesTable,
      SyncedFileRow,
      $$SyncedFilesTableFilterComposer,
      $$SyncedFilesTableOrderingComposer,
      $$SyncedFilesTableAnnotationComposer,
      $$SyncedFilesTableCreateCompanionBuilder,
      $$SyncedFilesTableUpdateCompanionBuilder,
      (
        SyncedFileRow,
        BaseReferences<_$AppDb, $SyncedFilesTable, SyncedFileRow>,
      ),
      SyncedFileRow,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$CardStatesTableTableManager get cardStates =>
      $$CardStatesTableTableManager(_db, _db.cardStates);
  $$SyncedFilesTableTableManager get syncedFiles =>
      $$SyncedFilesTableTableManager(_db, _db.syncedFiles);
}
