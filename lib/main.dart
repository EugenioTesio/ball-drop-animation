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
  bool _needRepaint = false;
  final bool _isAnimationInProgress = false;
  Offset? _centerOffset;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
              child: GestureDetector(
                onPanStart: (details) {
                  // pick the ball only if the animation is not
                  // in progress and the user hits upon the ball
                  if (_isAnimationInProgress == false &&
                      (circleShape.hitTest(details.localPosition) ?? false)) {
                    setState(() {
                      _needRepaint = true;
                    });
                  }
                },
                onPanUpdate: (details) {
                  // prevent to set a new center position for hits out of
                  // the ball bounds and if the animation is in progress as well
                  if (_isAnimationInProgress == false && _needRepaint) {
                    setState(() {
                      _centerOffset = details.localPosition;
                    });
                  }
                },
                child: ColoredBox(
                  color: Colors.amber,
                  child: CustomPaint(
                    foregroundPainter: circleShape,
                    size: canvasSize,
                  ),
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

  @override
  bool? hitTest(Offset position) {
    // Calculate the distance between the position and the center of the circle
    final distance = (position - center).distance;

    // Check if the distance is within the radius of the circle
    if (distance <= radius) {
      return true;
    } else {
      return false;
    }
  }
}
