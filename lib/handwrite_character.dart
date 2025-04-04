import 'package:flashhanzi/home_page.dart';
import 'package:flutter/material.dart';

class HandwriteCharacter extends StatefulWidget {
  const HandwriteCharacter({super.key});

  @override
  State<HandwriteCharacter> createState() => _HandwriteCharacterState();
}

class _HandwriteCharacterState extends State<HandwriteCharacter> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 20),
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
                      MaterialPageRoute(builder: (context) => HomePage()),
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
          Container(
            height: 340,
            width: 340,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
          ),
          SizedBox(height: 20), // Space before the buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40), // Side padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Clear Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: doNothing,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.black, // Text color
                          fontSize: 16, // Font size
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Space between buttons
                // Recognize Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: doNothing,
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

          // Center the buttons
        ],
      ),
    );
  }
}

void doNothing() {}
