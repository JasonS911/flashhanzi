import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flashhanzi/database/database.dart';

void main() async {
  final db = AppDatabase();
  final file = File('assets/cedict_ts.u8'); // or wherever you placed the file

  if (!await file.exists()) {
    return;
  }

  final lines = await file.readAsLines();

  int inserted = 0;

  for (final line in lines) {
    if (line.startsWith('#')) continue; // skip comments

    final match = RegExp(
      r'^(\S+)\s+(\S+)\s+\[(.+?)\]\s+/(.+)/$',
    ).firstMatch(line);
    if (match != null) {
      final simplified = match.group(1)!;
      final traditional = match.group(2)!;
      final pinyin = match.group(3)!;
      final definitions = match.group(4)!.replaceAll('/', '; ').trim();

      try {
        await db
            .into(db.dictionaryEntries)
            .insert(
              DictionaryEntriesCompanion(
                simplified: Value(simplified),
                traditional: Value(traditional),
                pinyin: Value(pinyin),
                definition: Value(definitions),
              ),
            );
        inserted++;
      } catch (e) {
        // Avoid duplicates or invalid inserts
        print(e);
      }
    }
  }

  print('Inserted $inserted entries.');
}
