import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedSplashScreen extends StatefulWidget {
  final Widget nextScreen;
  final Duration duration;
  final String imagePath;

  const AnimatedSplashScreen({
    super.key,
    required this.nextScreen,
    this.duration = const Duration(milliseconds: 2000),
    required this.imagePath,
  });

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // More elaborate growing animation sequence
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.2, end: 0.5).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 0.4).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.4, end: 1.0).chain(
          CurveTween(curve: Curves.elasticOut),
        ),
        weight: 1.5,
      ),
    ]).animate(_controller);

    // Coffee cup shaking/rotating animation
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -0.1).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.1).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 2 * math.pi).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 2,
      ),
    ]).animate(_controller);

    _controller.forward();

    // Schedule navigation after animation completes
    Future.delayed(widget.duration + const Duration(milliseconds: 100), () {
      if (mounted) {
        // Only navigate if the widget is still mounted
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => widget.nextScreen,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Using grey[50] as background
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Image.asset(
                  widget.imagePath,
                  width: 300,
                  height: 300,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
