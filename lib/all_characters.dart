import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/dictionary_lookup.dart';
import 'package:flashhanzi/edit.dart';
import 'package:flashhanzi/utils/play_audio.dart';
import 'package:flutter/material.dart';
import 'package:flashhanzi/home_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AllCharacters extends StatefulWidget {
  const AllCharacters({super.key, required this.db});
  final AppDatabase db;
  @override
  State<AllCharacters> createState() => _AllCharactersState();
}

class _AllCharactersState extends State<AllCharacters> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<CharacterCard> results = [];
  int offset = 0;
  final int limit = 20;
  bool isLoading = false;
  bool hasMore = true;

  late Map<String, String> strokeMap;
  bool strokesLoaded = false;
  @override
  void initState() {
    super.initState();
    loadMore();
    _searchController.addListener(() {
      _onSearchChanged();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !isLoading &&
          hasMore) {
        loadMore();
      }
    });
  }

  void _onSearchChanged() {
    if (isLoading) return;

    setState(() {
      results.clear();
      offset = 0;
      hasMore = true;
    });
    loadMore(); // Only load once per typing pause
  }

  //get more characters after searching. Search is paginated
  Future<void> loadMore() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final input = _searchController.text.trim().replaceAll(' ', '');
    List<CharacterCard> newResults = [];
    if (input.isEmpty) {
      newResults = await widget.db.getAllCharacterCardPaginated(limit, offset);
    } else {
      newResults = await widget.db.searchCharacterCardPaginated(
        input,
        limit,
        offset,
      );
    }

    setState(() {
      results.addAll(newResults);
      offset += newResults.length;
      isLoading = false;
      hasMore = newResults.length == limit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          // Home Button + Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.home, size: 30),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(db: widget.db),
                        ),
                      );
                    },
                  ),
                ),
                const Text(
                  'Personal Dictionary',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextField(
              controller: _searchController,
              onChanged: (value) async {
                setState(() {
                  results = [];
                  offset = 0;
                  hasMore = true;
                });
                await loadMore(); // Call loadMore every time the user types
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // No Results
          if (results.isEmpty && !isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No results found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),

          // Loading Indicator
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),

          // Search Results
          ...results.map(
            (entry) => GestureDetector(
              onLongPress: () {
                _showWordOptions(context, entry.character);
              },
              child: buildResultCardAll(entry),
            ),
          ),
        ],
      ),
    );
  }

  void _showWordOptions(BuildContext context, String word) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.search),
              title: Text('Search "$word"'),
              onTap: () {
                Navigator.pop(context); // Close the modal
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => DictionaryLookup(
                          db: widget.db,
                          prefillSearch: word,
                        ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteCardFromAll(String character) async {
    widget.db.deleteCard(character);
    setState(() {
      results.removeWhere((entry) => entry.character == character);
    });
  }

  Widget buildResultCardAll(CharacterCard entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            //edit
            SlidableAction(
              onPressed: (context) async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditCardPage(db: widget.db, card: entry),
                  ),
                );

                if (result == true) {
                  // Refresh the list
                  _onSearchChanged();
                }
              },
              backgroundColor: const Color.fromARGB(255, 214, 214, 214),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              icon: Icons.edit,
              label: 'Edit',
            ),

            SlidableAction(
              onPressed:
                  (context) async => await deleteCardFromAll(entry.character),

              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          // decoration: BoxDecoration(
          //   border: Border(bottom: BorderSide(color: Colors.grey, width: 2)),
          // ),
          // ignore: sized_box_for_whitespace
          child: Container(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  entry.character,
                  style: TextStyle(
                    fontSize: entry.character.length >= 4 ? 24 : 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '[${entry.pinyin}]',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFB42F2B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: IconButton(
                            icon: const Icon(
                              Icons.volume_up,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              playAudio(entry.character);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
