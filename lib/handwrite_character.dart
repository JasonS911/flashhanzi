import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/home_page.dart';
import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    as mlkit;
import 'package:jieba_flutter/analysis/jieba_segmenter.dart';
import 'package:jieba_flutter/analysis/seg_token.dart';
// import 'package:jieba_flutter/jieba_flutter.dart';

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
  Set<String> recognizedList = {};
  Set<String> finalRecognizedList = {};
  @override
  void initState() {
    super.initState();
    db = AppDatabase();

    // Initialize the digital ink recognizer with the correct language code
    _digitalInkRecognizer = mlkit.DigitalInkRecognizer(languageCode: 'zh-Hans');
  }

  Future<void> recognizeDrawing() async {
    try {
      await ensureModelDownloaded();
      // Convert raw points to Ink
      final ink = _convertPointsToInk(points);
      final result = await _digitalInkRecognizer.recognize(ink);

      // Convert the List<RecognitionCandidate> to a single string
      String recognized = result.map((candidate) => candidate.text).join('\n');
      List<String> recognizedTextList = recognized.split('\n');
      //cycle through the first five words of the list. For each word break apart using Jieba and add to the final recognizedList to return
      for (var wordNumber = 0; wordNumber < 5; wordNumber++) {
        var recognizedWord = recognizedTextList[wordNumber];
        await JiebaSegmenter.init().then((value) {
          var segmentedWord = JiebaSegmenter();
          List<String> recognizedWordBeforeBroken = segmentedWord
              .process(recognizedWord, SegMode.SEARCH)[0]
              .toString()
              .split(',');
          recognizedWord = recognizedWordBeforeBroken[0].substring(1);
          recognizedList.add(recognizedWord);
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
    });
  }

  Future<void> ensureModelDownloaded() async {
    const modelName = 'zh-Hani';
    final modelManager = mlkit.DigitalInkRecognizerModelManager();

    try {
      bool isDownloaded = await modelManager.isModelDownloaded(modelName);

      if (!isDownloaded) {
        print("Model not downloaded, downloading...");
        await modelManager.downloadModel(modelName); // Download the model once
        print("Model downloaded and saved locally.");
      } else {
        print("Model is already downloaded.");
      }
    } catch (e) {
      print("Error checking/downloading model: $e");
    }
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
                        await recognizeDrawing();
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
            if (recognizedList.isNotEmpty) // Display recognized text below
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 300, // or any fixed height that fits your design
                  child: WordGrid(wordSet: recognizedList),
                ),
              ),
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
  final Set<String> wordSet;
  const WordGrid({super.key, required this.wordSet});

  @override
  // ignore: library_private_types_in_public_api
  _WordGridState createState() => _WordGridState();
}

class _WordGridState extends State<WordGrid> {
  late List<String> words;
  @override
  void initState() {
    super.initState();
    // Convert the Set into a List to display in the GridView
    words = widget.wordSet.toList();
    print(words);
  }

  void updateWords(Set<String> newWords) {
    setState(() {
      words = newWords.toList(); // Update the words when the Set changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: words.length,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(8),
          color: Colors.blue[100],
          child: Center(
            child: Text(
              words[index],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
