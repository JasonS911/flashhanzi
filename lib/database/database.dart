import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'database.g.dart'; // Required for codegen

// Define your table
class CharacterCards extends Table {
  TextColumn get character => text()();
  TextColumn get pinyin => text()();
  TextColumn get definition => text()();
  IntColumn get interval => integer().withDefault(const Constant(1))();
  IntColumn get repetition => integer().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  DateTimeColumn get nextReview => dateTime().nullable()();

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

// Your database class
@DriftDatabase(tables: [CharacterCards, DictionaryEntries])
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
  Future<void> updateNextReview(String character, DateTime newDate) async {
    await (update(characterCards)..where(
      (card) => card.character.equals(character),
    )).write(CharacterCardsCompanion(nextReview: Value(newDate)));
  }

  //development only
  Future<void> resetNextReview(String character) async {
    await (update(characterCards)
      ..where((card) => card.character.equals(character))).write(
      CharacterCardsCompanion(
        nextReview: Value(DateTime.now().subtract(const Duration(days: 1))),
      ),
    );
  }

  // Future<List<DictionaryEntry>> searchDictionary(String input) {
  //   return (select(dictionaryEntries)..where(
  //     (entry) =>
  //         entry.simplified.equals(input) |
  //         entry.traditional.equals(input) |
  //         entry.pinyin.like('%$input%'),
  //   )).get();
  // }

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
                entry.pinyinPlain.like('%$input%'),
          )
          ..orderBy([
            (entry) => OrderingTerm(
              expression: FunctionCallExpression('length', [entry.simplified]),
              mode: OrderingMode.asc,
            ),
            (entry) => OrderingTerm(expression: entry.simplified),
          ])
          ..limit(limit, offset: offset))
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

Future<void> seedTestCards(AppDatabase db) async {
  final existing = await db.select(db.characterCards).get();
  if (existing.isNotEmpty) {
    db.resetNextReview('好');
    db.resetNextReview('学');
    return;
  }

  final cards = [
    CharacterCardsCompanion(
      character: Value('好'),
      pinyin: Value('hǎo'),
      definition: Value('good'),
      nextReview: Value(DateTime.now().subtract(const Duration(days: 1))),
    ),
    CharacterCardsCompanion(
      character: Value('学'),
      pinyin: Value('xué'),
      definition: Value('to study'),
      nextReview: Value(DateTime.now().add(const Duration(days: 1))),
    ),
  ];

  for (final card in cards) {
    await db.into(db.characterCards).insert(card);
  }
}
