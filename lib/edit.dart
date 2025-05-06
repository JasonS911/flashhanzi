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

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _pinyinController = TextEditingController(text: widget.card.pinyin);
    _definitionController = TextEditingController(text: widget.card.definition);
    _notesController = TextEditingController(text: widget.card.notes ?? '');
  }

  @override
  void dispose() {
    _pinyinController.dispose();
    _definitionController.dispose();
    _notesController.dispose();
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
        pinyin: drift.Value(_pinyinController.text),
        definition: drift.Value(_definitionController.text),
      ),
    );

    setState(() {
      _isSaving = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Card updated successfully!")));
    Navigator.pop(context);
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
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Card")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                decoration: const InputDecoration(labelText: "Pinyin"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _definitionController,
                decoration: const InputDecoration(labelText: "Definition"),
                maxLines: null,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: "Notes"),
                maxLines: null,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    child:
                        _isSaving
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text("Save Changes"),
                  ),
                  TextButton(
                    onPressed: _deleteCard,
                    child: const Text(
                      "Delete Card",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
