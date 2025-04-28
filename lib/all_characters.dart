import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/utils/play_audio.dart';
import 'package:flutter/material.dart';
import 'package:flashhanzi/home_page.dart';

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

          // Search Results
          ...results.map((entry) => buildResultCardAll(entry)),

          // Loading Indicator
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget buildResultCardAll(CharacterCard entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.character,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.pinyin,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB42F2B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.volume_up,
                      size: 24,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      playAudio(entry.character);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
