import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/home_page.dart';
import 'package:flashhanzi/parse.dart';
import 'package:flashhanzi/stroke_order.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart'; // Add this import for FlipCard

class ReviewCharacters extends StatefulWidget {
  const ReviewCharacters({super.key, required this.db});

  final AppDatabase db; // Declare the database instance

  @override
  State<ReviewCharacters> createState() => _ReviewCharactersState();
}

class _ReviewCharactersState extends State<ReviewCharacters> {
  late AppDatabase db; // Declare the database instance
  late Future<List<CharacterCard>> _dueCards;
  late int _currentIndex;
  final TextEditingController _notesController = TextEditingController();
  Future<List<SentencePair>>? _sentencesFuture;
  late Map<String, String> strokeMap;
  bool strokesLoaded = false;
  final ExpansionTileController expansionController = ExpansionTileController();

  bool noMoreCards = false;
  @override
  void initState() {
    super.initState();
    db = widget.db; // Initialize the database instance in initState
    _dueCards = db.getDueCards(); // Call the method without arguments
    _currentIndex = 0; // Initialize the current index to 0
    // bool _flipped = false; // Initialize the flipped state to false
    _dueCards.then((cards) {
      if (cards.isEmpty) {
        setState(() {
          _currentIndex = -1;
        });
      } else {
        setState(() {
          // Initialize _sentencesFuture here after _dueCards is available
          _sentencesFuture = widget.db.findSentencesFor(
            cards[_currentIndex].character,
          );
        });
      }
    });

    _loadData();
  }

