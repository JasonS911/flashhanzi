import 'package:flashhanzi/all_characters.dart';
import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/edit.dart';
import 'package:flashhanzi/home_page.dart';
import 'package:flashhanzi/utils/parse.dart';
import 'package:flashhanzi/utils/stroke_order.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart'; // Add this import for FlipCard
import 'package:flashhanzi/utils/play_audio.dart';

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
  late Map<String, String> strokeMap;
  bool strokesLoaded = false;
  final ExpansibleController expansionController = ExpansibleController();
  bool _initialized = false;

  String? _lastCardCharacter; // keeps track of the previously shown character

  //grabs new cards
  void refreshDueCards() async {
    final cards = await widget.db.getDueCards();

    if (!mounted) return;

    setState(() {
      _cards = cards;
      _currentIndex = cards.isEmpty ? -1 : 0;
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

    if (_currentIndex < 0) {
      return; // Handle out-of-bounds error or invalid index
    }
    // Get the card to update
    final cardToUpdate = _cards[_currentIndex];

    // Update the database
    await widget.db.updateNotesDB(cardToUpdate.character, newNotes);
    // Re-fetch the data to ensure the UI is updated
  }

  void updateCard(int grade) async {
    //grades : 1 = Forgot, 2 = Hard, 3 = Good, 4 = Easy
    // make currentIndex -1 to show completed cards
    if (_cards.isNotEmpty) {
      // Reschedule for the specified number of days
      // Cycle through cards
      const minEase = 1.3;

      int reps = _cards[_currentIndex].repetition;
      double ease = _cards[_currentIndex].easeFactor;
      int interval = _cards[_currentIndex].interval;
      int step = _cards[_currentIndex].learningStep;

      if (reps == 0) {
        // Learning steps for new cards
        if (grade < 2) {
          // Reset learning
          step = 0;
          widget.db.updateNextReview(
            _cards[_currentIndex].character,
            reps,
            interval,
            ease,
            DateTime.now().add(Duration(minutes: 1)),
            step,
          ); // Reschedule for tomorrow
          //if grade is better than forgot, and step is 0 then
        } else if (step == 0) {
          step = 1;
          widget.db.updateNextReview(
            _cards[_currentIndex].character,
            reps,
            interval,
            ease,
            DateTime.now().add(Duration(minutes: 1)),
            step,
          );
        } else if (step == 1) {
          step = 2;
          widget.db.updateNextReview(
            _cards[_currentIndex].character,
            reps,
            interval,
            ease,
            DateTime.now().add(Duration(minutes: 10)),
            step,
          );
        } else {
          // Graduate to review
          step = 3;
          reps = 1; //make sure reps is 1
          interval = 1;
          ease = 2.5;
          widget.db.updateNextReview(
            _cards[_currentIndex].character,
            reps,
            interval,
            ease,
            DateTime.now().add(Duration(minutes: 10)),
            step,
          );
        }
      } else {
        //sm2 logic
        if (grade < 2) {
          // Forgot
          reps = 0;
          interval = 1; // NEXT REVIEW: Tomorrow
        } else {
          // Remembered
          reps += 1;

          if (reps == 2) {
            interval = 1;
          } else if (reps == 3) {
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
          _cards[_currentIndex].character,
          reps,
          interval,
          ease,
          DateTime.now().add(Duration(days: interval)),
          step,
        ); // Reschedule for tomorrow
      }

      if (strokeMap.containsKey(_cards[_currentIndex].character)) {
        expansionController.collapse();
      }
    }
    //currentindex is 1 if cards is empty
    if (_currentIndex >= _cards.length - 1) {
      final cards = await widget.db.getDueCards();

      if (cards.isNotEmpty) {
        setState(() {
          _cards = cards;
          _currentIndex = 0;
        });
        //empty
      } else {
        setState(() {
          _currentIndex = -1;
          _cards = [];
        });
      }
    } else {
      setState(() {
        _currentIndex++;
      });
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
                SizedBox(
                  height: MediaQuery.of(context).padding.top,
                ), // Space at the top
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
                      'Review Characters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child:
                          _cards.isNotEmpty
                              ? IconButton(
                                icon: Icon(Icons.edit),
                                color: Colors.grey,
                                tooltip: 'Edit',
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => EditCardPage(
                                            card: currentCard!,
                                            db: widget.db,
                                          ),
                                    ),
                                  );

                                  // After EditCardPage is popped, check result:
                                  if (result == true) {
                                    refreshDueCards();
                                  }
                                },
                              )
                              : IconButton(
                                icon: Icon(Icons.refresh),
                                color: Colors.grey,
                                tooltip: 'Refresh Cards',
                                onPressed: () async {
                                  final cards = await widget.db.getDueCards();
                                  setState(() {
                                    _cards = cards;
                                    _currentIndex = _cards.isEmpty ? -1 : 0;
                                  });
                                },
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
                                                AllCharacters(db: widget.db),
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
                          : currentCard!.character.length <= 3
                          ? Text(
                            currentCard.character,
                            style: const TextStyle(
                              fontSize: 76,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              decoration:
                                  TextDecoration.none, // Remove underline
                            ),
                          )
                          : Text(
                            currentCard.character,
                            style: const TextStyle(
                              fontSize: 46,
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
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    ExpansionTile(
                      title: const Text("Personal Notes"),
                      leading: const Icon(Icons.notes),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.transparent,
                        ), // removes bottom line
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child:
                              _currentIndex == -1
                                  ? SizedBox.shrink()
                                  : Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      _cards[_currentIndex].notes
                                                  ?.trim()
                                                  .isNotEmpty ==
                                              true
                                          ? _cards[_currentIndex].notes!.trim()
                                          : "No notes yet.",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
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
                SizedBox(
                  height: MediaQuery.of(context).padding.top,
                ), // Space at the top
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
                    Align(
                      alignment: Alignment.centerRight,
                      child:
                          _cards.isNotEmpty
                              ? IconButton(
                                icon: Icon(Icons.edit),
                                color: Colors.grey,
                                tooltip: 'Edit',
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => EditCardPage(
                                            card: currentCard!,
                                            db: widget.db,
                                          ),
                                    ),
                                  );

                                  // After EditCardPage is popped, check result:
                                  if (result == true) {
                                    refreshDueCards();
                                  }
                                },
                              )
                              : IconButton(
                                icon: Icon(Icons.refresh),
                                color: Colors.grey,
                                tooltip: 'Refresh Cards',
                                onPressed: () async {
                                  final cards = await widget.db.getDueCards();
                                  setState(() {
                                    _cards = cards;
                                    _currentIndex = _cards.isEmpty ? -1 : 0;
                                  });
                                },
                              ),
                    ),
                  ],
                ),
                SizedBox(height: 4), // Space before the review list
                //inside futurebuilder
                Column(
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
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  AllCharacters(db: widget.db),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Character text
                                      _cards[_currentIndex].character.length <=
                                              3
                                          ? Text(
                                            _cards[_currentIndex].character,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 76,
                                              color: Colors.black87,
                                              decoration: TextDecoration.none,
                                            ),
                                          )
                                          : Text(
                                            _cards[_currentIndex].character,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 52,
                                              color: Colors.black87,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: 4,
                                ), // Space before the review list
                              ],
                            ),
                          ],
                ),

                Padding(
                  padding: EdgeInsets.all(0),
                  child:
                      _currentIndex != -1
                          ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Pinyin + icon (wrapped nicely)
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: constraints.maxWidth * 0.95,
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  '[${_cards[_currentIndex].pinyin}]',
                                              style: TextStyle(
                                                fontSize:
                                                    _cards[_currentIndex]
                                                                .pinyin
                                                                .length <=
                                                            3
                                                        ? 32
                                                        : 24,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            WidgetSpan(
                                              alignment:
                                                  PlaceholderAlignment.middle,
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.volume_up,
                                                  size:
                                                      _cards[_currentIndex]
                                                                  .pinyin
                                                                  .length <=
                                                              3
                                                          ? 28
                                                          : 22,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  playAudio(
                                                    _cards[_currentIndex]
                                                        .character,
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        softWrap: true,
                                      ),
                                    );
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 0),
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
                                                fontSize: 20,
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
                                SizedBox(
                                  height: 8,
                                ), // Space between meaning and example
                                _cards[_currentIndex].chineseSentence == null ||
                                        _cards[_currentIndex].chineseSentence ==
                                            ""
                                    ? SizedBox(height: 0)
                                    : RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'Example: ${_cards[_currentIndex].chineseSentence}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                          WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.volume_up,
                                                size: 24,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () {
                                                playAudio(
                                                  _cards[_currentIndex]
                                                      .chineseSentence!,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                _cards[_currentIndex].pinyinSentence == null ||
                                        _cards[_currentIndex].pinyinSentence ==
                                            ""
                                    ? SizedBox(height: 0)
                                    : Wrap(
                                      children: [
                                        Text(
                                          'Pinyin: ${_cards[_currentIndex].pinyinSentence}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            decoration:
                                                TextDecoration
                                                    .none, // Remove underline
                                          ),
                                        ),
                                        SizedBox(height: 36),
                                      ],
                                    ),
                                _cards[_currentIndex].englishSentence == null ||
                                        _cards[_currentIndex].englishSentence ==
                                            ""
                                    ? SizedBox(height: 0)
                                    : Wrap(
                                      children: [
                                        Text(
                                          "Translation: ${_cards[_currentIndex].englishSentence}",
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

                                const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                              ],
                            ),
                          )
                          : SizedBox(height: 4),
                ),

                Padding(
                  padding: EdgeInsets.all(0),
                  child:
                      (_cards.isEmpty || _currentIndex == -1 || !strokesLoaded)
                          ? SizedBox(height: 4)
                          : strokesLoaded &&
                              strokeMap.containsKey(
                                _cards[_currentIndex].character,
                              )
                          ? Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              controller: expansionController,
                              title: const Text("Stroke Order Animation"),
                              leading: const Icon(Icons.play_arrow),
                              children: [
                                Center(
                                  child: SizedBox(
                                    height: 150,
                                    child: StrokeOrderWidget(
                                      character:
                                          _cards[_currentIndex].character,
                                      dataMap: strokeMap,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : const SizedBox.shrink(),
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
