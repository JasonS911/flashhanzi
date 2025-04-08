import 'package:flashhanzi/database/database.dart';
import 'package:flashhanzi/home_page.dart';
import 'package:flutter/material.dart';

class DoneStudying extends StatelessWidget {
  const DoneStudying({super.key, required this.db});
  final AppDatabase db;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'Done studying for today!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: TextDecoration.none, // Remove underline
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(db: db)),
              );
            },
            child: const Text(
              'Go Home',
              style: TextStyle(color: Color(0xFFB42F2B)),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(db: db)),
              );
            },
            child: const Text('Review All Cards'),
          ),
          SizedBox(height: 16),
        ],
      ),
    ); //
  }
}
