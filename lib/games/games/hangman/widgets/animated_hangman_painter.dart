import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedHangmanPainter extends CustomPainter {
  final double progress;
  final int incorrectGuesses;
  final bool isGameOver;
  final bool hasWon;
  final double swingAngle;
  final double breatheScale;

  AnimatedHangmanPainter({
    required this.progress,
    required this.incorrectGuesses,
    this.isGameOver = false,
    this.hasWon = false,
    this.swingAngle = 0,
    this.breatheScale = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintGallows = Paint()
      ..color = Colors.red.shade900
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paint = Paint()
      ..color = hasWon ? Colors.green : (isGameOver ? Colors.red : Colors.red.shade700)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw gallows first
    _drawGallows(canvas, size, paintGallows);

    if (incorrectGuesses > 0) {
      canvas.save();

      final center = Offset(size.width * 0.55, size.height * 0.3);
      final headRadius = size.width * 0.07;

      if (!isGameOver) {
        final pivot = Offset(size.width * 0.5, size.height * 0.1);
        canvas.translate(pivot.dx, pivot.dy);
        canvas.rotate(math.sin(swingAngle) * (0.1));
        canvas.translate(-pivot.dx, -pivot.dy);
      }

      // Draw in correct order: rope, arms (behind body), body, head, legs
      // 1. Rope first
      if (progress >= 1) {
        canvas.drawLine(
            Offset(size.width * 0.55, size.height * 0.1),
            Offset(size.width * 0.55, size.height * 0.22),
            paint
        );
      }

      // 2. Draw arms if they exist (BEFORE body)
      if (progress >= 3) {
        // Left arm
        canvas.drawLine(
            center.translate(0, headRadius + 10),
            center.translate(-20, headRadius + 30),
            paint
        );
      }

      if (progress >= 4) {
        // Right arm
        canvas.drawLine(
            center.translate(0, headRadius + 10),
            center.translate(20, headRadius + 30),
            paint
        );
      }

      // 3. Body
      if (progress >= 2) {
        canvas.drawLine(
            center.translate(0, headRadius),
            center.translate(0, size.height * 0.25),
            paint
        );
      }

      // 4. Head (drawn after body so it appears in front)
      if (progress >= 1) {
        canvas.drawCircle(center, headRadius * breatheScale, paint);

        if (isGameOver || hasWon) {
          final facePaint = Paint()
            ..color = paint.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;

          // Eyes
          if (hasWon) {
            // Happy eyes
            canvas.drawArc(
                Rect.fromCenter(center: center.translate(-5, -5), width: 6, height: 6),
                0, math.pi, false, facePaint
            );
            canvas.drawArc(
                Rect.fromCenter(center: center.translate(5, -5), width: 6, height: 6),
                0, math.pi, false, facePaint
            );
          } else {
            // X eyes
            _drawX(canvas, center.translate(-5, -5), 4, facePaint);
            _drawX(canvas, center.translate(5, -5), 4, facePaint);
          }

          // Mouth
          canvas.drawArc(
              Rect.fromCenter(center: center.translate(0, 5), width: 10, height: 10),
              hasWon ? 0 : math.pi, math.pi, false, facePaint
          );
        }
      }

      // 5. Legs (drawn last)
      if (progress >= 5) {
        canvas.drawLine(
            center.translate(0, size.height * 0.25),
            center.translate(-20, size.height * 0.35),
            paint
        );
      }

      if (progress >= 6) {
        canvas.drawLine(
            center.translate(0, size.height * 0.25),
            center.translate(20, size.height * 0.35),
            paint
        );
      }

      canvas.restore();
    }
  }

  void _drawGallows(Canvas canvas, Size size, Paint paint) {
    // Base
    canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.8),
        Offset(size.width * 0.4, size.height * 0.8),
        paint
    );

    // Vertical post
    canvas.drawLine(
        Offset(size.width * 0.3, size.height * 0.8),
        Offset(size.width * 0.3, size.height * 0.1),
        paint
    );

    // Horizontal beam
    canvas.drawLine(
        Offset(size.width * 0.3, size.height * 0.1),
        Offset(size.width * 0.7, size.height * 0.1),
        paint
    );

    // Support beam
    canvas.drawLine(
        Offset(size.width * 0.3, size.height * 0.3),
        Offset(size.width * 0.5, size.height * 0.1),
        paint
    );
  }

  void _drawX(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawLine(
        center.translate(-size/2, -size/2),
        center.translate(size/2, size/2),
        paint
    );
    canvas.drawLine(
        center.translate(-size/2, size/2),
        center.translate(size/2, -size/2),
        paint
    );
  }

  @override
  bool shouldRepaint(covariant AnimatedHangmanPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.incorrectGuesses != incorrectGuesses ||
        oldDelegate.isGameOver != isGameOver ||
        oldDelegate.hasWon != hasWon ||
        oldDelegate.swingAngle != swingAngle ||
        oldDelegate.breatheScale != breatheScale;
  }
}