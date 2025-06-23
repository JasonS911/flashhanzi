import 'package:flashhanzi/about_page.dart';
import 'package:flashhanzi/all_characters.dart';
import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/main.dart';
import 'package:flashhanzi/utils/error.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    as mlkit;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flashhanzi/utils/play_audio.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.db});
  final AppDatabase db;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int dueCardsLength = 0;
  String? _chineseWord;
  String? _pinyinWord;
  String? _englishWord;
  String? _chineseSentence;
  String? _pinyinSentence;
  String? _englishSentence;

  String? chineseStory;
  String? pinyinStory;
  String? englishStory;

  bool showPinyinStory = false;
  bool showEnglishStory = false;

  @override
  void initState() {
    super.initState();
    // Initialize the database using the value passed to HomePage
    ensureModelDownloaded();
    getDueCardsLength();
    fetchChinesePhrases();
    fetchDailyStory();
  }

  void getDueCardsLength() async {
    final dueCards = await widget.db.getDueCards(); // Call your custom method
    setState(() {
      dueCardsLength = dueCards.length;
    });
  }

  Future<void> ensureModelDownloaded() async {
    const modelName = 'zh-Hani';
    final modelManager = mlkit.DigitalInkRecognizerModelManager();

    try {
      bool isDownloaded = await modelManager.isModelDownloaded(modelName);

      if (!isDownloaded) {
        await modelManager.downloadModel(modelName); // Download the model once
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ErrorPage(db: widget.db)),
      );
    }
  }

  Future<void> fetchChinesePhrases() async {
    final url = Uri.parse('https://www.chineseclass101.com/chinese-phrases/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      // Example: Extracting phrases from elements with class 'phrase'
      final wordData = jsonDecode(
        document.querySelector('#word_page')?.attributes['data-wordday'] ??
            '{}',
      );
      setState(() {
        _chineseWord = wordData['text'];
        _pinyinWord = wordData['romanization'];
        _englishWord = wordData['english'];

        final samples = wordData['samples'] as List<dynamic>;
        _chineseSentence = samples[0]['text'];
        _pinyinSentence = samples[0]['romanization'];
        _englishSentence = samples[0]['english'];
      });
    } else {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ErrorPage(db: widget.db)),
      );
    }
  }

  Future<void> fetchDailyStory() async {
    final today = DateTime.now();
    final dateString = DateFormat(
      'yyyy-MM-dd',
    ).format(today); // Ensures leading zeros
    final url =
        'https://chinesestorygenerator.web.app/daily_story/$dateString.json';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dailyStory = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        chineseStory = dailyStory['chinese'];
        pinyinStory = dailyStory['pinyin'];
        englishStory = dailyStory['english'];
      });
    } else {
      return;
    }
  }

  Future<void> _addNewCard(AppDatabase db, String characterToAdd) async {
    if (!mounted) return;
    newCardFromWotd(
      db,
      characterToAdd,
      _pinyinWord!,
      _englishWord!,
      _chineseSentence,
      _pinyinSentence,
      _englishSentence,
    );
    showDialog(
      context: context,
      barrierDismissible: false, // optional: prevent premature tap dismissal
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 10,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Word added to your review deck!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sets the background color of the page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // optional, or highlight based on context
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Optionally pop and return to main scaffold
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) => MyHomePage(initialIndex: index, db: widget.db),
            ),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.brush), label: 'Handwrite'),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Review Characters',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Dictionary Lookup',
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // Sets the background color of the page
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                bottom: kBottomNavigationBarHeight,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Centers children horizontally
                children: [
                  SizedBox(height: 24), // Adds space at the top
                  Image.asset(
                    'assets/logo.png', // Ensure you have a logo image in the assets folder
                    height: 100, // Adjust height as needed
                    width: 260, // Adjust width as needed
                  ),
                  Text(
                    '$dueCardsLength Characters due today', // Display the first sentence
                    style: GoogleFonts.notoSansSc(
                      fontSize: 20,
                      color: Colors.black87,
                      decoration: TextDecoration.none, // Remove underline
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 4,
                      right: 4,
                      bottom: 4,
                    ),
                    child:
                        _chineseWord == null ||
                                _pinyinWord == null ||
                                _englishWord == null ||
                                _chineseSentence == null ||
                                _pinyinSentence == null ||
                                _englishSentence == null
                            ? SizedBox(height: 4)
                            : Container(
                              width:
                                  double
                                      .infinity, // Makes the container full width
                              // height: 300,
                              margin: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start, // Aligns children to the start
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 16,
                                          left: 16,
                                        ), // Adds space at the top
                                        child: Text(
                                          'Word of the Day',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            decoration:
                                                TextDecoration
                                                    .none, // Remove underline from the title
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 30),

                                        onPressed:
                                            () => _addNewCard(
                                              widget.db,
                                              _chineseWord!,
                                            ),
                                      ),
                                    ],
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _chineseWord!,
                                          style: TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            decoration:
                                                TextDecoration
                                                    .none, // Remove underline
                                          ),
                                        ),

                                        Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          alignment: WrapAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 12,
                                                bottom: 8,
                                              ), // Adds space between character and text
                                              child: Text(
                                                _pinyinWord!, // Pinyin with tone
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.volume_up,
                                                  size: 24,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  // Add functionality to play audio here
                                                  playAudio(_chineseWord!);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Text(
                                      _englishWord!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        decoration:
                                            TextDecoration
                                                .none, // Remove underline
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Divider(
                                    color: Colors.grey,
                                    height: 1,
                                    indent: 16,
                                    endIndent: 16,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Sentence",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration
                                                    .none, // Remove underline
                                          ),
                                        ),
                                        IconButton(
                                          padding:
                                              EdgeInsets.only(), // optional padding before icon
                                          icon: const Icon(
                                            Icons.volume_up,
                                            size:
                                                20, // Slightly smaller to align well
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            playAudio(_chineseSentence!);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16.0,
                                      right: 16.0,
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: _chineseSentence!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration
                                                      .none, // Remove underline
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      _pinyinSentence!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                        decoration:
                                            TextDecoration
                                                .none, // Remove underline
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      _englishSentence!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                        decoration:
                                            TextDecoration
                                                .none, // Remove underline
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                ],
                              ),
                            ),
                  ), // Adds space at the top
                  SizedBox(
                    height: 16,
                  ), // Adds space between the word of the day and the next section
                  //second container with passage of the day
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (!showPinyinStory) {
                          showPinyinStory = !showPinyinStory;
                        } else if (!showEnglishStory) {
                          showEnglishStory = !showEnglishStory;
                        } else {
                          showPinyinStory = false;
                          showEnglishStory = false;
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity, // Makes the container full width
                      // height: 300,
                      margin: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start, // Aligns children to the start
                        children: [
                          chineseStory != null
                              ? Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4,
                                          left: 16,
                                        ), // Adds space at the top
                                        child: Text(
                                          'Passage of the Day',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            decoration:
                                                TextDecoration
                                                    .none, // Remove underline from the title
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 0,
                                              top: 4,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.volume_up,
                                                size: 20,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () {
                                                // Add functionality to play audio here
                                                playAudio(chineseStory!);
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 0,
                                              top: 4,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.pause,
                                                size: 20,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () {
                                                // Add functionality to play audio here
                                                pauseAudio();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16.0,
                                      right: 16.0,
                                      bottom: 16,
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: chineseStory,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration
                                                      .none, // Remove underline
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : SizedBox(height: 0),
                          pinyinStory != null && showPinyinStory
                              ? Column(
                                children: [
                                  Divider(
                                    color: Colors.grey,
                                    height: 1,
                                    indent: 16,
                                    endIndent: 16,
                                  ),

                                  SizedBox(height: 16),
                                ],
                              )
                              : SizedBox(height: 0),
                          pinyinStory != null && showPinyinStory
                              ? Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  bottom: 16,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: pinyinStory,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          decoration:
                                              TextDecoration
                                                  .none, // Remove underline
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              : SizedBox(height: 0),
                          Column(
                            children:
                                englishStory != null &&
                                        showPinyinStory &&
                                        showEnglishStory
                                    ? [
                                      Divider(
                                        color: Colors.grey,
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16,
                                      ),
                                      SizedBox(height: 16),
                                    ]
                                    : [
                                      SizedBox(height: 0),
                                      SizedBox(height: 0),
                                    ],
                          ),
                          englishStory != null &&
                                  showPinyinStory &&
                                  showEnglishStory
                              ? Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  bottom: 16,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: englishStory,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          decoration:
                                              TextDecoration
                                                  .none, // Remove underline
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              : SizedBox(height: 0),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  // Adds space between sentences
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 20.0,
                  //   ), // Adds space on the left and right
                  //   child: GridView.count(
                  //     crossAxisCount: 2, // Number of columns
                  //     childAspectRatio: 1, // Aspect ratio for each grid item
                  //     mainAxisSpacing: 2, // Space between rows
                  //     crossAxisSpacing: 2, // Space between columns
                  //     physics:
                  //         NeverScrollableScrollPhysics(), // Disables scrolling
                  //     shrinkWrap:
                  //         true, // Ensures GridView takes only the required space
                  //     children: [
                  //       Padding(
                  //         padding: EdgeInsets.all(4),
                  //         child: _ActionTile(
                  //           label: 'Scan Character',
                  //           icon: Icons.camera_alt,
                  //           onTap: () {
                  //             Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                 builder:
                  //                     (context) => MyHomePage(
                  //                       initialIndex: 0,
                  //                       db: widget.db,
                  //                     ),
                  //               ),
                  //             );
                  //           },
                  //         ),
                  //       ),
                  //       Padding(
                  //         padding: EdgeInsets.all(4),
                  //         child: _ActionTile(
                  //           label: 'Handwrite Character',
                  //           icon: Icons.brush,
                  //           onTap: () {
                  //             Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                 builder:
                  //                     (context) => MyHomePage(
                  //                       initialIndex: 1,
                  //                       db: widget.db,
                  //                     ),
                  //               ),
                  //             );
                  //           }, // Replace with your scan function
                  //         ),
                  //       ),
                  //       Padding(
                  //         padding: EdgeInsets.all(4),
                  //         child: _ActionTile(
                  //           label: 'Review Characters',
                  //           icon: Icons.book,
                  //           onTap: () {
                  //             Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                 builder:
                  //                     (context) => MyHomePage(
                  //                       initialIndex: 2,
                  //                       db: widget.db,
                  //                     ),
                  //               ),
                  //             ).then((_) {
                  //               // Called when returning from ReviewCharacters
                  //               getDueCardsLength();
                  //             });
                  //           },
                  //         ),
                  //       ),
                  //       Padding(
                  //         padding: EdgeInsets.all(4),
                  //         child: _ActionTile(
                  //           label: 'Search Characters',
                  //           icon: Icons.search,
                  //           onTap: () {
                  //             Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                 builder:
                  //                     (context) => MyHomePage(
                  //                       initialIndex: 3,
                  //                       db: widget.db,
                  //                     ),
                  //               ),
                  //             );
                  //           }, // Replace with your scan function
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),

            // Top-right More icon
            Positioned(
              top: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                ), // Increase this if you want
                child: PopupMenuButton<String>(
                  color: Colors.white,
                  icon: Icon(Icons.more_vert, color: Colors.black87),
                  onSelected: (value) {
                    if (value == 'allCharacters') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllCharacters(db: widget.db),
                        ),
                      );
                    }
                    if (value == 'about') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'allCharacters',
                          child: Text('Review All Characters'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'about',
                          child: Text('About'),
                        ),
                      ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _ActionTile extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _ActionTile({
//     required this.label,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       elevation: 4,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 36),
//               const SizedBox(height: 12),
//               Text(label, textAlign: TextAlign.center),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