  Future<void> _loadData() async {
    // Await the result of the asynchronous loadStrokeData function.
    Map<String, String> dataMap =
        await loadStrokeData(); // Correct use of await
    setState(() {
      strokeMap = dataMap; // Update the strokeMap with the loaded data
      strokesLoaded = true; // Mark strokes as loaded
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure you are fetching the latest notes when navigating back to this page
    _dueCards =
        db.getDueCards(); // Fetch the data again when the page is revisited
  }

  void updateNotes() async {
    final newNotes = _notesController.text;

    final cards = await db.getDueCards();

    // Ensure the current index is valid
    if (_currentIndex < 0 || _currentIndex >= cards.length) {
      return; // Handle out-of-bounds error or invalid index
    }

    // Get the card to update
    final cardToUpdate = cards[_currentIndex];

    // Update the database
    await db.updateNotesDB(cardToUpdate.character, newNotes);
    // Re-fetch the data to ensure the UI is updated
  }

  void updateCard(int grade) async {
    expansionController.collapse();
    //grades : 1 = Forgot, 2 = Hard, 3 = Good, 4 = Easy
    final cards = await db.getDueCards();
    // make currentIndex -1 to show completed cards
    if (cards.isNotEmpty) {
      if (_currentIndex >= cards.length) {
        setState(() {
          _currentIndex = -1;
          noMoreCards = true;
        });
        return;
      }

      // db.updateNextReview(cards[0].character, DateTime.now());

      // Reschedule for the specified number of days
      // Cycle through cards

      if (grade == 1) {
        // If "Forgot" button was pressed
        db.updateNextReview(
          cards[0].character,
          DateTime.now().add(Duration(days: 1)),
        ); // Reschedule for tomorrow
      } else if (grade == 2) {
        // If "Hard" button was pressed
        db.updateNextReview(
          cards[0].character,
          DateTime.now().add(Duration(days: 2)),
        ); // Reschedule for two days later
      } else if (grade == 3) {
        // If "Good" button was pressed
        db.updateNextReview(
          cards[0].character,
          DateTime.now().add(Duration(days: 3)),
        ); // Reschedule for three days later
      } else if (grade == 4) {
        // If "Easy" button was pressed
        db.updateNextReview(
          cards[0].character,
          DateTime.now().add(Duration(days: 4)),
        ); // Reschedule for a week later
      }

      setState(() {
        _currentIndex = _currentIndex + 1;
        _sentencesFuture = widget.db.findSentencesFor(
          cards[_currentIndex].character,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      fill: Fill.fillFront,
      direction: FlipDirection.HORIZONTAL, // or VERTICAL
      speed: 500, // in milliseconds
      front: Card(
        elevation: 4,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 20), // Space at the top
                Stack(
                  alignment: Alignment.center, // Center the text in the Stack
                  children: [
                    Align(
                      alignment:
                          Alignment
                              .centerLeft, // Align the IconButton to the left
                      child: IconButton(
                        icon: const Icon(Icons.home, size: 30),
                        onPressed: () {
                          Navigator.pop(
                            context,
                          ); // Go back to the previous page
                        },
                      ),
                    ),
                    const Text(
                      'Review Characters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32), // Space before the review list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FutureBuilder<List<CharacterCard>>(
                    future: _dueCards,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 84,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            decoration: TextDecoration.none, // Remove underline
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Text(
                          'Error loading data',
                          style: TextStyle(
                            fontSize: 116,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            decoration: TextDecoration.none, // Remove underline
                          ),
                        );
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        try {
                          return Text(
                            snapshot.data![_currentIndex].character,
                            style: const TextStyle(
                              fontSize: 116,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              decoration:
                                  TextDecoration.none, // Remove underline
                            ),
                          );
                        } catch (e) {
                          //change this screen
                          return Center(
                            child: Column(
                              children: [
                                Text(
                                  'Done studying for today!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    decoration:
                                        TextDecoration.none, // Remove underline
                                  ),
                                ),
                                SizedBox(height: 40),

                                ElevatedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Color(0xFFB42F2B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(db: db),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      'Review All Cards',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 28),
                              ],
                            ),
                          );
                        }
                      }
                      return Center(
                        child: Column(
                          children: [
                            SizedBox(height: 32),
                            Text(
                              'Done studying for today!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                decoration:
                                    TextDecoration.none, // Remove underline
                              ),
                            ),
                            SizedBox(height: 40),

                            ElevatedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Color(0xFFB42F2B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(db: db),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  'Review All Cards',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(height: 28),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16), // Space before the review list
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'How well did you remember?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(255, 110, 110, 110),
                      decoration: TextDecoration.none, // Remove underline
                    ),
                  ),
                ),
                SizedBox(height: 16), // Space before the buttons
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center, // Center the buttons horizontally
                  children: [
                    SizedBox(width: 40), // Space before the first button
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 12,
                          bottom: 4,
                        ), // Vertical padding for the button
                        child: ElevatedButton.icon(
                          onPressed: () {
                            updateCard(1);
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ), // Icon on the left
                          label: const Text('Forgot'), // Button text
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Button color
                            foregroundColor: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16), // Space between the buttons
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12, bottom: 4),
                        child: ElevatedButton(
                          onPressed: () {
                            updateCard(2); // Update the card with "Hard" grade
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Button color
                            foregroundColor: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min, // Keep the button compact
                            children: const [
                              Text(
                                '🙁', // Upside-down smiley emoji
                                style: TextStyle(fontSize: 20), // Emoji size
                              ),
                              SizedBox(
                                width: 8,
                              ), // Space between emoji and text
                              Text('Hard'), // Button text
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 40), // Space between the buttons
                  ],
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center, // Center the buttons horizontally
                  children: [
                    SizedBox(width: 40), // Space before the first button
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            updateCard(3); // Update the card with "Good" grade
                          },
                          icon: const Icon(
                            Icons.thumb_up,
                            color: Colors.white,
                          ), // Icon on the left
                          label: const Text('Good'), // Button text
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, // Button color
                            foregroundColor: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16), // Space between the buttons
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          updateCard(4); // Update the card with "Easy" grade
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Button color
                          foregroundColor: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Keep the button compact
                          children: const [
                            Text(
                              '😎', // Upside-down smiley emoji
                              style: TextStyle(fontSize: 20), // Emoji size
                            ),
                            SizedBox(width: 8), // Space between emoji and text
                            Text('Easy'), // Button text
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 40), // Space between the buttons
                  ],
                ),
                SizedBox(height: 24), // Space before the next review character
                Text(
                  '[ Tap to flip ]', // Instruction for tapping to flip
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600], // Lighter color for instruction
                  ),
                ),
                SizedBox(height: 24), // Space before the next review character
                FutureBuilder<List<CharacterCard>>(
                  future: _dueCards, // Your future to fetch the data
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show loading indicator while waiting
                    } else if (snapshot.hasError) {
                      return Text('Error loading data'); // Handle error state
                    } else if (snapshot.hasData) {
                      final cards = snapshot.data!;

                      if (cards.isNotEmpty &&
                          _currentIndex >= 0 &&
                          _currentIndex < cards.length) {
                        final card = cards[_currentIndex];

                        // Set the notesController to the existing notes
                        _notesController.text = card.notes ?? '';
                      }

                      return ListView(
                        shrinkWrap: true,
                        children: [
                          ExpansionTile(
                            title: const Text("Personal Notes"),
                            leading: const Icon(Icons.play_arrow),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                height: 150, // or any size you want
                                child: Center(
                                  child: TextField(
                                    controller: _notesController,
                                    maxLines: 5,
                                    maxLength: 300,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Add your notes here",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  updateNotes();
                                },
                                child: Text('Save Notes'),
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ],
                      );
                    }

                    return SizedBox.shrink(); // Return empty widget if no data
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      back: Card(
        elevation: 4,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 20), // Space at the top
                Stack(
                  alignment: Alignment.center, // Center the text in the Stack
                  children: [
                    Align(
                      alignment:
                          Alignment
                              .centerLeft, // Align the IconButton to the left
                      child: IconButton(
                        icon: const Icon(Icons.home, size: 30),
                        onPressed: () {
                          Navigator.pop(
                            context,
                          ); // Go back to the previous page
                        },
                      ),
                    ),
                    const Text(
                      'Review Characters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4), // Space before the review list
                //inside futurebuilder
                Padding(
                  padding: EdgeInsets.all(0),
                  child: Column(
                    children: [
                      FutureBuilder(
                        future: _dueCards,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 84,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                decoration:
                                    TextDecoration.none, // Remove underline
                              ),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data!.isNotEmpty) {
                            try {
                              return Column(
                                children: [
                                  SizedBox(height: 32),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      bottom: 16,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        bottom: 20,
                                      ), // Add padding inside the container
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color:
                                                Colors.grey, // Underline color
                                            width: 1, // Underline thickness
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(width: 52),
                                          Wrap(
                                            children: [
                                              Text(
                                                snapshot
                                                    .data![_currentIndex]
                                                    .character,
                                                style: TextStyle(
                                                  fontSize: 76,
                                                  color: Colors.black87,
                                                  decoration:
                                                      TextDecoration
                                                          .none, // Remove underline
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(
                                            width: 28,
                                          ), // Space between characters
                                          Wrap(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 12,
                                                ),
                                                child: Text(
                                                  '[${snapshot.data![_currentIndex].pinyin}]',
                                                  style: const TextStyle(
                                                    fontSize: 48,
                                                    color: Colors.black87,
                                                    decoration:
                                                        TextDecoration
                                                            .none, // Remove underline
                                                  ),
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
                                                  doNothing();
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ), // Space before the review list

                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      bottom: 12,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        bottom: 0,
                                      ), // Add padding inside the container

                                      child: Column(
                                        children: [
                                          Wrap(
                                            alignment: WrapAlignment.center,
                                            // crossAxisAlignment:
                                            //     CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Meaning: ${snapshot.data![_currentIndex].definition}',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  color: Color(0xFFB42F2B),
                                                  fontWeight: FontWeight.bold,
                                                  decoration:
                                                      TextDecoration
                                                          .none, // Remove underline
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } catch (e) {
                              //change this screen
                              return Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 32),
                                    Text(
                                      'Done studying for today!',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        decoration:
                                            TextDecoration
                                                .none, // Remove underline
                                      ),
                                    ),
                                    SizedBox(height: 40),

                                    ElevatedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Color(0xFFB42F2B),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => HomePage(db: db),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text(
                                          'Review All Cards',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 28),
                                  ],
                                ),
                              );
                            }
                          } else if (snapshot.hasError) {
                            return const Text(
                              'Error loading data',
                              style: TextStyle(
                                fontSize: 116,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                decoration:
                                    TextDecoration.none, // Remove underline
                              ),
                            );
                          } else {
                            return const Text(
                              'Error loading data',
                              style: TextStyle(
                                fontSize: 116,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                decoration:
                                    TextDecoration.none, // Remove underline
                              ),
                            );
                          }
                        },
                      ),

                      Padding(
                        padding: EdgeInsets.all(0),
                        child: FutureBuilder(
                          future: _sentencesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text(
                                'Loading...',
                                style: TextStyle(
                                  fontSize: 84,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  decoration:
                                      TextDecoration.none, // Remove underline
                                ),
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data!.isNotEmpty) {
                              if (noMoreCards) {
                                return SizedBox(height: 4);
                              }
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 8,
                                    ), // Space between meaning and example
                                    Wrap(
                                      children: [
                                        Text(
                                          'Example: ${snapshot.data![0].chinese}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            decoration:
                                                TextDecoration
                                                    .none, // Remove underline
                                          ),
                                        ),
                                      ],
                                    ),
                                    Wrap(
                                      children: [
                                        Text(
                                          'Pinyin: ${snapshot.data![0].pinyin}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            decoration:
                                                TextDecoration
                                                    .none, // Remove underline
                                          ),
                                        ),
                                        Wrap(
                                          children: [
                                            Text(
                                              "Translation: ${snapshot.data![0].english}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                decoration:
                                                    TextDecoration
                                                        .none, // Remove underline
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),

                                      padding: EdgeInsets.only(bottom: 24),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color:
                                                Colors.grey, // Underline color
                                            width: 1, // Underline thickness
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return const Text(
                                'Error loading data',
                                style: TextStyle(
                                  fontSize: 116,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  decoration:
                                      TextDecoration.none, // Remove underline
                                ),
                              );
                            } else {
                              return const Text(
                                'Error loading data',
                                style: TextStyle(
                                  fontSize: 116,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  decoration:
                                      TextDecoration.none, // Remove underline
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<List<CharacterCard>>(
                  future: _dueCards, // Your future to fetch the data
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show loading indicator while waiting
                    } else if (snapshot.hasError) {
                      return Text('Error loading data'); // Handle error state
                    } else if (snapshot.hasData) {
                      final cards = snapshot.data!;
                      try {
                        return ListView(
                          shrinkWrap: true,
                          children: [
                            strokesLoaded &&
                                    strokeMap.containsKey(
                                      cards[_currentIndex].character,
                                    )
                                ? ExpansionTile(
                                  controller: expansionController,
                                  title: const Text("Stroke Order Animation"),
                                  leading: const Icon(Icons.play_arrow),
                                  children: [
                                    Center(
                                      child: SizedBox(
                                        height: 150,
                                        child:
                                            strokeMap.containsKey(
                                                  cards[_currentIndex]
                                                      .character,
                                                )
                                                ? StrokeOrderWidget(
                                                  character:
                                                      cards[_currentIndex]
                                                          .character,
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
                      } catch (e) {
                        return SizedBox(height: 4);
                      }
                    }

                    return SizedBox.shrink(); // Return empty widget if no data
                  },
                ),
                //stuff after column containing future builder
                SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'How well did you remember?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(255, 59, 59, 59),
                      decoration: TextDecoration.none, // Remove underline
                    ),
                  ),
                ),
                SizedBox(height: 4), // Space before the buttons
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center, // Center the buttons horizontally
                  children: [
                    SizedBox(width: 40), // Space before the first button
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 12,
                          bottom: 4,
                        ), // Vertical padding for the button
                        child: ElevatedButton.icon(
                          onPressed: () {
                            updateCard(1);
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ), // Icon on the left
                          label: const Text('Forgot'), // Button text
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Button color
                            foregroundColor: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16), // Space between the buttons
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12, bottom: 4),
                        child: ElevatedButton(
                          onPressed: () {
                            updateCard(2);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Button color
                            foregroundColor: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min, // Keep the button compact
                            children: const [
                              Text(
                                '🙁', // Upside-down smiley emoji
                                style: TextStyle(fontSize: 20), // Emoji size
                              ),
                              SizedBox(
                                width: 8,
                              ), // Space between emoji and text
                              Text('Hard'), // Button text
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 40), // Space between the buttons
                  ],
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center, // Center the buttons horizontally
                  children: [
                    SizedBox(width: 40), // Space before the first button
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            updateCard(3);
                          },
                          icon: const Icon(
                            Icons.thumb_up,
                            color: Colors.white,
                          ), // Icon on the left
                          label: const Text('Good'), // Button text
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, // Button color
                            foregroundColor: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16), // Space between the buttons
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          updateCard(4);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Button color
                          foregroundColor: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Keep the button compact
                          children: const [
                            Text(
                              '😎', // Upside-down smiley emoji
                              style: TextStyle(fontSize: 20), // Emoji size
                            ),
                            SizedBox(width: 8), // Space between emoji and text
                            Text('Easy'), // Button text
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 40), // Space between the buttons
                  ],
                ),
                SizedBox(height: 16), // Space before the next review character
                Text(
                  '[ Tap to flip ]', // Instruction for tapping to flip
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600], // Lighter color for instruction
                  ),
                ),
                SizedBox(height: 16), // Space before the next review character
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void doNothing() {
  // Placeholder function for button actions
}
