import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flashhanzi/database/database.dart';
import 'package:pinyin/pinyin.dart';

Future<void> parse(AppDatabase db) async {
  final file = File('lib/assets/cedict_ts.u8'); // File path
  final fileSentences = File('lib/assets/ch_eng_pairs.tsv'); // File path

  if (!await file.exists() || !await fileSentences.exists()) {
    print('File not found.');
    return;
  }

  final lines = await file.readAsLines();
  final linesSentences = await fileSentences.readAsLines();

  // Collect all rows to insert
  final List<DictionaryEntriesCompanion> entries = [];
  final List<SentencePairsCompanion> sentencePairs = [];

  for (final line in linesSentences) {
    final parts = line.split('\t');
    if (parts.length >= 4) {
      final chinese = parts[1].trim();
      final english = parts[3].trim();

      sentencePairs.add(
        SentencePairsCompanion(
          chinese: Value(chinese),
          english: Value(english),
          pinyin: Value(PinyinHelper.getPinyin(chinese)),
        ),
      );
    }
  }

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
      final pinYinPlain = normalizePinyin(pinyin);
      final definitions = match.group(4)!.replaceAll('/', '; ').trim();

      entries.add(
        DictionaryEntriesCompanion(
          simplified: Value(simplified),
          traditional: Value(traditional),
          pinyin: Value(pinyin),
          pinyinPlain: Value(pinYinPlain),
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
    batch.insertAll(
      db.sentencePairs,
      sentencePairs,
      mode: InsertMode.insertOrIgnore,
    );
  });
}

String normalizePinyin(String input) {
  final toneMap = {'1': '', '2': '', '3': '', '4': '', '5': ''};

  return input
      .replaceAllMapped(RegExp(r'\d'), (m) => toneMap[m.group(0)]!)
      .replaceAll(' ', '')
      .toLowerCase();
}
