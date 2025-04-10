import 'package:flashhanzi/parse.dart';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class StrokePainter extends CustomPainter {
  final List<String> strokes;

  StrokePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..isAntiAlias = true;

    final double scale = size.width / 1024; // scale strokes to canvas size

    for (final svg in strokes) {
      final path = parseSvgPathData(svg);
      final offsetX = (size.width - 1024 * scale) / 2;
      final offsetY = (size.height - 1024 * scale) / 2;

      final matrix =
          Matrix4.identity()
            ..translate(offsetX, offsetY + 1024 * scale) // move down then flip
            ..scale(scale, -scale); // Flip Y

      final flipped = path.transform(matrix.storage);
      canvas.drawPath(flipped, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CharacterStrokeView extends StatelessWidget {
  final StrokeData strokeData;

  const CharacterStrokeView({super.key, required this.strokeData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(painter: StrokePainter(strokeData.strokes)),
    );
  }
}
