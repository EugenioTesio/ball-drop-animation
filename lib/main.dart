import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  bool _needRepaint = false;
  bool _isAnimationInProgress = false;
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
                onPanEnd: (details) {
                  // prevent to set a new center position for hits out of
                  // the ball bounds and if the animation is in progress as well
                  if (_isAnimationInProgress == false && _needRepaint) {
                    _runAnimation(
                      details.velocity.pixelsPerSecond,
                      const Size(50, 50),
                      canvasSize,
                    );
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

  /// Calculates and runs a [SpringSimulation].
  void _runAnimation(
    Offset pixelsPerSecond,
    Size objectSize,
    Size canvasSize,
  ) {
    _isAnimationInProgress = true;

    // create an unbounded because physis simulations don't have bounds
    final controller = AnimationController.unbounded(
      vsync: this,
    );

    final velocityPixelsPerSecond = pixelsPerSecond.distance;

    // creates a FrictionSimulation. The drag parameter goes from 1 (infinite
    // friction) to 0 (none friction). The position parameter tell the flutter
    // engine in witch point should start to refresh the UI; e.g. if the
    // velocity is 100 pixel/sec, position is 200 and none friction will start
    // to send updates on the 2nd sec
    final simulation = FrictionSimulation(0.05, 0, velocityPixelsPerSecond);

    // the angle in radians from 0 to pi for +y and 0 to -pi for -y
    var direction = pixelsPerSecond.direction;

    // as the controller always increment the value this variable is needed
    // to get the differential increment
    var walkedDistance = 0.0;

    controller.addListener(() {
      setState(() {
        // differential offset is the incremental point from the last frame
        final differentialOffset =
            Offset.fromDirection(direction, controller.value - walkedDistance);

        // calculates the new center with the given increment
        _centerOffset = Offset(_centerOffset!.dx + differentialOffset.dx,
            _centerOffset!.dy + differentialOffset.dy);

        // update walkedDistance to get the differentialOffset in next frame
        walkedDistance = controller.value;
      });
    });

    // run the animation and dispose the controller when finish
    controller.animateWith(simulation).whenComplete(() {
      setState(() {
        _needRepaint = false;
        _isAnimationInProgress = false;
        controller.dispose();
      });
    });
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
