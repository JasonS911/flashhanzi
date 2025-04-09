import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flashhanzi/database/database.dart';

Future<void> parse(AppDatabase db) async {
  final file = File('lib/assets/cedict_ts.u8'); // File path

  if (!await file.exists()) {
    print('File not found.');
    return;
  }

  final lines = await file.readAsLines();

  int inserted = 0;

  // Collect all rows to insert
  final List<DictionaryEntriesCompanion> entries = [];

  for (final line in lines) {
    if (line.startsWith('#')) continue; // Skip comments

    final match = RegExp(
      r'^(.+?)\s+(.+?)\s+\[(.+?)\]\s+/(.+)/$',
    ).firstMatch(line);

    if (match != null) {
      final traditional = match.group(1)!.trim();

      if (traditional.contains(RegExp(r'[A-Za-z]'))) continue;

      final simplified = match.group(2)!.trim();

      if (simplified.contains(RegExp(r'[A-Za-z]'))) continue;

      final pinyin = match.group(3)!.trim();
      final definitions = match.group(4)!.replaceAll('/', '; ').trim();

      entries.add(
        DictionaryEntriesCompanion(
          simplified: Value(simplified),
          traditional: Value(traditional),
          pinyin: Value(pinyin),
          definition: Value(definitions),
        ),
      );
    }
  }

  // Perform batch insert
  await db.batch((batch) {
    batch.insertAll(
      db.dictionaryEntries,
      entries,
      mode: InsertMode.insertOrIgnore,
    );
  });

  inserted = entries.length;
  print('Inserted $inserted entries.');
}
