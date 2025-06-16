import 'package:flashhanzi/subscription_page.dart';
import 'package:flashhanzi/utils/loading_screen.dart';
import 'package:flashhanzi/utils/parse.dart';
import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/dictionary_lookup.dart';
import 'package:flashhanzi/handwrite_character.dart';
import 'package:flashhanzi/home_page.dart';
import 'package:flashhanzi/review_characters.dart';
import 'package:flashhanzi/scan_character.dart';
import 'package:flashhanzi/utils/subscription_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();

  // final isTableEmpty = (await db.select(db.dictionaryEntries).get()).isEmpty;

  // if (isTableEmpty) {
  //   await parse(db);
  // }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(AppEntry(db: db)));
}

class AppEntry extends StatelessWidget {
  final AppDatabase db;
  const AppEntry({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashHanzi',
      theme: ThemeData(
        primaryTextTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          bodyLarge: TextStyle(color: Colors.black87),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFB42F2B),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: InitialLoadingScreen(db: db),
    );
  }
}

class InitialLoadingScreen extends StatefulWidget {
  final AppDatabase db;
  const InitialLoadingScreen({super.key, required this.db});

  @override
  State<InitialLoadingScreen> createState() => _InitialLoadingScreenState();
}

class _InitialLoadingScreenState extends State<InitialLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    await Future.delayed(Duration(seconds: 2));
    final isTableEmpty =
        (await widget.db.select(widget.db.dictionaryEntries).get()).isEmpty;
    if (isTableEmpty) {
      await parse(widget.db);
    }

    await SubscriptionManager().initialize();

    if (!mounted) return;

    if (SubscriptionManager().isProUser) {
      // User is Pro → go to HomePage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage(db: widget.db)),
      );
    } else {
      //TODO: change upon update for subscription functionality
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage(db: widget.db)),
      );
      // User is not Pro → show SubscribePage
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => const SubscribePage()),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen();
  }
}

class MyHomePage extends StatefulWidget {
  final int initialIndex;
  final AppDatabase db;
  const MyHomePage({super.key, required this.initialIndex, required this.db});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _currentIndex;
  final GlobalKey<ReviewCharactersState> _reviewKey =
      GlobalKey<ReviewCharactersState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _currentIndex == 0 ? ScanCharacter(db: widget.db) : const SizedBox(),
          HandwriteCharacter(db: widget.db),
          _currentIndex == 2
              ? ReviewCharacters(key: _reviewKey, db: widget.db)
              : const SizedBox(),
          DictionaryLookup(db: widget.db),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
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
          ),
        ],
      ),
    );
  }
}
