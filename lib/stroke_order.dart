import 'package:flutter/material.dart';
import 'package:stroke_order_animator/stroke_order_animator.dart'; // Import stroke order animator library

// Define the StrokeOrder class to represent the stroke data.

// ignore: must_be_immutable
class StrokeOrderWidget extends StatefulWidget {
  final String character; // The stroke order data to display animation for.
  Map<String, String> dataMap;
  StrokeOrderWidget({
    super.key,
    required this.character,
    required this.dataMap,
  });

  @override
  // ignore: library_private_types_in_public_api
  _StrokeOrderWidgetState createState() => _StrokeOrderWidgetState();
}

class _StrokeOrderWidgetState extends State<StrokeOrderWidget>
    with TickerProviderStateMixin {
  late StrokeOrderAnimationController _completedController;
  late Future<StrokeOrderAnimationController> _animationController;

  @override
  void initState() {
    super.initState();
    // Load stroke data asynchronously
    _animationController = _loadStrokeOrder(widget.character, widget.dataMap);
  }

  // Async method to load data
  // Future<void> _loadData() async {
  //   // Load stroke data asynchronously
  //   Map<String, String> dataMap = await loadStrokeData();
  //   // Pass the data map along with the character to _loadStrokeOrder
  //   _animationController = _loadStrokeOrder(widget.character, dataMap);
  //   setState(() {});
  // }

  // Dispose the controller when it's no longer needed.
  @override
  void dispose() {
    _completedController.dispose();
    super.dispose();
  }

  // Loads the stroke order for the character.
  Future<StrokeOrderAnimationController> _loadStrokeOrder(
    String character,
    Map<String, String>
    strokeDataMap, // Map where the character key maps to the JSON string
  ) async {
    // Retrieve the JSON string for the given character from the map
    final strokeDataJson = strokeDataMap[character];

    if (strokeDataJson == null) {
      // Handle the case where the character does not exist in the map
      throw Exception("Stroke data for character '$character' not found");
    }

    // Use the retrieved JSON string to create the StrokeOrderAnimationController
    final controller = StrokeOrderAnimationController(
      StrokeOrder(strokeDataJson), // Pass the JSON string here
      this,
    );
    controller.startAnimation();
    return controller;
  }

  // Builds the stroke order animation.
  Widget _buildStrokeOrderAnimation(StrokeOrderAnimationController controller) {
    return StrokeOrderAnimator(
      controller,
      size: Size(150, 150), // Set the size of the animation area
      key: UniqueKey(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StrokeOrderAnimationController>(
      future: _animationController,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator while waiting.
        }

        if (snapshot.hasData) {
          // When data is available, build the animation view.
          return Column(children: [_buildStrokeOrderAnimation(snapshot.data!)]);
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Handle error state.
        }

        return SizedBox.shrink(); // Return empty widget if no data is available.
      },
    );
  }
}
