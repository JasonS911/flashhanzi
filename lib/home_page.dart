import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: Colors.black87, // Set a neutral default color
            decoration: TextDecoration.none, // Remove default underline
          ),
        ),
      ),
      home:
          const HomePage(), // Correctly uses the 'home' parameter of MaterialApp.router
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Sets the background color of the page
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        // Makes the entire page scrollable
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Centers children horizontally
          children: [
            Image.asset(
              'lib/assets/logo.png', // Ensure you have a logo image in the assets folder
              height: 100, // Adjust height as needed
              width: 260, // Adjust width as needed
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 0,
                left: 4,
                right: 4,
                bottom: 4,
              ),
              child: Container(
                width: double.infinity, // Makes the container full width
                height: 200,
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Aligns children to the start
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                      ), // Adds space at the top
                      child: Text(
                        'Word of the Day',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          decoration:
                              TextDecoration
                                  .none, // Remove underline from the title
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '好',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              decoration:
                                  TextDecoration.none, // Remove underline
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 12,
                              bottom: 8,
                            ), // Adds space between character and text
                            child: Text(
                              'hāo', // Pinyin with tone
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Good; well',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none, // Remove underline
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        '她是一个好人',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none, // Remove underline
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Tā shì yí gè hǎo rén',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none, // Remove underline
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ), // Adds space at the top
            SizedBox(
              height: 4,
            ), // Adds space between the word of the day and the next section
            Text(
              '5 Characters due today', // Display the first sentence
              style: GoogleFonts.notoSansSc(
                fontSize: 20,
                color: Colors.black87,
                decoration: TextDecoration.none, // Remove underline
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16),
            // Adds space between sentences
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ), // Adds space on the left and right
              child: GridView.count(
                crossAxisCount: 2, // Number of columns
                childAspectRatio: 1, // Aspect ratio for each grid item
                mainAxisSpacing: 2, // Space between rows
                crossAxisSpacing: 2, // Space between columns
                physics: NeverScrollableScrollPhysics(), // Disables scrolling
                shrinkWrap:
                    true, // Ensures GridView takes only the required space
                children: [
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: _ActionTile(
                      label: 'Scan Character',
                      icon: Icons.camera_alt,
                      onTap: doNothing, // Replace with your scan function
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: _ActionTile(
                      label: 'Handwrite Character',
                      icon: Icons.brush,
                      onTap: doNothing, // Replace with your scan function
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: _ActionTile(
                      label: 'Review Characters',
                      icon: Icons.book,
                      onTap: doNothing, // Replace with your scan function
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4),
                    child: _ActionTile(
                      label: 'Search Characters',
                      icon: Icons.search,
                      onTap: doNothing, // Replace with your scan function
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36),
              const SizedBox(height: 12),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

void doNothing() {
  // This function intentionally left blank to avoid any action.
  // It can be used as a placeholder for future functionality or to prevent errors.
  // For example, it can be used in callbacks where no action is needed.
}
