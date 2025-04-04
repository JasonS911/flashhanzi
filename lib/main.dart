import 'package:flashhanzi/dictionary_lookup.dart';
import 'package:flashhanzi/handwrite_character.dart';
import 'package:flashhanzi/home_page.dart';
import 'package:flashhanzi/review_characters.dart';
import 'package:flashhanzi/scan_character.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashHanzi',
      theme: ThemeData(
        primaryTextTheme: TextTheme(
          bodyMedium: TextStyle(
            color: Colors.black87, // Set a neutral default color
            decoration: TextDecoration.none, // Remove default underline
          ),
          bodyLarge: TextStyle(
            color: Colors.black87, // Set a neutral default color
            decoration: TextDecoration.none, // Remove default underline
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // Set the background color
          selectedItemColor: Color(
            0xFFB42F2B,
          ), // Set the color for selected items
          unselectedItemColor:
              Colors.grey, // Set the color for unselected items
        ),
      ),
      home: const HomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int initialIndex; // Add this to accept the initial index

  const MyHomePage({super.key, required this.initialIndex});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _currentIndex; // Tracks the current index of the BottomNavigationBar

  final List<Widget> _pages = [
    ScanCharacter(), // First tab
    HandwriteCharacter(), // Second tab
    ReviewCharacters(),
    DictionaryLookup(), // Third tab
    // Fourth tab (if you have it)
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Set the initial index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('FlashHanzi')),
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Highlight the selected tab
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current index
          });
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
          ), // Add this line for the new tab
        ],
      ),
    );
  }
}
