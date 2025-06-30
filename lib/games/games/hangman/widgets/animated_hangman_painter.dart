
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

      // Define body measurements here so they're available to all drawing sections
      final shoulderHeight = center.dy + headRadius + 5;
      // Reduce the body length to make proportions better
      final waistHeight = shoulderHeight + size.height * 0.1; // Shorter torso
      final shoulderWidth = 16.0;
      final waistWidth = 10.0;

      if (!isGameOver) {
        final pivot = Offset(size.width * 0.5, size.height * 0.1);
        canvas.translate(pivot.dx, pivot.dy);
        canvas.rotate(math.sin(swingAngle) * (0.1));
        canvas.translate(-pivot.dx, -pivot.dy);
      }

      // Define the body points once
      final leftShoulder = Offset(center.dx - shoulderWidth/2, shoulderHeight);
      final rightShoulder = Offset(center.dx + shoulderWidth/2, shoulderHeight);
      final leftHip = Offset(center.dx - waistWidth/2, waistHeight);
      final rightHip = Offset(center.dx + waistWidth/2, waistHeight);

      // Draw in correct order: rope, body parts
      // 1. Rope first
      if (progress >= 1) {
        canvas.drawLine(
            Offset(size.width * 0.55, size.height * 0.1),
            Offset(size.width * 0.55, size.height * 0.22),
            paint
        );
      }

      // 2. Body parts
      if (progress >= 1) {
        canvas.save();

        // Apply head tilt when game is lost
        if (isGameOver) {
          // Tilt head to the right
          canvas.translate(center.dx, center.dy);
          canvas.rotate(math.pi / 12); // Tilt by 15 degrees
          canvas.translate(-center.dx, -center.dy);
        }

        // Head
        canvas.drawCircle(center, headRadius * breatheScale, paint);

        // Add facial features
        final facePaint = Paint()
          ..color = paint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        if (isGameOver) {
          // X eyes
          _drawX(canvas, center.translate(-5, -5), 4, facePaint);
          _drawX(canvas, center.translate(5, -5), 4, facePaint);

          // Sad mouth with tongue sticking out
          // Mouth - open
          final mouthRect = Rect.fromCenter(
              center: center.translate(0, 6),
              width: 10,
              height: 8
          );
          canvas.drawArc(mouthRect, 0, math.pi, false, facePaint);

          // Tongue - fill with red
          final tonguePaint = Paint()
            ..color = Colors.red
            ..style = PaintingStyle.fill;

          final tongueOutline = Paint()
            ..color = Colors.red.shade700
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;

          // Tongue path
          final tonguePath = Path()
            ..moveTo(center.dx - 2, center.dy + 6)
            ..lineTo(center.dx + 2, center.dy + 6)
            ..lineTo(center.dx, center.dy + 12)
            ..close();

          canvas.drawPath(tonguePath, tonguePaint);
          canvas.drawPath(tonguePath, tongueOutline);

        } else if (hasWon) {
          // Happy eyes
          canvas.drawArc(
              Rect.fromCenter(center: center.translate(-5, -5), width: 6, height: 6),
              0, math.pi, false, facePaint
          );
          canvas.drawArc(
              Rect.fromCenter(center: center.translate(5, -5), width: 6, height: 6),
              0, math.pi, false, facePaint
          );

          // Happy mouth
          canvas.drawArc(
              Rect.fromCenter(center: center.translate(0, 5), width: 10, height: 10),
              0, math.pi, false, facePaint
          );
        } else {
          // Worried eyes (small circles)
          canvas.drawCircle(center.translate(-5, -3), 1.5, facePaint);
          canvas.drawCircle(center.translate(5, -3), 1.5, facePaint);

          // Worried eyebrows (angled lines above eyes)
          canvas.drawLine(
              center.translate(-8, -8),
              center.translate(-2, -6),
              facePaint
          );
          canvas.drawLine(
              center.translate(2, -7),
              center.translate(8, -9),
              facePaint
          );

          // Worried mouth (slight frown)
          canvas.drawArc(
              Rect.fromCenter(center: center.translate(0, 5), width: 12, height: 8),
              0.2, math.pi * 0.6, false, facePaint
          );
        }

        canvas.restore(); // Restore after head tilt
      }

      // 3. Body (more realistic with slight curve)
      if (progress >= 2) {
        // Neck
        canvas.drawLine(
            center.translate(0, headRadius),
            center.translate(0, headRadius + 5),
            paint
        );

        // Torso (slightly wider at shoulders, narrower at waist)
        final bodyPath = Path()
          ..moveTo(leftShoulder.dx, leftShoulder.dy)
          ..lineTo(rightShoulder.dx, rightShoulder.dy)
          ..lineTo(rightHip.dx, rightHip.dy)
          ..lineTo(leftHip.dx, leftHip.dy)
          ..close();

        canvas.drawPath(bodyPath, Paint()
          ..color = paint.color
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke);
      }

      // 4. Arms
      if (progress >= 3) {
        // Left arm (with slight bend at elbow)
        final elbowPoint = leftShoulder.translate(-8, 12);
        final handPoint = elbowPoint.translate(-4, 8);

        canvas.drawLine(leftShoulder, elbowPoint, paint);
        canvas.drawLine(elbowPoint, handPoint, paint);
      }

      if (progress >= 4) {
        // Right arm (with slight bend at elbow)
        final elbowPoint = rightShoulder.translate(8, 12);
        final handPoint = elbowPoint.translate(4, 8);

        canvas.drawLine(rightShoulder, elbowPoint, paint);
        canvas.drawLine(elbowPoint, handPoint, paint);
      }

      // 5. Legs
      if (progress >= 5) {
        // Left leg (with slight bend at knee)
        final kneePoint = leftHip.translate(-4, 15);
        final footPoint = kneePoint.translate(-3, 15);

        canvas.drawLine(leftHip, kneePoint, paint);
        canvas.drawLine(kneePoint, footPoint, paint);
      }

      if (progress >= 6) {
        // Right leg (with slight bend at knee)
        final kneePoint = rightHip.translate(4, 15);
        final footPoint = kneePoint.translate(3, 15);

        canvas.drawLine(rightHip, kneePoint, paint);
        canvas.drawLine(kneePoint, footPoint, paint);
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
