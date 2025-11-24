import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helper/functions.dart';
import '../controller/dice_controller.dart';

class ModernDiceWidget extends StatefulWidget {
  final double? size;

  const ModernDiceWidget({
    super.key,
    this.size,
  });

  @override
  State<ModernDiceWidget> createState() => _ModernDiceWidgetState();
}

class _ModernDiceWidgetState extends State<ModernDiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _bounceAnimation;
  final diceController = Get.find<DiceController>();
  int _animatingValue = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60.0,
      ),
    ]).animate(_controller);

    // Listen for dice rolling state changes
    ever(diceController.dice.rxIsRolling, _handleRollingStateChange);
    _controller.addListener(_updateAnimatingValue);
  }

  void _handleRollingStateChange(bool isRolling) {
    if (isRolling && !_controller.isAnimating) {
      _controller.forward(from: 0.0);
    }
  }

  void _updateAnimatingValue() {
    if (diceController.dice.rxIsRolling.value) {
      if (_controller.value < 0.8) {
        setState(() {
          _animatingValue = math.Random().nextInt(6) + 1;
        });
      } else {
        setState(() {
          _animatingValue = diceController.diceValue;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateAnimatingValue);
    _controller.dispose();
    super.dispose();
  }

  void _handleDiceTap() {
    if (diceController.dice.canBeRolledByHuman) {
      diceController.handleDiceRoll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final diceValue = diceController.diceValue;
      final diceColor = diceController.color;
      final isRolling = diceController.dice.rxIsRolling.value;
      final isRobotTurn = diceController.isRobotTurn;
      final isInteractive = diceController.dice.rollState && !isRobotTurn;
      final color = LudoHelper.getTokenColor(diceColor);

      // Calculate dice size with constraints
      // Default is 15% of screen width
      double calculatedSize = widget.size ?? (MediaQuery.of(context).size.width * 0.15);

      // Apply min/max constraints
      calculatedSize = calculatedSize.clamp(55.0, 70.0);

      return GestureDetector(
        onTap: _handleDiceTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isInteractive ? 1.0 : 0.8,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: Card(
                  elevation: isInteractive ? 10 : 5,
                  shadowColor: color.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(calculatedSize * 0.2),
                  ),
                  child: SizedBox(
                    height: calculatedSize,
                    width: calculatedSize,
                    child: Stack(
                      children: [
                        // Shadow under dice
                        if (_bounceAnimation.value > 1.05)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(calculatedSize * 0.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                            ),
                          ),
                        // Dice face
                        Transform.rotate(
                          angle: _animation.value * math.pi * 2 * 3,
                          child: CustomPaint(
                            painter: DicePainter(
                              value: isRolling ? _animatingValue : diceValue,
                              color: color,
                              animationValue: _animation.value,
                              isRolling: isRolling,
                            ),
                            size: Size.square(calculatedSize),
                          ),
                        ),
                        // Robot indicator
                        if (isRobotTurn)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(calculatedSize * 0.2),
                              ),
                              child: Icon(
                                Icons.smart_toy,
                                size: calculatedSize * 0.4,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        // Non-interactive indicator
                        if (!isInteractive && !isRobotTurn && !isRolling)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(calculatedSize * 0.2),
                              ),
                              child: Icon(
                                Icons.not_interested,
                                size: calculatedSize * 0.4,
                                color: Colors.black26,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

// DicePainter class remains the same
class DicePainter extends CustomPainter {
  final int value;
  final Color color;
  final double animationValue;
  final bool isRolling;

  DicePainter({
    required this.value,
    required this.color,
    required this.animationValue,
    required this.isRolling,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final diceSize = size.width * 0.85;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw dice body
    final diceRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: diceSize,
      height: diceSize,
    );

    // Create a richer 3D effect with gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withValues(alpha: 1.0),
        color.withValues(alpha: 0.8),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(diceRect)
      ..style = PaintingStyle.fill;

    // Apply a wobble effect during animation
    double wobbleFactor = isRolling ? (1 - math.cos(animationValue * 15)) * 2 : 0;

    // Modified rect for wobble effect
    final wobbleRect = Rect.fromCenter(
      center: Offset(
        centerX + wobbleFactor * math.cos(animationValue * 10) * 2,
        centerY + wobbleFactor * math.sin(animationValue * 10) * 2,
      ),
      width: diceSize,
      height: diceSize,
    );

    // Draw base with rounded corners
    final rrect = RRect.fromRectAndRadius(
      wobbleRect,
      Radius.circular(diceSize * 0.2),
    );
    canvas.drawRRect(rrect, paint);

    // Add border for better definition
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, borderPaint);

    // Add inner shadow effect
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 3);
    canvas.drawRRect(rrect, shadowPaint);

    // Draw dots with proper layering
    _drawDots(canvas, centerX, centerY, diceSize, value, wobbleFactor);
  }

  void _drawDots(Canvas canvas, double centerX, double centerY, double diceSize,
      int value, double wobbleFactor) {
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotSize = diceSize * 0.13;
    final offset = diceSize * 0.25;

    // Calculate dot positions based on dice value with wobble effect
    double wobbleX = isRolling ? wobbleFactor * math.sin(animationValue * math.pi * 4) * 2 : 0;
    double wobbleY = isRolling ? wobbleFactor * math.cos(animationValue * math.pi * 4) * 2 : 0;

    List<Offset> dotPositions = [];

    switch (value) {
      case 1:
        dotPositions = [Offset(centerX, centerY)];
        break;
      case 2:
        dotPositions = [
          Offset(centerX - offset, centerY - offset),
          Offset(centerX + offset, centerY + offset),
        ];
        break;
      case 3:
        dotPositions = [
          Offset(centerX - offset, centerY - offset),
          Offset(centerX, centerY),
          Offset(centerX + offset, centerY + offset),
        ];
        break;
      case 4:
        dotPositions = [
          Offset(centerX - offset, centerY - offset),
          Offset(centerX + offset, centerY - offset),
          Offset(centerX - offset, centerY + offset),
          Offset(centerX + offset, centerY + offset),
        ];
        break;
      case 5:
        dotPositions = [
          Offset(centerX - offset, centerY - offset),
          Offset(centerX + offset, centerY - offset),
          Offset(centerX, centerY),
          Offset(centerX - offset, centerY + offset),
          Offset(centerX + offset, centerY + offset),
        ];
        break;
      case 6:
        dotPositions = [
          Offset(centerX - offset, centerY - offset),
          Offset(centerX + offset, centerY - offset),
          Offset(centerX - offset, centerY),
          Offset(centerX + offset, centerY),
          Offset(centerX - offset, centerY + offset),
          Offset(centerX + offset, centerY + offset),
        ];
        break;
      default:
      // Fallback to 1 if invalid value
        dotPositions = [Offset(centerX, centerY)];
    }

    // Draw each dot with its own wobble effect
    for (var position in dotPositions) {
      final adjustedPosition = Offset(
        position.dx + wobbleX,
        position.dy + wobbleY,
      );
      _drawDot(canvas, adjustedPosition.dx, adjustedPosition.dy, dotSize, dotPaint);
    }
  }

  void _drawDot(Canvas canvas, double x, double y, double size, Paint paint) {
    // Draw main dot
    canvas.drawCircle(Offset(x, y), size, paint);

    // Add a small highlight to each dot for a 3D effect
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x - size * 0.3, y - size * 0.3), size * 0.3, highlightPaint);

    // Add a small shadow under each dot
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(x + size * 0.1, y + size * 0.1), size * 0.9, shadowPaint);
  }

  @override
  bool shouldRepaint(DicePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isRolling != isRolling;
  }
}


