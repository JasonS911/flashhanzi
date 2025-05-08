import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flashhanzi/database/database.dart';

class EditCardPage extends StatefulWidget {
  final CharacterCard card;
  final AppDatabase db;

  const EditCardPage({super.key, required this.card, required this.db});

  @override
  State<EditCardPage> createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> {
  late TextEditingController _pinyinController;
  late TextEditingController _definitionController;
  late TextEditingController _notesController;
  late TextEditingController _chineseSController;
  late TextEditingController _pinyinSController;
  late TextEditingController _englishSController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _pinyinController = TextEditingController(text: widget.card.pinyin);
    _definitionController = TextEditingController(text: widget.card.definition);
    _notesController = TextEditingController(text: widget.card.notes ?? '');
    _chineseSController = TextEditingController(
      text: widget.card.chineseSentence ?? '',
    );
    _pinyinSController = TextEditingController(
      text: widget.card.pinyinSentence ?? '',
    );
    _englishSController = TextEditingController(
      text: widget.card.englishSentence ?? '',
    );
  }

  @override
  void dispose() {
    _pinyinController.dispose();
    _definitionController.dispose();
    _notesController.dispose();
    _chineseSController.dispose();
    _pinyinSController.dispose();
    _englishSController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    await widget.db.updateNotesDB(widget.card.character, _notesController.text);

    await (widget.db.update(widget.db.characterCards)
      ..where((tbl) => tbl.character.equals(widget.card.character))).write(
      CharacterCardsCompanion(
        pinyin: drift.Value(_pinyinController.text.trim()),
        definition: drift.Value(_definitionController.text.trim()),
        chineseSentence: drift.Value(_chineseSController.text.trim()),
        pinyinSentence: drift.Value(_pinyinSController.text.trim()),
        englishSentence: drift.Value(_englishSController.text.trim()),
      ),
    );

    setState(() {
      _isSaving = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Card updated successfully!")));
    Navigator.pop(context, true);
  }

  Future<void> _deleteCard() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Card"),
            content: const Text("Are you sure you want to delete this card?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm ?? false) {
      await widget.db.deleteCard(widget.card.character);
      if (!mounted) return;
      Navigator.pop(context, true); // return true to caller
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Card")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Text(
                  widget.card.character,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _pinyinController,
                  decoration: const InputDecoration(
                    labelText: "Pinyin",
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _definitionController,
                  decoration: const InputDecoration(
                    labelText: "Definition",
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: "Notes",
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _chineseSController,
                  decoration: const InputDecoration(
                    labelText: "Chinese Sentence",
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _pinyinController,
                  decoration: const InputDecoration(
                    labelText: "Pinyin Sentence",
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _englishSController,
                  decoration: const InputDecoration(
                    labelText: "English Sentence",
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 29),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _deleteCard,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Delete Card',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveChanges,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB42F2B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child:
                                _isSaving
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text("Save Changes"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
