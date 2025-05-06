// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CharacterCardsTable extends CharacterCards
    with TableInfo<$CharacterCardsTable, CharacterCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _characterMeta = const VerificationMeta(
    'character',
  );
  @override
  late final GeneratedColumn<String> character = GeneratedColumn<String>(
    'character',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinyinMeta = const VerificationMeta('pinyin');
  @override
  late final GeneratedColumn<String> pinyin = GeneratedColumn<String>(
    'pinyin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _repetitionMeta = const VerificationMeta(
    'repetition',
  );
  @override
  late final GeneratedColumn<int> repetition = GeneratedColumn<int>(
    'repetition',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _learningStepMeta = const VerificationMeta(
    'learningStep',
  );
  @override
  late final GeneratedColumn<int> learningStep = GeneratedColumn<int>(
    'learning_step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextReviewMeta = const VerificationMeta(
    'nextReview',
  );
  @override
  late final GeneratedColumn<DateTime> nextReview = GeneratedColumn<DateTime>(
    'next_review',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinyinPlainMeta = const VerificationMeta(
    'pinyinPlain',
  );
  @override
  late final GeneratedColumn<String> pinyinPlain = GeneratedColumn<String>(
    'pinyin_plain',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chineseSentenceMeta = const VerificationMeta(
    'chineseSentence',
  );
  @override
  late final GeneratedColumn<String> chineseSentence = GeneratedColumn<String>(
    'chinese_sentence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinyinSentenceMeta = const VerificationMeta(
    'pinyinSentence',
  );
  @override
  late final GeneratedColumn<String> pinyinSentence = GeneratedColumn<String>(
    'pinyin_sentence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _englishSentenceMeta = const VerificationMeta(
    'englishSentence',
  );
  @override
  late final GeneratedColumn<String> englishSentence = GeneratedColumn<String>(
    'english_sentence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    character,
    pinyin,
    definition,
    interval,
    repetition,
    easeFactor,
    learningStep,
    nextReview,
    notes,
    pinyinPlain,
    chineseSentence,
    pinyinSentence,
    englishSentence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('character')) {
      context.handle(
        _characterMeta,
        character.isAcceptableOrUnknown(data['character']!, _characterMeta),
      );
    } else if (isInserting) {
      context.missing(_characterMeta);
    }
    if (data.containsKey('pinyin')) {
      context.handle(
        _pinyinMeta,
        pinyin.isAcceptableOrUnknown(data['pinyin']!, _pinyinMeta),
      );
    } else if (isInserting) {
      context.missing(_pinyinMeta);
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    } else if (isInserting) {
      context.missing(_definitionMeta);
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    }
    if (data.containsKey('repetition')) {
      context.handle(
        _repetitionMeta,
        repetition.isAcceptableOrUnknown(data['repetition']!, _repetitionMeta),
      );
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('learning_step')) {
      context.handle(
        _learningStepMeta,
        learningStep.isAcceptableOrUnknown(
          data['learning_step']!,
          _learningStepMeta,
        ),
      );
    }
    if (data.containsKey('next_review')) {
      context.handle(
        _nextReviewMeta,
        nextReview.isAcceptableOrUnknown(data['next_review']!, _nextReviewMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('pinyin_plain')) {
      context.handle(
        _pinyinPlainMeta,
        pinyinPlain.isAcceptableOrUnknown(
          data['pinyin_plain']!,
          _pinyinPlainMeta,
        ),
      );
    }
    if (data.containsKey('chinese_sentence')) {
      context.handle(
        _chineseSentenceMeta,
        chineseSentence.isAcceptableOrUnknown(
          data['chinese_sentence']!,
          _chineseSentenceMeta,
        ),
      );
    }
    if (data.containsKey('pinyin_sentence')) {
      context.handle(
        _pinyinSentenceMeta,
        pinyinSentence.isAcceptableOrUnknown(
          data['pinyin_sentence']!,
          _pinyinSentenceMeta,
        ),
      );
    }
    if (data.containsKey('english_sentence')) {
      context.handle(
        _englishSentenceMeta,
        englishSentence.isAcceptableOrUnknown(
          data['english_sentence']!,
          _englishSentenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {character};
  @override
  CharacterCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterCard(
      character:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}character'],
          )!,
      pinyin:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}pinyin'],
          )!,
      definition:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}definition'],
          )!,
      interval:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}interval'],
          )!,
      repetition:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}repetition'],
          )!,
      easeFactor:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}ease_factor'],
          )!,
      learningStep:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}learning_step'],
          )!,
      nextReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      pinyinPlain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinyin_plain'],
      ),
      chineseSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chinese_sentence'],
      ),
      pinyinSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinyin_sentence'],
      ),
      englishSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_sentence'],
      ),
    );
  }

  @override
  $CharacterCardsTable createAlias(String alias) {
    return $CharacterCardsTable(attachedDatabase, alias);
  }
}

