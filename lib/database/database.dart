import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'database.g.dart'; // Required for codegen

// Define your table
class CharacterCards extends Table {
  TextColumn get character => text()();
  TextColumn get pinyin => text()();
  TextColumn get definition => text()();
  IntColumn get interval => // Days between reviews
      integer().withDefault(
        const Constant(1),
      )(); //interval = previousInterval * easeFactor;
  IntColumn get repetition =>
      integer().withDefault(
        const Constant(0),
      )(); // How many times you've remembered this card in a row
  RealColumn get easeFactor => // How easy this card is for you (default: 2.5)
      real().withDefault(
        const Constant(2.5),
      )(); //interval = previousInterval * easeFactor;
  IntColumn get learningStep =>
      integer().withDefault(
        const Constant(0),
      )(); //if something has been learned or not. 1 is 1min 2 is 10 min 3 is graduated
  DateTimeColumn get nextReview => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get pinyinPlain => text().nullable()();
  //sentence pairs
  TextColumn get chineseSentence => text().nullable()();
  TextColumn get pinyinSentence => text().nullable()();
  TextColumn get englishSentence => text().nullable()();
  @override
  Set<Column> get primaryKey => {character};
}

class DictionaryEntries extends Table {
  TextColumn get simplified => text()();
  TextColumn get traditional => text()();
  TextColumn get pinyin => text()();
  TextColumn get definition => text()();
  TextColumn get pinyinPlain => text().nullable()();

  @override
  Set<Column> get primaryKey => {simplified, pinyin};
}

class SentencePairs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get chinese => text()();
  TextColumn get english => text()();
  TextColumn get pinyin => text()();
}

// Your database class
@DriftDatabase(tables: [CharacterCards, DictionaryEntries, SentencePairs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Method to get due cards
  Future<List<CharacterCard>> getDueCards() {
    return (select(characterCards)..where(
      (card) => card.nextReview.isSmallerThanValue(DateTime.now()),
    )).get();
  }

  // Method to update the nextReview field for a specific card
  Future<void> updateNextReview(
    String character,
    int newRepetition,
    int newInterval,
    double newEasefactor,
    DateTime newDate,
    int step,
  ) async {
    await (update(characterCards)
      ..where((card) => card.character.equals(character))).write(
      CharacterCardsCompanion(
        repetition: Value(newRepetition),
        interval: Value(newInterval),
        easeFactor: Value(newEasefactor),
        nextReview: Value(newDate),
        learningStep: Value(step),
      ),
    );
  }

  Future<void> deleteCard(String character) async {
    await (delete(characterCards)
      ..where((tbl) => tbl.character.equals(character))).go();
  }

  Future<void> updateNotesDB(String character, String newNotes) async {
    await (update(characterCards)..where(
      (card) => card.character.equals(character),
    )).write(CharacterCardsCompanion(notes: Value(newNotes)));
  }

  //search for specific character
  Future<List<DictionaryEntry>> searchDictionary(String input) {
    return (select(dictionaryEntries)..where(
      (entry) =>
          entry.simplified.equals(input) | entry.traditional.equals(input),
    )).get();
  }

  //used for personal dictionary page
  Future<List<CharacterCard>> getAllCharacterCardPaginated(
    int limit,
    int offset,
  ) {
    return (select(characterCards)
          ..orderBy([
            (entry) => OrderingTerm(
              expression: FunctionCallExpression('length', [entry.character]),
              mode: OrderingMode.asc,
            ),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<List<CharacterCard>> searchCharacterCardPaginated(
    String input,
    int limit,
    int offset,
  ) {
    return (select(characterCards)
          ..where(
            (entry) =>
                entry.character.equals(input) |
                entry.pinyin.like('%$input%') |
                entry.pinyinPlain.like('%$input%'),
          )
          ..orderBy([
            (entry) => OrderingTerm(
              expression: FunctionCallExpression('length', [entry.character]),
              mode: OrderingMode.asc,
            ),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  //search dictionary page search
  Future<List<DictionaryEntry>> searchDictionaryPaginated(
    String input,
    int limit,
    int offset,
  ) {
    return (select(dictionaryEntries)
          ..where(
            (entry) =>
                entry.simplified.equals(input) |
                entry.traditional.equals(input) |
                entry.pinyin.like('%$input%') |
                entry.pinyinPlain.like('%$input%'), //removes accents
          )
          ..orderBy([
            (entry) => OrderingTerm(
              expression: FunctionCallExpression('length', [entry.simplified]),
              mode: OrderingMode.asc,
            ),
            // Order by exact matches for 'pinyin'
            (entry) => OrderingTerm(
              expression:
                  entry.pinyinPlain
                      .equals(input)
                      .cast<int>(), // 1 for exact match, 0 for non-match
              mode: OrderingMode.desc, // Exact matches come first
            ),
            // Order by exact matches for 'simplified' first
            (entry) => OrderingTerm(
              expression:
                  entry.simplified
                      .equals(input)
                      .cast<int>(), // 1 for exact match, 0 for non-match
              mode: OrderingMode.desc, // Exact matches come first
            ),

            (entry) => OrderingTerm(expression: entry.simplified),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<List<SentencePair>> findSentencesFor(String word) {
    return (select(sentencePairs)
          ..where((tbl) => tbl.chinese.like('%$word%'))
          ..limit(1))
        .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'flashhanzi.sqlite'));
    return NativeDatabase(file);
  });
}

Future<void> newCard(AppDatabase db, String character) async {
  final entry = await lookupCharacter(db, character);
  //theoretically should not trigger
  if (entry == null) {
    return;
  }
  final sentencePair = await db.findSentencesFor(character);
  final sentence = sentencePair.isNotEmpty ? sentencePair.first : null;

  final card = CharacterCardsCompanion(
    character: Value(character),
    pinyin: Value(entry.pinyin),
    definition: Value(entry.definition),
    nextReview: Value(DateTime.now().add(const Duration(days: 0))),
    pinyinPlain: Value(entry.pinyinPlain),
    chineseSentence: Value(sentence?.chinese ?? ''),
    pinyinSentence: Value(sentence?.pinyin ?? ''),
    englishSentence: Value(sentence?.english ?? ''),
  );

  await db.into(db.characterCards).insertOnConflictUpdate(card);
}

Future<void> newCardFromWotd(
  AppDatabase db,
  String character,
  String pinyinWord,
  String definitionWord,
  String? chineseS,
  String? pinyinS,
  String? englishS,
) async {
  final entry = await lookupCharacter(db, character);
  //theoretically should not trigger
  if (entry == null) {
    return;
  }

  final card = CharacterCardsCompanion(
    character: Value(character),
    pinyin: Value(pinyinWord),
    definition: Value(definitionWord),
    nextReview: Value(DateTime.now().add(const Duration(days: 0))),
    pinyinPlain: Value(entry.pinyinPlain),
    chineseSentence: Value(chineseS ?? ''),
    pinyinSentence: Value(pinyinS ?? ''),
    englishSentence: Value(englishS ?? ''),
  );

  await db.into(db.characterCards).insertOnConflictUpdate(card);
}

Future<DictionaryEntry?> lookupCharacter(
  AppDatabase db,
  String character,
) async {
  final query =
      db.select(db.dictionaryEntries)
        ..where((entry) => entry.simplified.equals(character))
        ..limit(1);

  final result = await query.getSingleOrNull();
  return result;
}
