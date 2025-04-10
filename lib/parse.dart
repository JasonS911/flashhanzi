import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flashhanzi/database/database.dart';
import 'package:pinyin/pinyin.dart';
import 'dart:convert';

Future<void> parse(AppDatabase db) async {
  final filePreClean = await rootBundle.loadString(
    'assets/cedict_ts.u8',
  ); // File path
  final file = filePreClean.replaceAll('\r', '').replaceAll('\uFEFF', '');

  final fileSentences = await rootBundle.loadString(
    'assets/ch_eng_pairs.tsv',
  ); // File path

  if (file.isEmpty || fileSentences.isEmpty) {
    print('File content is empty.');
    return;
  }

  final lines = file.split('\n');
  final linesSentences = fileSentences.split('\n');

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

      // if (traditional.contains(RegExp(r'[A-Za-z]'))) continue;

      final simplified = match.group(2)!.trim();

      // if (simplified.contains(RegExp(r'[A-Za-z]'))) continue;

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

class StrokeData {
  final String character;
  final List<String> strokes;

  StrokeData({required this.character, required this.strokes});

  factory StrokeData.fromJson(Map<String, dynamic> json) {
    return StrokeData(
      character: json['character'],
      strokes: List<String>.from(json['strokes']),
    );
  }
}

Future<Map<String, StrokeData>> loadStrokeData() async {
  final raw = await rootBundle.loadString('assets/graphics.txt');
  final lines = raw.split('\n');
  final Map<String, StrokeData> map = {};

  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    final jsonData = json.decode(line);
    final strokeData = StrokeData.fromJson(jsonData);
    map[strokeData.character] = strokeData;
  }

  return map;
}
