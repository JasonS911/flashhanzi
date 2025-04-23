import 'package:flashhanzi/parse.dart';
import 'package:flashhanzi/stroke_order.dart';
import 'package:flutter/material.dart';
import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/home_page.dart';

class DictionaryLookup extends StatefulWidget {
  const DictionaryLookup({super.key, required this.db});
  final AppDatabase db;

  @override
  State<DictionaryLookup> createState() => _DictionaryLookupState();
}

class _DictionaryLookupState extends State<DictionaryLookup> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<DictionaryEntry> results = [];
  int offset = 0;
  final int limit = 20;
  bool isLoading = false;
  bool hasMore = true;

  late Map<String, String> strokeMap;
  bool strokesLoaded = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !isLoading &&
          hasMore) {
        loadMore();
      }
    });

    // Call loadData to fetch stroke data asynchronously
    _loadData();
  }

  //get character stroke data
  Future<void> _loadData() async {
    // Await the result of the asynchronous loadStrokeData function.
    Map<String, String> dataMap =
        await loadStrokeData(); // Correct use of await
    setState(() {
      strokeMap = dataMap; // Update the strokeMap with the loaded data
      strokesLoaded = true; // Mark strokes as loaded
    });
  }

  //get more characters after searching. Search is paginated
  Future<void> loadMore() async {
    final input = _searchController.text.trim();
    if (input.isEmpty) return;

    setState(() => isLoading = true);

    final newResults = await widget.db.searchDictionaryPaginated(
      input,
      limit,
      offset,
    );

    setState(() {
      results.addAll(newResults);
      offset += newResults.length;
      isLoading = false;
      hasMore = newResults.length == limit;
    });
  }

  Future<void> _addNewCard(AppDatabase db, String characterToAdd) async {
    newCard(db, characterToAdd);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Word added to your review deck!'),
        duration: Duration(seconds: 2), // auto-dismiss after 2 seconds
      ),
    );
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
                  'Dictionary Lookup',
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Search Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () async {
                final input = _searchController.text.trim();
                if (input.isEmpty) return;

                setState(() {
                  results = [];
                  offset = 0;
                  hasMore = true;
                });

                await loadMore();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB42F2B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Search Word', style: TextStyle(fontSize: 16)),
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
          ...results.map((entry) => buildResultCard(entry)),

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

  Widget buildResultCard(DictionaryEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.simplified,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.add, size: 30),

                    onPressed: () => _addNewCard(widget.db, entry.simplified),
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
                      print("Playing audio for ${entry.simplified}");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.definition,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<SentencePair>>(
                future: widget.db.findSentencesFor(entry.simplified),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No example sentence found.'),
                        const SizedBox(height: 16),
                        strokesLoaded && strokeMap.containsKey(entry.simplified)
                            ? ExpansionTile(
                              title: const Text("Stroke Animation"),
                              leading: const Icon(Icons.play_arrow),
                              children: [
                                Center(
                                  child: SizedBox(
                                    height: 150,
                                    child:
                                        strokeMap.containsKey(entry.simplified)
                                            ? StrokeOrderWidget(
                                              character: entry.simplified,
                                              dataMap: strokeMap,
                                            ) // Pass the character to the widget
                                            : SizedBox.shrink(),
                                  ),
                                ),
                              ],
                            )
                            : const SizedBox.shrink(), // return nothing
                      ],
                    );
                  } else {
                    final sentence = snapshot.data!.first;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Text(
                            "Sentence: ${sentence.chinese}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Text(
                            "Pinyin: ${sentence.pinyin}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: Text(
                            "Translation: ${sentence.english}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        strokesLoaded && strokeMap.containsKey(entry.simplified)
                            ? ExpansionTile(
                              title: const Text("Stroke Animation"),
                              leading: const Icon(Icons.play_arrow),
                              children: [
                                Center(
                                  child: SizedBox(
                                    height: 150,
                                    child:
                                        strokeMap.containsKey(entry.simplified)
                                            ? StrokeOrderWidget(
                                              character: entry.simplified,
                                              dataMap: strokeMap,
                                            ) // Pass the character to the widget
                                            : SizedBox.shrink(),
                                  ),
                                ),
                              ],
                            )
                            : const SizedBox.shrink(), // return nothing
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
