import 'package:flashhanzi/assets/parse_cedict.dart';
import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/dictionary_lookup.dart';
import 'package:flashhanzi/handwrite_character.dart';
import 'package:flashhanzi/home_page.dart';
import 'package:flashhanzi/review_characters.dart';
import 'package:flashhanzi/scan_character.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  await seedTestCards(db);

  final isTableEmpty = (await db.select(db.dictionaryEntries).get()).isEmpty;

  if (isTableEmpty) {
    await parse(db); // Run parsing if the table is empty
  }

  runApp(MyApp(db: db));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.db});
  final AppDatabase db; // Pass the database instance to the app
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
      home: HomePage(db: db),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int initialIndex; // Add this to accept the initial index
  final AppDatabase db; // Pass the database instance to the home page
  const MyHomePage({super.key, required this.initialIndex, required this.db});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _currentIndex; // Tracks the current index of the BottomNavigationBar

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Set the initial index
    _pages = [
      ScanCharacter(db: widget.db), // First tab
      HandwriteCharacter(db: widget.db), // Second tab
      ReviewCharacters(db: widget.db),
      DictionaryLookup(db: widget.db), // Third tab
    ];
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
