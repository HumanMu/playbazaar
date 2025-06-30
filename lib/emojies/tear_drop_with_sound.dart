import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class GameOverCryingEmoji extends StatefulWidget {
  final bool isVisible;
  final Duration animationDuration;
  final int maxAnimationRounds;
  final String soundAsset;
  final double volume;

  const GameOverCryingEmoji({
    super.key,
    this.isVisible = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.maxAnimationRounds = 3,
    this.soundAsset = 'assets/sounds/sad/baby_no_no_no.mp3',
    this.volume = 1.0,
  });

  @override
  State<GameOverCryingEmoji> createState() => _GameOverCryingEmojiState();
}

class _GameOverCryingEmojiState extends State<GameOverCryingEmoji>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounceAnimation;
  late final Animation<double> _mouthAnimation;
  AudioPlayer? _soundPlayer;
  bool _isPlaying = false;
  int _animationCount = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initSound();
    if (widget.isVisible) {
      _startCrying();
    }
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..addStatusListener(_handleAnimationStatus);

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _mouthAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (_isDisposed) return;

    if (status == AnimationStatus.completed) {
      _animationCount++;
      if (_animationCount >= widget.maxAnimationRounds * 2) {
        _controller.stop();
        _stopCrying();
      } else {
        _controller.reverse();
      }
    } else if (status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  Future<void> _initSound() async {
    try {
      _soundPlayer = AudioPlayer();
      await _soundPlayer?.setAsset(widget.soundAsset);
      await _soundPlayer?.setVolume(widget.volume);

      _soundPlayer?.playerStateStream.listen((state) {
        if (!mounted || _isDisposed) return;
        if (state.processingState == ProcessingState.completed) {
          _stopCrying();
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
      widget.isVisible ? _startCrying() : _stopCrying();
    }

    if (widget.volume != oldWidget.volume) {
      _soundPlayer?.setVolume(widget.volume);
    }
  }

  Future<void> _startCrying() async {
    if (_isDisposed || _isPlaying) return;

    try {
      setState(() {
        _isPlaying = true;
        _animationCount = 0;
      });

      _controller.forward();
      await _soundPlayer?.seek(Duration.zero);
      await _soundPlayer?.play();
    } catch (e) {
      debugPrint('Error playing sound: $e');
      _isPlaying = false;
    }
  }

  Future<void> _stopCrying() async {
    if (_isDisposed) return;

    try {
      setState(() {
        _isPlaying = false;
      });

      await _soundPlayer?.stop();
      await _soundPlayer?.seek(Duration.zero);
    } catch (e) {
      debugPrint('Error stopping sound: $e');
    }
  }

  Future<void> _restartCrying() async {
    if (_isDisposed || _isPlaying) return;

    await _stopCrying();
    if (!mounted) return;

    setState(() {
      _animationCount = 0;
    });

    _controller.reset();
    await _startCrying();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    _soundPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: GestureDetector(
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
      ),
    );
  }
}

class CryingEmojiPainter extends CustomPainter {
  final Animation<double> animation;
  final Animation<double> mouthAnimation;

  static final Paint _paint = Paint();
  static const Color _tearColor = Color(0xFF7DA4BD);
  static const Color _faceColor = Color(0xFFFF4D00);

  CryingEmojiPainter({
    required this.animation,
    required this.mouthAnimation,
  }) : super(repaint: animation);

  void _drawTear(Canvas canvas, Offset startPoint) {
    final tearPath = Path();
    final tearOffset = 25.0 * animation.value;

    tearPath.moveTo(startPoint.dx, startPoint.dy);
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

    _paint
      ..color = _tearColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(tearPath, _paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Face
    _paint
      ..color = _faceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.4, _paint);

    // Draw features
    _drawEyebrows(canvas, center);
    _drawEyes(canvas, center);
    _drawTears(canvas, center);
    _drawMouth(canvas, center);
  }

  void _drawEyebrows(Canvas canvas, Offset center) {
    _paint
      ..color = Colors.black
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    for (final offset in [-20.0, 20.0]) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx + offset, center.dy - 30),
          width: 30,
          height: 20,
        ),
        offset < 0 ? 0.5 : 0.1,
        2.5,
        false,
        _paint,
      );
    }
  }

  void _drawEyes(Canvas canvas, Offset center) {
    _paint
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (final offset in [-20.0, 20.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + offset, center.dy - 10),
          width: 15,
          height: 20,
        ),
        _paint,
      );
    }
  }

  void _drawTears(Canvas canvas, Offset center) {
    for (final offset in [-15.0, 15.0]) {
      final tearStart = Offset(center.dx + offset, center.dy + 5);
      _drawTear(canvas, tearStart);

      _paint
        ..color = _tearColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(tearStart.dx, tearStart.dy + 50 + (10 * animation.value)),
        3,
        _paint,
      );
    }
  }

  void _drawMouth(Canvas canvas, Offset center) {
    final mouthOpenness = 15.0 * mouthAnimation.value;
    final path = Path();

    path.moveTo(center.dx - 30, center.dy + 30);
    path.quadraticBezierTo(
      center.dx,
      center.dy + 40 + mouthOpenness,
      center.dx + 30,
      center.dy + 30,
    );

    // Draw mouth interior
    _paint
      ..style = PaintingStyle.fill
      ..color = Colors.black.withAlpha(204);
    canvas.drawPath(path, _paint);

    // Draw mouth outline
    _paint
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawPath(path, _paint);

    // Draw quivers
    for (final offset in [-1.0, 1.0]) {
      canvas.drawLine(
        Offset(center.dx + (30 * offset), center.dy + 30),
        Offset(center.dx + (35 * offset), center.dy + 28),
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(CryingEmojiPainter oldDelegate) => true;
}
