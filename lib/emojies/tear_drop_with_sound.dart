import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class GameOverCryingEmoji extends StatefulWidget {
  final bool isVisible;

  const GameOverCryingEmoji({
    super.key,
    this.isVisible = true,
  });

  @override
  State<GameOverCryingEmoji> createState() => _GameOverCryingEmojiState();
}

class _GameOverCryingEmojiState extends State<GameOverCryingEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _mouthAnimation;
  late AudioPlayer _soundPlayer;
  bool _isPlaying = false;
  int _animationCount = 0;
  static const int maxAnimationRounds = 3;

  @override
  void initState() {
    super.initState();

    // Setup animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationCount++;
        if (_animationCount >= maxAnimationRounds * 2) { // Multiply by 2 because of forward/reverse cycles
          _controller.stop();
          _stopCrying();
        } else {
          _controller.reverse();
        }
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });


    // Create bounce animation
    _bounceAnimation = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Create mouth animation
    _mouthAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _initSound();
    if (widget.isVisible) {
      _startCrying();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _stopCrying();
    _soundPlayer.stop();
    super.dispose();
  }


  Future<void> _initSound() async {
    try {
      _soundPlayer = AudioPlayer();
      await _soundPlayer.setAsset('assets/sounds/sad/baby_no_no_no.mp3');
      _soundPlayer.setVolume(1.0);

      // Add completion listener
      _soundPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _stopCrying();  // Stop when audio completes
        }
      });

    } catch (e) {
      debugPrint('Error initializing sound player for crying emoji: $e');
    }
  }

  @override
  void didUpdateWidget(GameOverCryingEmoji oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _startCrying();
      } else {
        _stopCrying();
      }
    }
  }

  Future<void> _startCrying() async {
    try {
      if (!_isPlaying ) {
        setState(() {
          _isPlaying = true;

        });
        _animationCount = 0;
        _controller.forward();
        await _soundPlayer.seek(Duration.zero);
        await _soundPlayer.play();
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> _stopCrying() async {
    try {
      setState(() {
        _isPlaying = false;
      });
      await _soundPlayer.stop();
      await _soundPlayer.seek(Duration.zero);
    } catch (e) {
      debugPrint('Error stopping sound: $e');
    }
  }

  void _restartCrying() async {
    if (!_isPlaying) {
      await _stopCrying();  // First stop everything
      setState(() {
        _animationCount = 0;
      });
      // Reset animation controller to initial state
      _controller.reset();  // Add this line
      _startCrying();
    }
  }


  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _restartCrying,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: CustomPaint(
              size: const Size(200, 200),
              painter: CryingEmojiPainter(
                animation: _controller,
                mouthAnimation: _mouthAnimation,
              ),
            ),
          );
        },
      ),
    );
  }
}

class CryingEmojiPainter extends CustomPainter {
  final Animation<double> animation;
  final Animation<double> mouthAnimation;

  CryingEmojiPainter({
    required this.animation,
    required this.mouthAnimation
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Face
    final paint = Paint()
      ..color = const Color(0xFFFF4D00)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.4, paint);

    // Eyebrow
    paint
      ..color = Colors.black
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    // Left eyebrow
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx - 20, center.dy - 30),
        width: 30,
        height: 20,
      ),
      0.5, // Start angle
      2.5, // Sweep angle
      false,
      paint,
    );

    // Right eyebrow
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx + 20, center.dy - 30),
        width: 30,
        height: 20,
      ),
      0.1, // Start angle
      2.5, // Sweep angle
      false,
      paint,
    );

    // Eyes
    paint
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Left eye
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - 20, center.dy - 10),
        width: 15,
        height: 20,
      ),
      paint,
    );

    // Right eye
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + 20, center.dy - 10),
        width: 15,
        height: 20,
      ),
      paint,
    );


    // Multiple tears with different sizes for more dramatic effect
    paint.color = const Color(0xFF88E3E3); // Lighter blue for tears

    // Left tears stream
    paint
      ..color = const Color(0xFF88C1E5)
      ..style = PaintingStyle.fill;

    // Function to draw a single long tear
    void drawLongTear(Offset startPoint) {
      final tearPath = Path();
      final tearOffset = 25.0 * animation.value;

      // Start point of the tear
      tearPath.moveTo(startPoint.dx, startPoint.dy);

      // Create curved tear drop shape
      tearPath.quadraticBezierTo(
        startPoint.dx - 8,
        startPoint.dy + 20 + tearOffset,
        startPoint.dx,
        startPoint.dy + 40 + tearOffset,
      );

      tearPath.quadraticBezierTo(
        startPoint.dx + 4,
        startPoint.dy + 20 + tearOffset,
        startPoint.dx,
        startPoint.dy,
      );

      canvas.drawPath(tearPath, paint);
    }

    // Function to draw a dot tear
    void drawDotTear(Offset center, double size) {
      canvas.drawCircle(center, size, paint);
    }

    // Left eye tears
    final leftTearStart = Offset(center.dx - 15, center.dy + 5);
    drawLongTear(leftTearStart);
    drawDotTear(
      Offset(leftTearStart.dx, leftTearStart.dy + 50 + (10 * animation.value)),
      3,
    );

    // Right eye tears
    final rightTearStart = Offset(center.dx + 15, center.dy + 5);
    drawLongTear(rightTearStart);
    drawDotTear(
      Offset(rightTearStart.dx, rightTearStart.dy + 50 + (10 * animation.value)),
      3,
    );


    // Frowning mouth
    final mouthOpenness = 15.0 * mouthAnimation.value;
    final mouthWidth = 50.0; // Total width of mouth
    final path = Path();

    // Starting point (left side of mouth)
    path.moveTo(center.dx - 30, center.dy + 30);
    final controlY = center.dy + 40 + mouthOpenness;
    path.quadraticBezierTo(
      center.dx, // Control point X
      controlY,  // Control point Y - moves down with animation
      center.dx + 30, // End point X
      center.dy + 30, // End point Y
    );
    canvas.drawPath(path, paint);


    final mouthRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 30),
        width: mouthWidth,
        height: 5 + mouthOpenness, // Height varies with animation
      ),
      const Radius.circular(10),
    );

    // Draw mouth interior
    paint
      ..style = PaintingStyle.fill
      ..color = Colors.black.withAlpha((0.8 * 255).toInt());
    canvas.drawRRect(mouthRect, paint);

    paint
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawPath(path, paint);

    // Left quiver
    canvas.drawLine(
      Offset(center.dx - 30, center.dy + 30),
      Offset(center.dx - 35, center.dy + 28),
      paint,
    );

    // Right quiver
    canvas.drawLine(
      Offset(center.dx + 30, center.dy + 30),
      Offset(center.dx + 35, center.dy + 28),
      paint,
    );
  }

  @override
  bool shouldRepaint(CryingEmojiPainter oldDelegate) => true;
}