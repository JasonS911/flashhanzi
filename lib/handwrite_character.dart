import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/home_page.dart';
import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    as mlkit;
import 'package:jieba_flutter/analysis/jieba_segmenter.dart';
import 'package:jieba_flutter/analysis/seg_token.dart';

class HandwriteCharacter extends StatefulWidget {
  const HandwriteCharacter({super.key, required this.db});
  final AppDatabase db;

  @override
  State<HandwriteCharacter> createState() => _HandwriteCharacterState();
}

class _HandwriteCharacterState extends State<HandwriteCharacter> {
  late AppDatabase db;
  List<Offset?> points = [];
  final GlobalKey _globalKey = GlobalKey();
  late mlkit.DigitalInkRecognizer _digitalInkRecognizer;

  //select characters and update grid widget
  Set<String> recognizedList = {};
  Set<String> charactersToAddRecognizedList =
      {}; //characters ur putting into dictionary
  void onSelectionChanged(Set<String> updatedSelection) {
    setState(() {
      charactersToAddRecognizedList = updatedSelection;
    });
  }

  @override
  void initState() {
    super.initState();
    db = AppDatabase();

    // Initialize the digital ink recognizer with the correct language code
    _digitalInkRecognizer = mlkit.DigitalInkRecognizer(languageCode: 'zh-Hans');
  }

  Future<void> _addNewCards(AppDatabase db, Set<String> charactersToAdd) async {
    for (String word in charactersToAdd) {
      newCard(db, word);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Words added to your review deck!'),
        duration: Duration(seconds: 2), // auto-dismiss after 2 seconds
      ),
    );
    clearCanvas();
  }

  Future<void> _recognizeDrawing() async {
    try {
      // await ensureModelDownloaded();
      // Convert raw points to Ink
      final ink = _convertPointsToInk(points);
      final result = await _digitalInkRecognizer.recognize(ink);

      // Convert the List<RecognitionCandidate> to a single string
      String recognized = result.map((candidate) => candidate.text).join('\n');
      List<String> recognizedTextList = recognized.split('\n');
      //cycle through the first ten words of the list. For each word break apart using Jieba and add to the final recognizedList to return
      for (var wordNumber = 0; wordNumber < 10; wordNumber++) {
        //add the most matched words right away if they exist in dictionary
        var recognizedWord = recognizedTextList[wordNumber];
        List<DictionaryEntry>? results = await widget.db.searchDictionary(
          recognizedWord,
        );
        if (results.isNotEmpty) {
          recognizedList.add(recognizedWord);
        }
        results = null;
        //segment each matched word phrase and add if they exist in dictionary
        await JiebaSegmenter.init().then((value) async {
          var segmentedWord = JiebaSegmenter();
          List<SegToken> recognizedWordBeforeBroken = segmentedWord.process(
            recognizedWord,
            SegMode.SEARCH,
          );
          for (var i = 0; i < recognizedWordBeforeBroken.length; i++) {
            recognizedWord = recognizedWordBeforeBroken[i].word;
            List<DictionaryEntry>? results = await widget.db.searchDictionary(
              recognizedWord,
            );
            if (results.isNotEmpty) {
              recognizedList.add(recognizedWord);
            }
            results = null;
          }
        });
      }
      setState(() {
        recognizedList = recognizedList;
      });
    } catch (e) {
      print("Error recognizing handwriting: $e");
    }
  }

  // Convert raw points to Ink
  mlkit.Ink _convertPointsToInk(List<Offset?> rawPoints) {
    final strokes = <mlkit.Stroke>[]; // To hold all strokes
    List<mlkit.StrokePoint> currentStroke =
        []; // To hold points for a single stroke

    for (final point in rawPoints) {
      if (point == null) {
        // When null is encountered, a stroke is completed
        if (currentStroke.isNotEmpty) {
          // Add the stroke to strokes list
          strokes.add(mlkit.Stroke()..points = List.from(currentStroke));
          currentStroke.clear();
        }
      } else {
        // Add a point to the current stroke
        currentStroke.add(
          mlkit.StrokePoint(
            x: point.dx,
            y: point.dy,
            t: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    }

    // Add the last stroke if there are points remaining
    if (currentStroke.isNotEmpty) {
      strokes.add(mlkit.Stroke()..points = List.from(currentStroke));
    }

    return mlkit.Ink()..strokes = strokes; // Return the ink with all strokes
  }

  void clearCanvas() {
    setState(() {
      points.clear();
      recognizedList = {};
      charactersToAddRecognizedList = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Stack(
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
                          builder: (context) => HomePage(db: db),
                        ),
                      );
                    },
                  ),
                ),
                const Text(
                  'Handwrite Character',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            RepaintBoundary(
              key: _globalKey,
              child: Container(
                height: 340,
                width: 340,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      double x = details.localPosition.dx;
                      double y = details.localPosition.dy;
                      if (x >= 10 && x <= 330 && y >= 10 && y <= 330) {
                        points.add(details.localPosition);
                      }
                    });
                  },
                  onPanEnd: (details) {
                    points.add(null); // End of stroke
                  },
                  child: CustomPaint(painter: MyPainter(points)),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: clearCanvas,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Clear',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _recognizeDrawing();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB42F2B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Recognize'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (recognizedList.isNotEmpty) ...[
              const SizedBox(height: 28),
              Text(
                'Recognized Characters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  letterSpacing: 0.5,
                ),
              ),

              WordGrid(
                wordSet: recognizedList,
                finalWordSet: charactersToAddRecognizedList,
                onSelectionChanged: onSelectionChanged,
              ),

              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _addNewCards(db, charactersToAddRecognizedList);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB42F2B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Add Characters to Personal Dictionary'),
                ),
              ),
              SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<Offset?> points;

  MyPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawCircle(points[i]!, 5.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class WordGrid extends StatefulWidget {
  final Set<String> wordSet; //aka recognizedList Set
  final Set<String> finalWordSet;
  final void Function(Set<String>) onSelectionChanged;

  const WordGrid({
    super.key,
    required this.wordSet,
    required this.finalWordSet,
    required this.onSelectionChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _WordGridState createState() => _WordGridState();
}

class _WordGridState extends State<WordGrid> {
  late List<String> words;
  // late Set<String> selectedWords;
  late void Function(Set<String>) onSelectionChanged;
  @override
  void initState() {
    super.initState();
    // Convert the Set into a List to display in the GridView
    words = widget.wordSet.toList();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 28),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        final isSelected = widget.finalWordSet.contains(word);
        return GestureDetector(
          onTap: () {
            final newSelection = Set<String>.from(
              widget.finalWordSet,
            ); //create new set of selected words
            isSelected ? newSelection.remove(word) : newSelection.add(word);

            widget.onSelectionChanged(newSelection); // SEND BACK here
          },
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.blue
                      : const Color.fromARGB(
                        240,
                        247,
                        245,
                        245,
                      ), // Light grey background
              borderRadius: BorderRadius.circular(12), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey, // Subtle shadow
                  blurRadius: 2,
                  offset: Offset(2, 2), // Shadow position
                ),
              ],
            ),
            child: Center(
              child: Text(
                words[index],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
