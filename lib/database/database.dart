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

// Your database class
@DriftDatabase(tables: [CharacterCards])
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
      (tbl) => tbl.character.equals(character),
    )).write(CharacterCardsCompanion(nextReview: Value(newDate)));
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
  if (existing.isNotEmpty) return;
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
