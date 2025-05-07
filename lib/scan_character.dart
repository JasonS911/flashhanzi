import 'package:camera/camera.dart';
import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/home_page.dart';
import 'package:flashhanzi/utils/error.dart';
import 'package:flashhanzi/utils/word_grid.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:jieba_flutter/analysis/jieba_segmenter.dart';
import 'package:jieba_flutter/analysis/seg_token.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanCharacter extends StatefulWidget {
  const ScanCharacter({super.key, required this.db});
  final AppDatabase db;
  @override
  State<ScanCharacter> createState() => _ScanCharacterState();
}

class _ScanCharacterState extends State<ScanCharacter>
    with WidgetsBindingObserver {
  late CameraController? _cameraController;
  bool isScanning = false;

  Future<void>? _initializeControllerFuture;
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
    WidgetsBinding.instance.addObserver(this);

    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        _initializeCamera();
      }
    }
  }

  bool _initializing = false;

  Future<void> _initializeCamera() async {
    if (_initializing) return;
    _initializing = true;

    final status = await Permission.camera.status;

    if (status.isGranted) {
      await _startCamera();
    } else if (status.isDenied || status.isRestricted) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        await _startCamera();
      } else {
        _showPermissionDialog();
      }
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    }

    _initializing = false;
  }

  Future<void> _startCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      setState(() {
        _initializeControllerFuture = _cameraController!.initialize();
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ErrorPage(db: widget.db)),
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Camera Permission'),
            content: const Text(
              'Please enable camera access in your settings.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await openAppSettings(); // Open device settings
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  Future<void> _scanImage() async {
    if (isScanning) return;
    setState(() {
      isScanning = true;
      recognizedList.clear();
      charactersToAddRecognizedList.clear();
    });
    try {
      await _initializeControllerFuture; // Ensure camera is ready
      final image = await _cameraController!.takePicture();

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.chinese,
      );
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final chineseOnly = _extractChineseOnly(recognizedText.text);
      //show the chiense only translation
      List<String> foundWords = [];

      await JiebaSegmenter.init().then((value) async {
        var segmentedWord = JiebaSegmenter();
        List<SegToken> words = segmentedWord.process(
          chineseOnly,
          SegMode.SEARCH,
        );
        for (final token in words) {
          final word = token.word;
          final results = await widget.db.searchDictionary(word);
          if (results.isNotEmpty) {
            foundWords.add(word);
          }
        }
      }); // Initialize JiebaSegmenter

      setState(() {
        // Update your UI with foundWords
        recognizedList = foundWords.map((word) => word.trim()).toSet();
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ErrorPage(db: widget.db)),
      );
    } finally {
      setState(() {
        isScanning = false;
      });
    }
  }

  String _extractChineseOnly(String input) {
    final regex = RegExp(r'[\u4e00-\u9fff]');
    return input.split('').where((char) => regex.hasMatch(char)).join();
  }

  Future<void> _addNewCards(AppDatabase db, Set<String> charactersToAdd) async {
    for (String word in charactersToAdd) {
      newCard(db, word);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${charactersToAdd.length} words added to your review deck!',
        ),
        duration: Duration(seconds: 2), // auto-dismiss after 2 seconds
      ),
    );
    ();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        // child: ElevatedButton(
        //   onPressed: _scanImage,
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Color(0xFFB42F2B), // Button color
        //     foregroundColor: Colors.white, // Text color
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(4), // Rounded corners
        //     ),
        //   ),
        //   child: Padding(
        //     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        //     child: Text(
        //       'Scan Characters',
        //       style: TextStyle(color: Colors.white, fontSize: 16),
        //     ),
        //   ),
        // ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                          builder: (context) => HomePage(db: widget.db),
                        ),
                      );
                    },
                  ),
                ),
                const Text(
                  'Scan Character',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.65,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error initializing camera',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          recognizedList.clear();
                          charactersToAddRecognizedList.clear();
                        });
                      },
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
                        await _scanImage();
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
                        child: Text('Scan'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (recognizedList.isNotEmpty) ...[
              SizedBox(height: 28),
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
                db: widget.db,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _addNewCards(widget.db, charactersToAddRecognizedList);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB42F2B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Add Selected Words for Review',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
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
