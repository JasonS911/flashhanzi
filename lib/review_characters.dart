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
  State<ReviewCharacters> createState() => ReviewCharactersState();
}

class ReviewCharactersState extends State<ReviewCharacters> {
  late int _currentIndex;
  final TextEditingController _notesController = TextEditingController();
  List<CharacterCard> _cards = [];
  late Future<List<CharacterCard>> _dueCards;
  Future<List<SentencePair>>? _sentencesFuture;
  late Map<String, String> strokeMap;
  bool strokesLoaded = false;
  final ExpansionTileController expansionController = ExpansionTileController();
  bool _initialized = false;

  String? _lastCardCharacter; // keeps track of the previously shown character

  void refreshDueCards() async {
    final cards = await widget.db.getDueCards();

    if (!mounted) return;

    setState(() {
      _cards = cards;
      _currentIndex = cards.isEmpty ? -1 : 0;
      _sentencesFuture =
          cards.isNotEmpty
              ? widget.db.findSentencesFor(cards[0].character)
              : null;
      _dueCards = widget.db.getDueCards();
      _initialized = true;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshDueCards();
    _loadData(); //loads stroke animation data
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

  void updateNotes() async {
    final newNotes = _notesController.text;

    final cards = await widget.db.getDueCards();

    // Ensure the current index is valid
    // if (_currentIndex < 0 || _currentIndex >= cards.length) {
    //   return; // Handle out-of-bounds error or invalid index
    // }
    if (_currentIndex < 0) {
      return; // Handle out-of-bounds error or invalid index
    }
    // Get the card to update
    final cardToUpdate = cards[_currentIndex];

    // Update the database
    await widget.db.updateNotesDB(cardToUpdate.character, newNotes);
    // Re-fetch the data to ensure the UI is updated
  }

  void updateCard(int grade) async {
    //grades : 1 = Forgot, 2 = Hard, 3 = Good, 4 = Easy
    var cards = await widget.db.getDueCards();
    final allCards = await widget.db.select(widget.db.characterCards).get();

    for (final card in allCards) {
      print('Next Review: ${card.nextReview}');
    }
    //currentindex is 1 if cards is empty
    if (_currentIndex == -1) {
      return;
    }
    // make currentIndex -1 to show completed cards
    if (cards.isNotEmpty) {
      // if (_currentIndex >= cards.length) {
      //   setState(() {
      //     _currentIndex = -1;
      //   });
      //   return;
      // }

      // Reschedule for the specified number of days
      // Cycle through cards
      const minEase = 1.3;

      int reps = cards[0].repetition;
      double ease = cards[0].easeFactor;
      int interval = cards[0].interval;

      if (grade < 2) {
        // Forgot
        reps = 0;
        interval = 1; // NEXT REVIEW: Tomorrow
      } else {
        // Remembered
        reps += 1;

        if (reps == 1) {
          interval = 1;
        } else if (reps == 2) {
          interval = 6;
        } else {
          interval = (interval * ease).round();
        }

        // Adjust easeFactor
        final modifier = 0.1 - (4 - grade) * (0.08 + (4 - grade) * 0.02);
        ease += modifier;
        if (ease < minEase) ease = minEase;
      }

      widget.db.updateNextReview(
        cards[0].character,
        reps,
        interval,
        ease,
        DateTime.now().add(Duration(days: interval)),
      ); // Reschedule for tomorrow
      final allCards = await widget.db.select(widget.db.characterCards).get();

      for (final card in allCards) {
        print('Next Review: ${card.nextReview}');
      }
      if (strokeMap.containsKey(cards[0].character)) {
        expansionController.collapse();
      }

      refreshDueCards();
    }
  }

  @override
  Widget build(BuildContext context) {
    CharacterCard? currentCard;
    if (!_initialized) {
      // Still loading
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentIndex >= 0 && _currentIndex < _cards.length) {
      currentCard = _cards[_currentIndex];
    }
    if (_lastCardCharacter != currentCard?.character) {
      _notesController.text = currentCard?.notes ?? '';
      _lastCardCharacter = currentCard?.character;
    }
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
                  child:
                      (_cards.isEmpty || _currentIndex == -1)
                          ? Center(
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
                                        builder:
                                            (context) =>
                                                HomePage(db: widget.db),
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
                          )
                          : Text(
                            currentCard!.character,
                            style: const TextStyle(
                              fontSize: 116,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              decoration:
                                  TextDecoration.none, // Remove underline
                            ),
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
                // Check for valid state
                // if (_cards.isEmpty || _currentIndex == -1) {
                //   return;
                // }

                // Initialize notes if needed
                ListView(
                  shrinkWrap: true,
                  children: [
                    ExpansionTile(
                      title: const Text("Personal Notes"),
                      leading: const Icon(Icons.play_arrow),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          height: 150,
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
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: updateNotes,
                          child: const Text('Save Notes'),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
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
                    children:
                        (_cards.isEmpty || _currentIndex == -1)
                            ? [
                              Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 64),
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
                                                (context) =>
                                                    HomePage(db: widget.db),
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
                              ),
                            ]
                            : [
                              Column(
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
                                                _cards[_currentIndex].character,
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
                                                  '[${_cards[_currentIndex].pinyin}]',
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
                                                'Meaning: ${_cards[_currentIndex].definition}',
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
                              ),
                            ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(0),
                  child: FutureBuilder(
                    future: _sentencesFuture,
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
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        if (_currentIndex == -1) {
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
                                margin: EdgeInsets.symmetric(horizontal: 4),

                                padding: EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey, // Underline color
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
                        return SizedBox(height: 4);
                      } else {
                        return SizedBox(height: 4);
                      }
                    },
                  ),
                ),
                FutureBuilder<List<CharacterCard>>(
                  future: _dueCards, // Your future to fetch the data
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show loading indicator while waiting
                    } else if (snapshot.hasError) {
                      return SizedBox(height: 4); // Handle error state
                    } else if (snapshot.hasData) {
                      final cards = snapshot.data!;
                      try {
                        return ListView(
                          shrinkWrap: true,
                          children: [
                            strokesLoaded &&
                                    strokeMap.containsKey(cards[0].character)
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
                                                  cards[0].character,
                                                )
                                                ? StrokeOrderWidget(
                                                  character: cards[0].character,
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
