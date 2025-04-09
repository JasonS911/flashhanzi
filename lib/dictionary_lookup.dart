import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/home_page.dart';
import 'package:flutter/material.dart';

class DictionaryLookup extends StatefulWidget {
  const DictionaryLookup({super.key, required this.db});
  final AppDatabase db;

  @override
  State<DictionaryLookup> createState() => _DictionaryLookupState();
}

class _DictionaryLookupState extends State<DictionaryLookup> {
  late AppDatabase db;
  final _searchController = TextEditingController();
  late Future<List<DictionaryEntry>> searchResults; // Declare as a list

  @override
  void initState() {
    super.initState();
    db = AppDatabase();
    searchResults = Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // Align items to the top
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center items horizontally
        children: [
          SizedBox(height: 20), // Space at the top
          Stack(
            alignment: Alignment.center, // Center the text in the Stack
            children: [
              Align(
                alignment:
                    Alignment.centerLeft, // Align the IconButton to the left
                child: IconButton(
                  icon: const Icon(Icons.home, size: 30),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage(db: db)),
                    );
                  },
                ),
              ),
              const Text(
                'Dictionary Lookup', // Title of the page
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20), // Space before the input field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40), // Side padding
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 24), // Space before the button
          Container(
            height: 440,
            width: 328,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
            child: FutureBuilder<List<DictionaryEntry>>(
              future: searchResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                } else {
                  final results = snapshot.data!;
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final entry = results[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                entry.simplified,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  decoration:
                                      TextDecoration.none, // Remove underline
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    entry.pinyin, // Pinyin with tone
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFFB42F2B),
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.volume_up,
                                      size: 24,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      // Add functionality to play audio here
                                      print(
                                        "Playing audio for hāo",
                                      ); // Placeholder for audio functionality
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ), // Space between pinyin and definition
                            Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Text(
                                entry.definition,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  decoration:
                                      TextDecoration.none, // Remove underline
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ), // Space between pinyin and definition
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Text(
                                '她是一个好人',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  decoration:
                                      TextDecoration.none, // Remove underline
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ), // Space between pinyin and definition
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Text(
                                'Tā shì yí gè hǎo rén',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  decoration:
                                      TextDecoration.none, // Remove underline
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ), // Space between pinyin and definition
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Text(
                                "Translation: He's studying Chinese",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  decoration:
                                      TextDecoration.none, // Remove underline
                                ),
                              ),
                            ),
                            //placeholder for stroke
                            SizedBox(
                              height: 16,
                            ), // Space before the stroke container
                            Center(
                              child: Container(
                                height: 180,
                                width: 180,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                ), // Space after the button
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),

          SizedBox(height: 16), // Add some space before the button
          ElevatedButton(
            onPressed: () {
              final input = _searchController.text.trim();
              if (input.isEmpty) {
                doNothing();
              } else {
                final results = db.searchDictionary(input);
                setState(() {
                  searchResults =
                      results; // Update the state with the search results
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFB42F2B), // Button color
              foregroundColor: Colors.white, // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // Rounded corners
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Search Word',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ), // Add vertical padding for better touch target
            ),
          ),

          // Add some space after the button
        ],
      ),
    );
  }
}

void doNothing() {
  // This function intentionally does nothing.
  // It can be used as a placeholder for button actions.
}
