import 'package:camera/camera.dart';
import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/home_page.dart';
import 'package:flutter/material.dart';

class ScanCharacter extends StatefulWidget {
  const ScanCharacter({super.key, required this.db});
  final AppDatabase db;
  @override
  State<ScanCharacter> createState() => _ScanCharacterState();
}

class _ScanCharacterState extends State<ScanCharacter> {
  late CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  late AppDatabase db;
  @override
  void initState() {
    super.initState();
    db = AppDatabase();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Get a list of available cameras on the device
      final cameras = await availableCameras();
      // Select the first camera (usually the rear camera)
      final firstCamera = cameras.first;

      // Initialize the CameraController
      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high, // Set the resolution
      );

      // Initialize the controller and store the Future
      setState(() {
        _initializeControllerFuture = _cameraController?.initialize();
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    // Dispose of the CameraController when the widget is disposed
    _cameraController?.dispose();
    super.dispose();
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
                      MaterialPageRoute(builder: (context) => HomePage(db: db)),
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
