import 'package:camera/camera.dart';
import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/home_page.dart';
import 'package:flashhanzi/utils/error.dart';
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
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
  late CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
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
    try {
      await _initializeControllerFuture; // Ensure camera is ready
      final image = await _cameraController!.takePicture();

      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
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
        // recognizedList = foundWords;
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ErrorPage(db: widget.db)),
      );
    }
  }

  String _extractChineseOnly(String input) {
    final regex = RegExp(r'[\u4e00-\u9fff]');
    return input.split('').where((char) => regex.hasMatch(char)).join();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20), // Add some space at the top
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
          const SizedBox(
            height: 20,
          ), // Add some space between the text and camera
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the camera preview in a box
                return Center(
                  child: Container(
                    width: 340, // Set the width of the camera box
                    height: 340, // Set the height of the camera box
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ), // Optional border
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // Optional rounded corners
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // Match the border radius
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                // Handle errors during initialization
                return Center(
                  child: Text(
                    'Error initializing camera',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              } else {
                // Otherwise, display a loading indicator
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          SizedBox(height: 20), // Add some space before the button
          ElevatedButton(
            onPressed: _scanImage,
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
                'Scan Characters',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 320,
            width: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
          ),
          SizedBox(height: 16), // Add some space before the button
          ElevatedButton(
            onPressed: doNothing,
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
                'Add Selected Words for Review',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void doNothing() {}
