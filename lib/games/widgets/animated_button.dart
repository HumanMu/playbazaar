import 'package:flutter/material.dart';

class ZAxisAnimatedButton extends StatefulWidget {
  final Widget child; // The button or widget you want to animate
  final VoidCallback onPressed;
  final Duration animationDuration;
  final double rotationAngle; // The angle for the z-axis rotation effect

  const ZAxisAnimatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.animationDuration = const Duration(milliseconds: 300),
    this.rotationAngle = 0.15, // Default rotation angle
  });

  @override
  State<ZAxisAnimatedButton> createState() => _ZAxisAnimatedButtonState();
}

class _ZAxisAnimatedButtonState extends State<ZAxisAnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed(); // Call the onPressed callback
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: _isPressed ? 0.9 : 1.0),
        duration: widget.animationDuration,
        builder: (context, value, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective for z-axis effect
              ..rotateX((1 - value) * widget.rotationAngle), // Animate rotation
            alignment: Alignment.center,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
