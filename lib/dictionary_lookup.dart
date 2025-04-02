import 'package:flutter/material.dart';

class DictionaryLookup extends StatefulWidget {
  const DictionaryLookup({super.key});

  @override
  State<DictionaryLookup> createState() => _DictionaryLookupState();
}

class _DictionaryLookupState extends State<DictionaryLookup> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20), // Space at the top

          const Text(
            'Dictionary Lookup',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20), // Space before the input field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40), // Side padding
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (String value) {
                // Handle the lookup logic here
                doNothing();
              },
            ),
          ),
          const SizedBox(height: 20), // Space before the button
          // ElevatedButton(
          //   onPressed: () {
          //     // Handle the lookup action here
          //     print('Lookup button pressed');
          //   },
          //   child: const Text('Lookup'),
          // ),
          Container(
            height: 240,
            width: 328,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
          ),
        ],
      ),
    );
  }
}

void doNothing() {
  // This function intentionally does nothing.
  // It can be used as a placeholder for button actions.
}
