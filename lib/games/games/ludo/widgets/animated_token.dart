import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedLudoToken extends StatefulWidget {
  final Color tokenColor;
  final double size;
  final bool isMoving;
  final bool isSelected;

  const AnimatedLudoToken({
    super.key,
    required this.tokenColor,
    this.size = 40.0,
    this.isMoving = false,
    this.isSelected = false,
  });

  @override
  State<AnimatedLudoToken> createState() => _AnimatedLudoTokenState();
}

class _AnimatedLudoTokenState extends State<AnimatedLudoToken>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -10.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -10.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.3, 0.7, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    if (widget.isMoving) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedLudoToken oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMoving != oldWidget.isMoving) {
      if (widget.isMoving) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }

    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.isMoving ? _bounceAnimation.value : 0),
          child: Transform.rotate(
            angle: widget.isMoving ? _rotationAnimation.value : 0,
            child: Transform.scale(
              scale: widget.isSelected ? _scaleAnimation.value : 1.0,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.tokenColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Center(
          child: Container(
            width: widget.size * 0.6,
            height: widget.size * 0.6,
            decoration: BoxDecoration(
              color: widget.tokenColor.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
