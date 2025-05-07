import 'package:flashhanzi/utils/parse.dart';
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
  // ignore: unused_field
  late Widget? _scanPage;
  final GlobalKey<ReviewCharactersState> _reviewKey =
      GlobalKey<ReviewCharactersState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Set the initial index
    _scanPage = ScanCharacter(db: widget.db); // Start with Scan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('FlashHanzi')),
      // body: _pages[_currentIndex], // Display the selected page
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Tab 0: ScanCharacter – only build when active
          _currentIndex == 0 ? ScanCharacter(db: widget.db) : const SizedBox(),

          // Tab 1: HandwriteCharacter – always alive (stateful drawing)
          HandwriteCharacter(db: widget.db),

          // Tab 2: ReviewCharacters – only build when active
          _currentIndex == 2
              ? ReviewCharacters(key: _reviewKey, db: widget.db)
              : const SizedBox(),

          // Tab 3: DictionaryLookup – always alive (stateful lookups)
          DictionaryLookup(db: widget.db),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Highlight the selected tab
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current index
            if (index == 2) {
              _reviewKey.currentState?.refreshDueCards();
            }
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
