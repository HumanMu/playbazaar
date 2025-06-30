import 'package:flutter/material.dart';

class KeyboardButton extends StatelessWidget {
  final String letter;
  final VoidCallback? onPressed;
  final bool isGameOver;
  final bool isCorrectGuess;

  const KeyboardButton({
    required this.letter,
    required this.onPressed,
    required this.isGameOver,
    required this.isCorrectGuess,
    super.key,
  });

  Color _getButtonColor() {
    if (isGameOver) {
      return isCorrectGuess ? Colors.green : Colors.red.shade300;
    }
    return onPressed == null ? Colors.grey : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(60, 40),
        backgroundColor: _getButtonColor(),
        foregroundColor: Colors.white,
        padding: EdgeInsets.zero,
      ),
      onPressed: onPressed,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


/*class AnimatedKeyboardButton extends StatefulWidget {
  final String letter;
  final VoidCallback? onPressed;
  final bool isGameOver;
  final bool isCorrectGuess;
  final int index;

  const AnimatedKeyboardButton({
    required this.letter,
    required this.onPressed,
    required this.isGameOver,
    required this.isCorrectGuess,
    required this.index,
    super.key,
  });

  @override
  State<AnimatedKeyboardButton> createState() => _AnimatedKeyboardButtonState();
}

class _AnimatedKeyboardButtonState extends State<AnimatedKeyboardButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.isCorrectGuess ? 1.2 : 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: widget.isCorrectGuess ? 1.0 : 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedKeyboardButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGameOver && !oldWidget.isGameOver) {
      Future.delayed(Duration(milliseconds: widget.index * 50), () {
        _controller.forward();
      });
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isCorrectGuess && widget.isGameOver
                    ? Colors.green
                    : Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: widget.onPressed,
              child: Text(
                widget.letter,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}*/
