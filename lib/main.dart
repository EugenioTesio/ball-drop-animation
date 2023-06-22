import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final bool _needRepaint = false;
  Offset? _centerOffset;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Throw the ball animation",
      home: Builder(builder: (context) {
        // set the canvas size to the whole screen
        final canvasSize = MediaQuery.of(context).size;

        // calculates the center of the screen
        _centerOffset ??= Offset(canvasSize.width / 2, canvasSize.height / 2);

        // paints the circle placed in the center of the given canvas
        final circleShape = CircleShape(
          needRepaint: _needRepaint,
          center: _centerOffset!,
          radius: 25,
        );
        return Scaffold(
          body: Center(
            child: SizedBox(
              height: canvasSize.height,
              width: canvasSize.width,
              child: ColoredBox(
                color: Colors.amber,
                child: CustomPaint(
                  foregroundPainter: circleShape,
                  size: canvasSize,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Class to draw the circle with a given [center] offset and [radius]. The
/// parameter [needRepaint] is needed to improve performance and not been
/// rebuilding the UI in ever frame
class CircleShape extends CustomPainter {
  final bool needRepaint;
  final Offset center;
  final double radius;

  CircleShape({
    required this.needRepaint,
    required this.center,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff995588)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      center,
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => needRepaint;
}