class CharacterCard extends DataClass implements Insertable<CharacterCard> {
  final String character;
  final String pinyin;
  final String definition;
  final int interval;
  final int repetition;
  final double easeFactor;
  final int learningStep;
  final DateTime? nextReview;
  final String? notes;
  final String? pinyinPlain;
  final String? chineseSentence;
  final String? pinyinSentence;
  final String? englishSentence;
  const CharacterCard({
    required this.character,
    required this.pinyin,
    required this.definition,
    required this.interval,
    required this.repetition,
    required this.easeFactor,
    required this.learningStep,
    this.nextReview,
    this.notes,
    this.pinyinPlain,
    this.chineseSentence,
    this.pinyinSentence,
    this.englishSentence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['character'] = Variable<String>(character);
    map['pinyin'] = Variable<String>(pinyin);
    map['definition'] = Variable<String>(definition);
    map['interval'] = Variable<int>(interval);
    map['repetition'] = Variable<int>(repetition);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['learning_step'] = Variable<int>(learningStep);
    if (!nullToAbsent || nextReview != null) {
      map['next_review'] = Variable<DateTime>(nextReview);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || pinyinPlain != null) {
      map['pinyin_plain'] = Variable<String>(pinyinPlain);
    }
    if (!nullToAbsent || chineseSentence != null) {
      map['chinese_sentence'] = Variable<String>(chineseSentence);
    }
    if (!nullToAbsent || pinyinSentence != null) {
      map['pinyin_sentence'] = Variable<String>(pinyinSentence);
    }
    if (!nullToAbsent || englishSentence != null) {
      map['english_sentence'] = Variable<String>(englishSentence);
    }
    return map;
  }

  CharacterCardsCompanion toCompanion(bool nullToAbsent) {
    return CharacterCardsCompanion(
      character: Value(character),
      pinyin: Value(pinyin),
      definition: Value(definition),
      interval: Value(interval),
      repetition: Value(repetition),
      easeFactor: Value(easeFactor),
      learningStep: Value(learningStep),
      nextReview:
          nextReview == null && nullToAbsent
              ? const Value.absent()
              : Value(nextReview),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      pinyinPlain:
          pinyinPlain == null && nullToAbsent
              ? const Value.absent()
              : Value(pinyinPlain),
      chineseSentence:
          chineseSentence == null && nullToAbsent
              ? const Value.absent()
              : Value(chineseSentence),
      pinyinSentence:
          pinyinSentence == null && nullToAbsent
              ? const Value.absent()
              : Value(pinyinSentence),
      englishSentence:
          englishSentence == null && nullToAbsent
              ? const Value.absent()
              : Value(englishSentence),
    );
  }

  factory CharacterCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterCard(
      character: serializer.fromJson<String>(json['character']),
      pinyin: serializer.fromJson<String>(json['pinyin']),
      definition: serializer.fromJson<String>(json['definition']),
      interval: serializer.fromJson<int>(json['interval']),
      repetition: serializer.fromJson<int>(json['repetition']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      learningStep: serializer.fromJson<int>(json['learningStep']),
      nextReview: serializer.fromJson<DateTime?>(json['nextReview']),
      notes: serializer.fromJson<String?>(json['notes']),
      pinyinPlain: serializer.fromJson<String?>(json['pinyinPlain']),
      chineseSentence: serializer.fromJson<String?>(json['chineseSentence']),
      pinyinSentence: serializer.fromJson<String?>(json['pinyinSentence']),
      englishSentence: serializer.fromJson<String?>(json['englishSentence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'character': serializer.toJson<String>(character),
      'pinyin': serializer.toJson<String>(pinyin),
      'definition': serializer.toJson<String>(definition),
      'interval': serializer.toJson<int>(interval),
      'repetition': serializer.toJson<int>(repetition),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'learningStep': serializer.toJson<int>(learningStep),
      'nextReview': serializer.toJson<DateTime?>(nextReview),
      'notes': serializer.toJson<String?>(notes),
      'pinyinPlain': serializer.toJson<String?>(pinyinPlain),
      'chineseSentence': serializer.toJson<String?>(chineseSentence),
      'pinyinSentence': serializer.toJson<String?>(pinyinSentence),
      'englishSentence': serializer.toJson<String?>(englishSentence),
    };
  }

  CharacterCard copyWith({
    String? character,
    String? pinyin,
    String? definition,
    int? interval,
    int? repetition,
    double? easeFactor,
    int? learningStep,
    Value<DateTime?> nextReview = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> pinyinPlain = const Value.absent(),
    Value<String?> chineseSentence = const Value.absent(),
    Value<String?> pinyinSentence = const Value.absent(),
    Value<String?> englishSentence = const Value.absent(),
  }) => CharacterCard(
    character: character ?? this.character,
    pinyin: pinyin ?? this.pinyin,
    definition: definition ?? this.definition,
    interval: interval ?? this.interval,
    repetition: repetition ?? this.repetition,
    easeFactor: easeFactor ?? this.easeFactor,
    learningStep: learningStep ?? this.learningStep,
    nextReview: nextReview.present ? nextReview.value : this.nextReview,
    notes: notes.present ? notes.value : this.notes,
    pinyinPlain: pinyinPlain.present ? pinyinPlain.value : this.pinyinPlain,
    chineseSentence:
        chineseSentence.present ? chineseSentence.value : this.chineseSentence,
    pinyinSentence:
        pinyinSentence.present ? pinyinSentence.value : this.pinyinSentence,
    englishSentence:
        englishSentence.present ? englishSentence.value : this.englishSentence,
  );
  CharacterCard copyWithCompanion(CharacterCardsCompanion data) {
    return CharacterCard(
      character: data.character.present ? data.character.value : this.character,
      pinyin: data.pinyin.present ? data.pinyin.value : this.pinyin,
      definition:
          data.definition.present ? data.definition.value : this.definition,
      interval: data.interval.present ? data.interval.value : this.interval,
      repetition:
          data.repetition.present ? data.repetition.value : this.repetition,
      easeFactor:
          data.easeFactor.present ? data.easeFactor.value : this.easeFactor,
      learningStep:
          data.learningStep.present
              ? data.learningStep.value
              : this.learningStep,
      nextReview:
          data.nextReview.present ? data.nextReview.value : this.nextReview,
      notes: data.notes.present ? data.notes.value : this.notes,
      pinyinPlain:
          data.pinyinPlain.present ? data.pinyinPlain.value : this.pinyinPlain,
      chineseSentence:
          data.chineseSentence.present
              ? data.chineseSentence.value
              : this.chineseSentence,
      pinyinSentence:
          data.pinyinSentence.present
              ? data.pinyinSentence.value
              : this.pinyinSentence,
      englishSentence:
          data.englishSentence.present
              ? data.englishSentence.value
              : this.englishSentence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterCard(')
          ..write('character: $character, ')
          ..write('pinyin: $pinyin, ')
          ..write('definition: $definition, ')
          ..write('interval: $interval, ')
          ..write('repetition: $repetition, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('learningStep: $learningStep, ')
          ..write('nextReview: $nextReview, ')
          ..write('notes: $notes, ')
          ..write('pinyinPlain: $pinyinPlain, ')
          ..write('chineseSentence: $chineseSentence, ')
          ..write('pinyinSentence: $pinyinSentence, ')
          ..write('englishSentence: $englishSentence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    character,
    pinyin,
    definition,
    interval,
    repetition,
    easeFactor,
    learningStep,
    nextReview,
    notes,
    pinyinPlain,
    chineseSentence,
    pinyinSentence,
    englishSentence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterCard &&
          other.character == this.character &&
          other.pinyin == this.pinyin &&
          other.definition == this.definition &&
          other.interval == this.interval &&
          other.repetition == this.repetition &&
          other.easeFactor == this.easeFactor &&
          other.learningStep == this.learningStep &&
          other.nextReview == this.nextReview &&
          other.notes == this.notes &&
          other.pinyinPlain == this.pinyinPlain &&
          other.chineseSentence == this.chineseSentence &&
          other.pinyinSentence == this.pinyinSentence &&
          other.englishSentence == this.englishSentence);
}

class CharacterCardsCompanion extends UpdateCompanion<CharacterCard> {
  final Value<String> character;
  final Value<String> pinyin;
  final Value<String> definition;
  final Value<int> interval;
  final Value<int> repetition;
  final Value<double> easeFactor;
  final Value<int> learningStep;
  final Value<DateTime?> nextReview;
  final Value<String?> notes;
  final Value<String?> pinyinPlain;
  final Value<String?> chineseSentence;
  final Value<String?> pinyinSentence;
  final Value<String?> englishSentence;
  final Value<int> rowid;
  const CharacterCardsCompanion({
    this.character = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.definition = const Value.absent(),
    this.interval = const Value.absent(),
    this.repetition = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.learningStep = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.notes = const Value.absent(),
    this.pinyinPlain = const Value.absent(),
    this.chineseSentence = const Value.absent(),
    this.pinyinSentence = const Value.absent(),
    this.englishSentence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharacterCardsCompanion.insert({
    required String character,
    required String pinyin,
    required String definition,
    this.interval = const Value.absent(),
    this.repetition = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.learningStep = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.notes = const Value.absent(),
    this.pinyinPlain = const Value.absent(),
    this.chineseSentence = const Value.absent(),
    this.pinyinSentence = const Value.absent(),
    this.englishSentence = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : character = Value(character),
       pinyin = Value(pinyin),
       definition = Value(definition);
  static Insertable<CharacterCard> custom({
    Expression<String>? character,
    Expression<String>? pinyin,
    Expression<String>? definition,
    Expression<int>? interval,
    Expression<int>? repetition,
    Expression<double>? easeFactor,
    Expression<int>? learningStep,
    Expression<DateTime>? nextReview,
    Expression<String>? notes,
    Expression<String>? pinyinPlain,
    Expression<String>? chineseSentence,
    Expression<String>? pinyinSentence,
    Expression<String>? englishSentence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (character != null) 'character': character,
      if (pinyin != null) 'pinyin': pinyin,
      if (definition != null) 'definition': definition,
      if (interval != null) 'interval': interval,
      if (repetition != null) 'repetition': repetition,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (learningStep != null) 'learning_step': learningStep,
      if (nextReview != null) 'next_review': nextReview,
      if (notes != null) 'notes': notes,
      if (pinyinPlain != null) 'pinyin_plain': pinyinPlain,
      if (chineseSentence != null) 'chinese_sentence': chineseSentence,
      if (pinyinSentence != null) 'pinyin_sentence': pinyinSentence,
      if (englishSentence != null) 'english_sentence': englishSentence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharacterCardsCompanion copyWith({
    Value<String>? character,
    Value<String>? pinyin,
    Value<String>? definition,
    Value<int>? interval,
    Value<int>? repetition,
    Value<double>? easeFactor,
    Value<int>? learningStep,
    Value<DateTime?>? nextReview,
    Value<String?>? notes,
    Value<String?>? pinyinPlain,
    Value<String?>? chineseSentence,
    Value<String?>? pinyinSentence,
    Value<String?>? englishSentence,
    Value<int>? rowid,
  }) {
    return CharacterCardsCompanion(
      character: character ?? this.character,
      pinyin: pinyin ?? this.pinyin,
      definition: definition ?? this.definition,
      interval: interval ?? this.interval,
      repetition: repetition ?? this.repetition,
      easeFactor: easeFactor ?? this.easeFactor,
      learningStep: learningStep ?? this.learningStep,
      nextReview: nextReview ?? this.nextReview,
      notes: notes ?? this.notes,
      pinyinPlain: pinyinPlain ?? this.pinyinPlain,
      chineseSentence: chineseSentence ?? this.chineseSentence,
      pinyinSentence: pinyinSentence ?? this.pinyinSentence,
      englishSentence: englishSentence ?? this.englishSentence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (character.present) {
      map['character'] = Variable<String>(character.value);
    }
    if (pinyin.present) {
      map['pinyin'] = Variable<String>(pinyin.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (repetition.present) {
      map['repetition'] = Variable<int>(repetition.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (learningStep.present) {
      map['learning_step'] = Variable<int>(learningStep.value);
    }
    if (nextReview.present) {
      map['next_review'] = Variable<DateTime>(nextReview.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (pinyinPlain.present) {
      map['pinyin_plain'] = Variable<String>(pinyinPlain.value);
    }
    if (chineseSentence.present) {
      map['chinese_sentence'] = Variable<String>(chineseSentence.value);
    }
    if (pinyinSentence.present) {
      map['pinyin_sentence'] = Variable<String>(pinyinSentence.value);
    }
    if (englishSentence.present) {
      map['english_sentence'] = Variable<String>(englishSentence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterCardsCompanion(')
          ..write('character: $character, ')
          ..write('pinyin: $pinyin, ')
          ..write('definition: $definition, ')
          ..write('interval: $interval, ')
          ..write('repetition: $repetition, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('learningStep: $learningStep, ')
          ..write('nextReview: $nextReview, ')
          ..write('notes: $notes, ')
          ..write('pinyinPlain: $pinyinPlain, ')
          ..write('chineseSentence: $chineseSentence, ')
          ..write('pinyinSentence: $pinyinSentence, ')
          ..write('englishSentence: $englishSentence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DictionaryEntriesTable extends DictionaryEntries
    with TableInfo<$DictionaryEntriesTable, DictionaryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DictionaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _simplifiedMeta = const VerificationMeta(
    'simplified',
  );
  @override
  late final GeneratedColumn<String> simplified = GeneratedColumn<String>(
    'simplified',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _traditionalMeta = const VerificationMeta(
    'traditional',
  );
  @override
  late final GeneratedColumn<String> traditional = GeneratedColumn<String>(
    'traditional',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinyinMeta = const VerificationMeta('pinyin');
  @override
  late final GeneratedColumn<String> pinyin = GeneratedColumn<String>(
    'pinyin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionMeta = const VerificationMeta(
    'definition',
  );
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
    'definition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinyinPlainMeta = const VerificationMeta(
    'pinyinPlain',
  );
  @override
  late final GeneratedColumn<String> pinyinPlain = GeneratedColumn<String>(
    'pinyin_plain',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    simplified,
    traditional,
    pinyin,
    definition,
    pinyinPlain,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dictionary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DictionaryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('simplified')) {
      context.handle(
        _simplifiedMeta,
        simplified.isAcceptableOrUnknown(data['simplified']!, _simplifiedMeta),
      );
    } else if (isInserting) {
      context.missing(_simplifiedMeta);
    }
    if (data.containsKey('traditional')) {
      context.handle(
        _traditionalMeta,
        traditional.isAcceptableOrUnknown(
          data['traditional']!,
          _traditionalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_traditionalMeta);
    }
    if (data.containsKey('pinyin')) {
      context.handle(
        _pinyinMeta,
        pinyin.isAcceptableOrUnknown(data['pinyin']!, _pinyinMeta),
      );
    } else if (isInserting) {
      context.missing(_pinyinMeta);
    }
    if (data.containsKey('definition')) {
      context.handle(
        _definitionMeta,
        definition.isAcceptableOrUnknown(data['definition']!, _definitionMeta),
      );
    } else if (isInserting) {
      context.missing(_definitionMeta);
    }
    if (data.containsKey('pinyin_plain')) {
      context.handle(
        _pinyinPlainMeta,
        pinyinPlain.isAcceptableOrUnknown(
          data['pinyin_plain']!,
          _pinyinPlainMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {simplified, pinyin};
  @override
  DictionaryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DictionaryEntry(
      simplified:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}simplified'],
          )!,
      traditional:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}traditional'],
          )!,
      pinyin:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}pinyin'],
          )!,
      definition:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}definition'],
          )!,
      pinyinPlain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinyin_plain'],
      ),
    );
  }

  @override
  $DictionaryEntriesTable createAlias(String alias) {
    return $DictionaryEntriesTable(attachedDatabase, alias);
  }
}

class DictionaryEntry extends DataClass implements Insertable<DictionaryEntry> {
  final String simplified;
  final String traditional;
  final String pinyin;
  final String definition;
  final String? pinyinPlain;
  const DictionaryEntry({
    required this.simplified,
    required this.traditional,
    required this.pinyin,
    required this.definition,
    this.pinyinPlain,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['simplified'] = Variable<String>(simplified);
    map['traditional'] = Variable<String>(traditional);
    map['pinyin'] = Variable<String>(pinyin);
    map['definition'] = Variable<String>(definition);
    if (!nullToAbsent || pinyinPlain != null) {
      map['pinyin_plain'] = Variable<String>(pinyinPlain);
    }
    return map;
  }

  DictionaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DictionaryEntriesCompanion(
      simplified: Value(simplified),
      traditional: Value(traditional),
      pinyin: Value(pinyin),
      definition: Value(definition),
      pinyinPlain:
          pinyinPlain == null && nullToAbsent
              ? const Value.absent()
              : Value(pinyinPlain),
    );
  }

  factory DictionaryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DictionaryEntry(
      simplified: serializer.fromJson<String>(json['simplified']),
      traditional: serializer.fromJson<String>(json['traditional']),
      pinyin: serializer.fromJson<String>(json['pinyin']),
      definition: serializer.fromJson<String>(json['definition']),
      pinyinPlain: serializer.fromJson<String?>(json['pinyinPlain']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'simplified': serializer.toJson<String>(simplified),
      'traditional': serializer.toJson<String>(traditional),
      'pinyin': serializer.toJson<String>(pinyin),
      'definition': serializer.toJson<String>(definition),
      'pinyinPlain': serializer.toJson<String?>(pinyinPlain),
    };
  }

  DictionaryEntry copyWith({
    String? simplified,
    String? traditional,
    String? pinyin,
    String? definition,
    Value<String?> pinyinPlain = const Value.absent(),
  }) => DictionaryEntry(
    simplified: simplified ?? this.simplified,
    traditional: traditional ?? this.traditional,
    pinyin: pinyin ?? this.pinyin,
    definition: definition ?? this.definition,
    pinyinPlain: pinyinPlain.present ? pinyinPlain.value : this.pinyinPlain,
  );
  DictionaryEntry copyWithCompanion(DictionaryEntriesCompanion data) {
    return DictionaryEntry(
      simplified:
          data.simplified.present ? data.simplified.value : this.simplified,
      traditional:
          data.traditional.present ? data.traditional.value : this.traditional,
      pinyin: data.pinyin.present ? data.pinyin.value : this.pinyin,
      definition:
          data.definition.present ? data.definition.value : this.definition,
      pinyinPlain:
          data.pinyinPlain.present ? data.pinyinPlain.value : this.pinyinPlain,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryEntry(')
          ..write('simplified: $simplified, ')
          ..write('traditional: $traditional, ')
          ..write('pinyin: $pinyin, ')
          ..write('definition: $definition, ')
          ..write('pinyinPlain: $pinyinPlain')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(simplified, traditional, pinyin, definition, pinyinPlain);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DictionaryEntry &&
          other.simplified == this.simplified &&
          other.traditional == this.traditional &&
          other.pinyin == this.pinyin &&
          other.definition == this.definition &&
          other.pinyinPlain == this.pinyinPlain);
}

class DictionaryEntriesCompanion extends UpdateCompanion<DictionaryEntry> {
  final Value<String> simplified;
  final Value<String> traditional;
  final Value<String> pinyin;
  final Value<String> definition;
  final Value<String?> pinyinPlain;
  final Value<int> rowid;
  const DictionaryEntriesCompanion({
    this.simplified = const Value.absent(),
    this.traditional = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.definition = const Value.absent(),
    this.pinyinPlain = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DictionaryEntriesCompanion.insert({
    required String simplified,
    required String traditional,
    required String pinyin,
    required String definition,
    this.pinyinPlain = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : simplified = Value(simplified),
       traditional = Value(traditional),
       pinyin = Value(pinyin),
       definition = Value(definition);
  static Insertable<DictionaryEntry> custom({
    Expression<String>? simplified,
    Expression<String>? traditional,
    Expression<String>? pinyin,
    Expression<String>? definition,
    Expression<String>? pinyinPlain,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (simplified != null) 'simplified': simplified,
      if (traditional != null) 'traditional': traditional,
      if (pinyin != null) 'pinyin': pinyin,
      if (definition != null) 'definition': definition,
      if (pinyinPlain != null) 'pinyin_plain': pinyinPlain,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DictionaryEntriesCompanion copyWith({
    Value<String>? simplified,
    Value<String>? traditional,
    Value<String>? pinyin,
    Value<String>? definition,
    Value<String?>? pinyinPlain,
    Value<int>? rowid,
  }) {
    return DictionaryEntriesCompanion(
      simplified: simplified ?? this.simplified,
      traditional: traditional ?? this.traditional,
      pinyin: pinyin ?? this.pinyin,
      definition: definition ?? this.definition,
      pinyinPlain: pinyinPlain ?? this.pinyinPlain,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (simplified.present) {
      map['simplified'] = Variable<String>(simplified.value);
    }
    if (traditional.present) {
      map['traditional'] = Variable<String>(traditional.value);
    }
    if (pinyin.present) {
      map['pinyin'] = Variable<String>(pinyin.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (pinyinPlain.present) {
      map['pinyin_plain'] = Variable<String>(pinyinPlain.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryEntriesCompanion(')
          ..write('simplified: $simplified, ')
          ..write('traditional: $traditional, ')
          ..write('pinyin: $pinyin, ')
          ..write('definition: $definition, ')
          ..write('pinyinPlain: $pinyinPlain, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SentencePairsTable extends SentencePairs
    with TableInfo<$SentencePairsTable, SentencePair> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SentencePairsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _chineseMeta = const VerificationMeta(
    'chinese',
  );
  @override
  late final GeneratedColumn<String> chinese = GeneratedColumn<String>(
    'chinese',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _englishMeta = const VerificationMeta(
    'english',
  );
  @override
  late final GeneratedColumn<String> english = GeneratedColumn<String>(
    'english',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinyinMeta = const VerificationMeta('pinyin');
  @override
  late final GeneratedColumn<String> pinyin = GeneratedColumn<String>(
    'pinyin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, chinese, english, pinyin];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sentence_pairs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SentencePair> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chinese')) {
      context.handle(
        _chineseMeta,
        chinese.isAcceptableOrUnknown(data['chinese']!, _chineseMeta),
      );
    } else if (isInserting) {
      context.missing(_chineseMeta);
    }
    if (data.containsKey('english')) {
      context.handle(
        _englishMeta,
        english.isAcceptableOrUnknown(data['english']!, _englishMeta),
      );
    } else if (isInserting) {
      context.missing(_englishMeta);
    }
    if (data.containsKey('pinyin')) {
      context.handle(
        _pinyinMeta,
        pinyin.isAcceptableOrUnknown(data['pinyin']!, _pinyinMeta),
      );
    } else if (isInserting) {
      context.missing(_pinyinMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SentencePair map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SentencePair(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      chinese:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}chinese'],
          )!,
      english:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}english'],
          )!,
      pinyin:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}pinyin'],
          )!,
    );
  }

  @override
  $SentencePairsTable createAlias(String alias) {
    return $SentencePairsTable(attachedDatabase, alias);
  }
}

class SentencePair extends DataClass implements Insertable<SentencePair> {
  final int id;
  final String chinese;
  final String english;
  final String pinyin;
  const SentencePair({
    required this.id,
    required this.chinese,
    required this.english,
    required this.pinyin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chinese'] = Variable<String>(chinese);
    map['english'] = Variable<String>(english);
    map['pinyin'] = Variable<String>(pinyin);
    return map;
  }

  SentencePairsCompanion toCompanion(bool nullToAbsent) {
    return SentencePairsCompanion(
      id: Value(id),
      chinese: Value(chinese),
      english: Value(english),
      pinyin: Value(pinyin),
    );
  }

  factory SentencePair.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SentencePair(
      id: serializer.fromJson<int>(json['id']),
      chinese: serializer.fromJson<String>(json['chinese']),
      english: serializer.fromJson<String>(json['english']),
      pinyin: serializer.fromJson<String>(json['pinyin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chinese': serializer.toJson<String>(chinese),
      'english': serializer.toJson<String>(english),
      'pinyin': serializer.toJson<String>(pinyin),
    };
  }

  SentencePair copyWith({
    int? id,
    String? chinese,
    String? english,
    String? pinyin,
  }) => SentencePair(
    id: id ?? this.id,
    chinese: chinese ?? this.chinese,
    english: english ?? this.english,
    pinyin: pinyin ?? this.pinyin,
  );
  SentencePair copyWithCompanion(SentencePairsCompanion data) {
    return SentencePair(
      id: data.id.present ? data.id.value : this.id,
      chinese: data.chinese.present ? data.chinese.value : this.chinese,
      english: data.english.present ? data.english.value : this.english,
      pinyin: data.pinyin.present ? data.pinyin.value : this.pinyin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SentencePair(')
          ..write('id: $id, ')
          ..write('chinese: $chinese, ')
          ..write('english: $english, ')
          ..write('pinyin: $pinyin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chinese, english, pinyin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SentencePair &&
          other.id == this.id &&
          other.chinese == this.chinese &&
          other.english == this.english &&
          other.pinyin == this.pinyin);
}

class SentencePairsCompanion extends UpdateCompanion<SentencePair> {
  final Value<int> id;
  final Value<String> chinese;
  final Value<String> english;
  final Value<String> pinyin;
  const SentencePairsCompanion({
    this.id = const Value.absent(),
    this.chinese = const Value.absent(),
    this.english = const Value.absent(),
    this.pinyin = const Value.absent(),
  });
  SentencePairsCompanion.insert({
    this.id = const Value.absent(),
    required String chinese,
    required String english,
    required String pinyin,
  }) : chinese = Value(chinese),
       english = Value(english),
       pinyin = Value(pinyin);
  static Insertable<SentencePair> custom({
    Expression<int>? id,
    Expression<String>? chinese,
    Expression<String>? english,
    Expression<String>? pinyin,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chinese != null) 'chinese': chinese,
      if (english != null) 'english': english,
      if (pinyin != null) 'pinyin': pinyin,
    });
  }

  SentencePairsCompanion copyWith({
    Value<int>? id,
    Value<String>? chinese,
    Value<String>? english,
    Value<String>? pinyin,
  }) {
    return SentencePairsCompanion(
      id: id ?? this.id,
      chinese: chinese ?? this.chinese,
      english: english ?? this.english,
      pinyin: pinyin ?? this.pinyin,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chinese.present) {
      map['chinese'] = Variable<String>(chinese.value);
    }
    if (english.present) {
      map['english'] = Variable<String>(english.value);
    }
    if (pinyin.present) {
      map['pinyin'] = Variable<String>(pinyin.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SentencePairsCompanion(')
          ..write('id: $id, ')
          ..write('chinese: $chinese, ')
          ..write('english: $english, ')
          ..write('pinyin: $pinyin')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CharacterCardsTable characterCards = $CharacterCardsTable(this);
  late final $DictionaryEntriesTable dictionaryEntries =
      $DictionaryEntriesTable(this);
  late final $SentencePairsTable sentencePairs = $SentencePairsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    characterCards,
    dictionaryEntries,
    sentencePairs,
  ];
}

typedef $$CharacterCardsTableCreateCompanionBuilder =
    CharacterCardsCompanion Function({
      required String character,
      required String pinyin,
      required String definition,
      Value<int> interval,
      Value<int> repetition,
      Value<double> easeFactor,
      Value<int> learningStep,
      Value<DateTime?> nextReview,
      Value<String?> notes,
      Value<String?> pinyinPlain,
      Value<String?> chineseSentence,
      Value<String?> pinyinSentence,
      Value<String?> englishSentence,
      Value<int> rowid,
    });
typedef $$CharacterCardsTableUpdateCompanionBuilder =
    CharacterCardsCompanion Function({
      Value<String> character,
      Value<String> pinyin,
      Value<String> definition,
      Value<int> interval,
      Value<int> repetition,
      Value<double> easeFactor,
      Value<int> learningStep,
      Value<DateTime?> nextReview,
      Value<String?> notes,
      Value<String?> pinyinPlain,
      Value<String?> chineseSentence,
      Value<String?> pinyinSentence,
      Value<String?> englishSentence,
      Value<int> rowid,
    });

class $$CharacterCardsTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterCardsTable> {
  $$CharacterCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetition => $composableBuilder(
    column: $table.repetition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get learningStep => $composableBuilder(
    column: $table.learningStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyinPlain => $composableBuilder(
    column: $table.pinyinPlain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chineseSentence => $composableBuilder(
    column: $table.chineseSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyinSentence => $composableBuilder(
    column: $table.pinyinSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishSentence => $composableBuilder(
    column: $table.englishSentence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CharacterCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterCardsTable> {
  $$CharacterCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetition => $composableBuilder(
    column: $table.repetition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get learningStep => $composableBuilder(
    column: $table.learningStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyinPlain => $composableBuilder(
    column: $table.pinyinPlain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chineseSentence => $composableBuilder(
    column: $table.chineseSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyinSentence => $composableBuilder(
    column: $table.pinyinSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishSentence => $composableBuilder(
    column: $table.englishSentence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharacterCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterCardsTable> {
  $$CharacterCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get character =>
      $composableBuilder(column: $table.character, builder: (column) => column);

  GeneratedColumn<String> get pinyin =>
      $composableBuilder(column: $table.pinyin, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<int> get repetition => $composableBuilder(
    column: $table.repetition,
    builder: (column) => column,
  );

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get learningStep => $composableBuilder(
    column: $table.learningStep,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get pinyinPlain => $composableBuilder(
    column: $table.pinyinPlain,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chineseSentence => $composableBuilder(
    column: $table.chineseSentence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinyinSentence => $composableBuilder(
    column: $table.pinyinSentence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get englishSentence => $composableBuilder(
    column: $table.englishSentence,
    builder: (column) => column,
  );
}

class $$CharacterCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterCardsTable,
          CharacterCard,
          $$CharacterCardsTableFilterComposer,
          $$CharacterCardsTableOrderingComposer,
          $$CharacterCardsTableAnnotationComposer,
          $$CharacterCardsTableCreateCompanionBuilder,
          $$CharacterCardsTableUpdateCompanionBuilder,
          (
            CharacterCard,
            BaseReferences<_$AppDatabase, $CharacterCardsTable, CharacterCard>,
          ),
          CharacterCard,
          PrefetchHooks Function()
        > {
  $$CharacterCardsTableTableManager(
    _$AppDatabase db,
    $CharacterCardsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CharacterCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$CharacterCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CharacterCardsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> character = const Value.absent(),
                Value<String> pinyin = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<int> repetition = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> learningStep = const Value.absent(),
                Value<DateTime?> nextReview = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> pinyinPlain = const Value.absent(),
                Value<String?> chineseSentence = const Value.absent(),
                Value<String?> pinyinSentence = const Value.absent(),
                Value<String?> englishSentence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacterCardsCompanion(
                character: character,
                pinyin: pinyin,
                definition: definition,
                interval: interval,
                repetition: repetition,
                easeFactor: easeFactor,
                learningStep: learningStep,
                nextReview: nextReview,
                notes: notes,
                pinyinPlain: pinyinPlain,
                chineseSentence: chineseSentence,
                pinyinSentence: pinyinSentence,
                englishSentence: englishSentence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String character,
                required String pinyin,
                required String definition,
                Value<int> interval = const Value.absent(),
                Value<int> repetition = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> learningStep = const Value.absent(),
                Value<DateTime?> nextReview = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> pinyinPlain = const Value.absent(),
                Value<String?> chineseSentence = const Value.absent(),
                Value<String?> pinyinSentence = const Value.absent(),
                Value<String?> englishSentence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacterCardsCompanion.insert(
                character: character,
                pinyin: pinyin,
                definition: definition,
                interval: interval,
                repetition: repetition,
                easeFactor: easeFactor,
                learningStep: learningStep,
                nextReview: nextReview,
                notes: notes,
                pinyinPlain: pinyinPlain,
                chineseSentence: chineseSentence,
                pinyinSentence: pinyinSentence,
                englishSentence: englishSentence,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CharacterCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterCardsTable,
      CharacterCard,
      $$CharacterCardsTableFilterComposer,
      $$CharacterCardsTableOrderingComposer,
      $$CharacterCardsTableAnnotationComposer,
      $$CharacterCardsTableCreateCompanionBuilder,
      $$CharacterCardsTableUpdateCompanionBuilder,
      (
        CharacterCard,
        BaseReferences<_$AppDatabase, $CharacterCardsTable, CharacterCard>,
      ),
      CharacterCard,
      PrefetchHooks Function()
    >;
typedef $$DictionaryEntriesTableCreateCompanionBuilder =
    DictionaryEntriesCompanion Function({
      required String simplified,
      required String traditional,
      required String pinyin,
      required String definition,
      Value<String?> pinyinPlain,
      Value<int> rowid,
    });
typedef $$DictionaryEntriesTableUpdateCompanionBuilder =
    DictionaryEntriesCompanion Function({
      Value<String> simplified,
      Value<String> traditional,
      Value<String> pinyin,
      Value<String> definition,
      Value<String?> pinyinPlain,
      Value<int> rowid,
    });

class $$DictionaryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTable> {
  $$DictionaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get simplified => $composableBuilder(
    column: $table.simplified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get traditional => $composableBuilder(
    column: $table.traditional,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyinPlain => $composableBuilder(
    column: $table.pinyinPlain,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DictionaryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTable> {
  $$DictionaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get simplified => $composableBuilder(
    column: $table.simplified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get traditional => $composableBuilder(
    column: $table.traditional,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyinPlain => $composableBuilder(
    column: $table.pinyinPlain,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DictionaryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTable> {
  $$DictionaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get simplified => $composableBuilder(
    column: $table.simplified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get traditional => $composableBuilder(
    column: $table.traditional,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinyin =>
      $composableBuilder(column: $table.pinyin, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
    column: $table.definition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinyinPlain => $composableBuilder(
    column: $table.pinyinPlain,
    builder: (column) => column,
  );
}

class $$DictionaryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DictionaryEntriesTable,
          DictionaryEntry,
          $$DictionaryEntriesTableFilterComposer,
          $$DictionaryEntriesTableOrderingComposer,
          $$DictionaryEntriesTableAnnotationComposer,
          $$DictionaryEntriesTableCreateCompanionBuilder,
          $$DictionaryEntriesTableUpdateCompanionBuilder,
          (
            DictionaryEntry,
            BaseReferences<
              _$AppDatabase,
              $DictionaryEntriesTable,
              DictionaryEntry
            >,
          ),
          DictionaryEntry,
          PrefetchHooks Function()
        > {
  $$DictionaryEntriesTableTableManager(
    _$AppDatabase db,
    $DictionaryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DictionaryEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$DictionaryEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$DictionaryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> simplified = const Value.absent(),
                Value<String> traditional = const Value.absent(),
                Value<String> pinyin = const Value.absent(),
                Value<String> definition = const Value.absent(),
                Value<String?> pinyinPlain = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DictionaryEntriesCompanion(
                simplified: simplified,
                traditional: traditional,
                pinyin: pinyin,
                definition: definition,
                pinyinPlain: pinyinPlain,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String simplified,
                required String traditional,
                required String pinyin,
                required String definition,
                Value<String?> pinyinPlain = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DictionaryEntriesCompanion.insert(
                simplified: simplified,
                traditional: traditional,
                pinyin: pinyin,
                definition: definition,
                pinyinPlain: pinyinPlain,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DictionaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DictionaryEntriesTable,
      DictionaryEntry,
      $$DictionaryEntriesTableFilterComposer,
      $$DictionaryEntriesTableOrderingComposer,
      $$DictionaryEntriesTableAnnotationComposer,
      $$DictionaryEntriesTableCreateCompanionBuilder,
      $$DictionaryEntriesTableUpdateCompanionBuilder,
      (
        DictionaryEntry,
        BaseReferences<_$AppDatabase, $DictionaryEntriesTable, DictionaryEntry>,
      ),
      DictionaryEntry,
      PrefetchHooks Function()
    >;
typedef $$SentencePairsTableCreateCompanionBuilder =
    SentencePairsCompanion Function({
      Value<int> id,
      required String chinese,
      required String english,
      required String pinyin,
    });
typedef $$SentencePairsTableUpdateCompanionBuilder =
    SentencePairsCompanion Function({
      Value<int> id,
      Value<String> chinese,
      Value<String> english,
      Value<String> pinyin,
    });

class $$SentencePairsTableFilterComposer
    extends Composer<_$AppDatabase, $SentencePairsTable> {
  $$SentencePairsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chinese => $composableBuilder(
    column: $table.chinese,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get english => $composableBuilder(
    column: $table.english,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SentencePairsTableOrderingComposer
    extends Composer<_$AppDatabase, $SentencePairsTable> {
  $$SentencePairsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chinese => $composableBuilder(
    column: $table.chinese,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get english => $composableBuilder(
    column: $table.english,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SentencePairsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SentencePairsTable> {
  $$SentencePairsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chinese =>
      $composableBuilder(column: $table.chinese, builder: (column) => column);

  GeneratedColumn<String> get english =>
      $composableBuilder(column: $table.english, builder: (column) => column);

  GeneratedColumn<String> get pinyin =>
      $composableBuilder(column: $table.pinyin, builder: (column) => column);
}

class $$SentencePairsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SentencePairsTable,
          SentencePair,
          $$SentencePairsTableFilterComposer,
          $$SentencePairsTableOrderingComposer,
          $$SentencePairsTableAnnotationComposer,
          $$SentencePairsTableCreateCompanionBuilder,
          $$SentencePairsTableUpdateCompanionBuilder,
          (
            SentencePair,
            BaseReferences<_$AppDatabase, $SentencePairsTable, SentencePair>,
          ),
          SentencePair,
          PrefetchHooks Function()
        > {
  $$SentencePairsTableTableManager(_$AppDatabase db, $SentencePairsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SentencePairsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$SentencePairsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SentencePairsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> chinese = const Value.absent(),
                Value<String> english = const Value.absent(),
                Value<String> pinyin = const Value.absent(),
              }) => SentencePairsCompanion(
                id: id,
                chinese: chinese,
                english: english,
                pinyin: pinyin,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String chinese,
                required String english,
                required String pinyin,
              }) => SentencePairsCompanion.insert(
                id: id,
                chinese: chinese,
                english: english,
                pinyin: pinyin,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SentencePairsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SentencePairsTable,
      SentencePair,
      $$SentencePairsTableFilterComposer,
      $$SentencePairsTableOrderingComposer,
      $$SentencePairsTableAnnotationComposer,
      $$SentencePairsTableCreateCompanionBuilder,
      $$SentencePairsTableUpdateCompanionBuilder,
      (
        SentencePair,
        BaseReferences<_$AppDatabase, $SentencePairsTable, SentencePair>,
      ),
      SentencePair,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CharacterCardsTableTableManager get characterCards =>
      $$CharacterCardsTableTableManager(_db, _db.characterCards);
  $$DictionaryEntriesTableTableManager get dictionaryEntries =>
      $$DictionaryEntriesTableTableManager(_db, _db.dictionaryEntries);
  $$SentencePairsTableTableManager get sentencePairs =>
      $$SentencePairsTableTableManager(_db, _db.sentencePairs);
}
