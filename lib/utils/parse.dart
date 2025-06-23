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
    return;
  }

  final lines = file.split('\n');
  final linesSentences = fileSentences.split('\n');

  // Collect all rows to insert
  final List<DictionaryEntriesCompanion> entries = [];
  final List<SentencePairsCompanion> sentencePairs = [];

  // for (final line in linesSentences) {
  //   final parts = line.split('\t');
  //   if (parts.length >= 4) {
  //     final chinese = parts[1].trim();
  //     final english = parts[3].trim();

  //     sentencePairs.add(
  //       SentencePairsCompanion(
  //         chinese: Value(chinese),
  //         english: Value(english),
  //         pinyin: Value(PinyinHelper.getPinyin(chinese)),
  //       ),
  //     );
  //   }
  // }
  for (int i = 0; i < linesSentences.length; i++) {
    final line = linesSentences[i];
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

    // Let UI breathe every 500 lines
    if (i % 400 == 0) {
      await Future.delayed(Duration(milliseconds: 10));
    }
  }

  // for (final line in lines) {
  //   if (line.startsWith('#')) continue; // Skip comments

  //   final match = RegExp(
  //     r'^(.+?)\s+(.+?)\s+\[(.+?)\]\s+/(.+)/$',
  //   ).firstMatch(line);

  //   if (match != null) {
  //     final traditional = match.group(1)!.trim();

  //     // if (traditional.contains(RegExp(r'[A-Za-z]'))) continue;

  //     final simplified = match.group(2)!.trim();

  //     // if (simplified.contains(RegExp(r'[A-Za-z]'))) continue;

  //     final pinyin = match.group(3)!.trim();
  //     final pinYinPlain = normalizePinyin(pinyin);
  //     final definitions = match.group(4)!.replaceAll('/', '; ').trim();

  //     //skip surname entries
  //     final lowerDef = definitions.toLowerCase();
  //     final isCapitalPinyin = pinyin[0].toUpperCase() == pinyin[0];
  //     final isUnwanted = lowerDef.contains('surname') && isCapitalPinyin;

  //     if (isUnwanted) continue;
  //     entries.add(
  //       DictionaryEntriesCompanion(
  //         simplified: Value(simplified),
  //         traditional: Value(traditional),
  //         pinyin: Value(pinyin),
  //         pinyinPlain: Value(pinYinPlain),
  //         definition: Value(definitions),
  //       ),
  //     );
  //   }
  // }
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.startsWith('#')) continue;

    final match = RegExp(
      r'^(.+?)\s+(.+?)\s+\[(.+?)\]\s+/(.+)/$',
    ).firstMatch(line);

    if (match != null) {
      final traditional = match.group(1)!.trim();
      final simplified = match.group(2)!.trim();
      final pinyin = match.group(3)!.trim();
      final pinYinPlain = normalizePinyin(pinyin);
      // final definitions = match.group(4)!.replaceAll('/', '; ').trim();
      final rawDefs = match.group(4)!;
      final defParts = rawDefs.split('/')..removeWhere((e) => e.trim().isEmpty);

      // Keep only the first 3 parts
      final limitedDefs = defParts.take(3).join('\n').trim();
      final definitions = limitedDefs;

      final lowerDef = definitions.toLowerCase();
      final isCapitalPinyin = pinyin[0].toUpperCase() == pinyin[0];
      final isUnwanted = lowerDef.contains('surname') && isCapitalPinyin;

      if (isUnwanted) continue;

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

    // Let UI breathe every 400 lines
    if (i % 400 == 0) {
      await Future.delayed(Duration(milliseconds: 10));
    }
  }

  // Perform batch insert
  // await db.batch((batch) {
  //   batch.insertAll(
  //     db.dictionaryEntries,
  //     entries,
  //     mode: InsertMode.insertOrIgnore,
  //   );
  //   batch.insertAll(
  //     db.sentencePairs,
  //     sentencePairs,
  //     mode: InsertMode.insertOrIgnore,
  //   );
  // });

  const int batchSize = 300;

  for (int i = 0; i < entries.length; i += batchSize) {
    final batchEntries = entries.skip(i).take(batchSize).toList();
    await db.batch((batch) {
      batch.insertAll(
        db.dictionaryEntries,
        batchEntries,
        mode: InsertMode.insertOrIgnore,
      );
    });
    await Future.delayed(Duration(milliseconds: 10)); // Yield to UI
  }

  for (int i = 0; i < sentencePairs.length; i += batchSize) {
    final batchSentences = sentencePairs.skip(i).take(batchSize).toList();
    await db.batch((batch) {
      batch.insertAll(
        db.sentencePairs,
        batchSentences,
        mode: InsertMode.insertOrIgnore,
      );
    });
    await Future.delayed(Duration(milliseconds: 10)); // Yield to UI
  }
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

  // Keep this method for parsing the JSON data later if needed
  factory StrokeData.fromJson(Map<String, dynamic> json) {
    return StrokeData(
      character: json['character'],
      strokes: List<String>.from(json['strokes']),
    );
  }

  // Add a method to get the JSON string for future reference if necessary
  String toJson() {
    return '{"character": "$character", "strokes": ${strokes.toString()}}';
  }
}

Future<Map<String, String>> loadStrokeData() async {
  final raw = await rootBundle.loadString('assets/graphics.txt');
  final lines = raw.split('\n');
  final Map<String, String> map = {};

  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    final jsonData = json.decode(
      line,
    ); // Parse the JSON string to a Dart object (if needed)
    final character =
        jsonData['character']; // Get the character from the parsed JSON
    map[character] =
        line; // Store the raw JSON string (the entire line) in the map
  }

  return map;
}

String? getStrokesForCharacter(
  String character,
  Map<String, String> strokeDataMap,
) {
  final strokeDataJson = strokeDataMap[character];

  if (strokeDataJson != null) {
    return strokeDataJson; // Return the raw JSON string for the character
  } else {
    return null; // Return null if the character is not found
  }
}
