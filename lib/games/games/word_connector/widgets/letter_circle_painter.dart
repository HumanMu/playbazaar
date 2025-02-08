import 'dart:math';
import 'package:flutter/material.dart';

class LetterCirclePosition {
  final String letter;
  final int index;
  final Offset position;

  LetterCirclePosition({
    required this.letter,
    required this.index,
    required this.position,
  });
}

class LetterCirclePainter extends CustomPainter {
  final List<String> letters;
  final List<int> selectedIndices;
  final List<LetterCirclePosition> letterPositions;
  final Offset? currentLineEnd;
  final Size size;

  // Cache for frequently used values
  late final Paint _circlePaint;
  late final Paint _selectedCirclePaint;
  late final Paint _borderPaint;
  late final Paint _selectedBorderPaint;
  late final Paint _linePaint;
  late final TextStyle _normalTextStyle;
  late final TextStyle _selectedTextStyle;

  LetterCirclePainter({
    required this.letters,
    required this.selectedIndices,
    required this.letterPositions,
    required this.currentLineEnd,
    required this.size,
  }) {
    // Initialize cached paint objects
    _circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    _selectedCirclePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    _borderPaint = Paint()
      ..color = Colors.green.withAlpha(102) // equivalent to withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _selectedBorderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3;

    _normalTextStyle = const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    _selectedTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.35;

    // Draw background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.green.withAlpha(51) // equivalent to withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );

    // Calculate and draw letter circles
    final letterRadius = 25.0;
    letterPositions.clear();

    for (var i = 0; i < letters.length; i++) {
      final letter = letters[i];
      final angle = -pi / 2 + (2 * pi * i / letters.length);
      final letterPos = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      final isSelected = selectedIndices.contains(i);

      // Draw letter circles
      canvas.drawCircle(
        letterPos,
        letterRadius,
        isSelected ? _selectedCirclePaint : _circlePaint,
      );

      // Draw letter circle borders
      canvas.drawCircle(
        letterPos,
        letterRadius,
        isSelected ? _selectedBorderPaint : _borderPaint,
      );

      // Draw letters
      final textPainter = TextPainter(
        text: TextSpan(
          text: letter,
          style: isSelected ? _selectedTextStyle : _normalTextStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        letterPos.translate(-textPainter.width / 2, -textPainter.height / 2),
      );

      // Store position with index
      letterPositions.add(LetterCirclePosition(
        letter: letter,
        index: i,
        position: letterPos,
      ));
    }

    // Draw lines between selected indices
    if (selectedIndices.isNotEmpty) {
      for (var i = 0; i < selectedIndices.length - 1; i++) {
        final startIndex = selectedIndices[i];
        final endIndex = selectedIndices[i + 1];
        final startPos = letterPositions[startIndex].position;
        final endPos = letterPositions[endIndex].position;
        canvas.drawLine(startPos, endPos, _linePaint);
      }

      // Draw line to current touch position if available
      if (currentLineEnd != null && selectedIndices.isNotEmpty) {
        final lastIndex = selectedIndices.last;
        final lastPos = letterPositions[lastIndex].position;
        canvas.drawLine(lastPos, currentLineEnd!, _linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LetterCirclePainter oldDelegate) {
    return oldDelegate.selectedIndices != selectedIndices ||
        oldDelegate.currentLineEnd != currentLineEnd ||
        oldDelegate.letters != letters;
  }
}





/*class LetterCirclePainter extends CustomPainter {
  final List<String> letters;
  final List<String> selectedLetters;
  final Map<String, Offset> letterPositions;
  final Offset? currentLineEnd;
  final Size size;

  // Cache for frequently used values
  late final Paint _circlePaint;
  late final Paint _selectedCirclePaint;
  late final Paint _borderPaint;
  late final Paint _selectedBorderPaint;
  late final Paint _linePaint;
  late final TextStyle _normalTextStyle;
  late final TextStyle _selectedTextStyle;

  LetterCirclePainter({
    required this.letters,
    required this.selectedLetters,
    required this.letterPositions,
    required this.currentLineEnd,
    required this.size,
  }) {
    // Initialize cached paint objects
    _circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    _selectedCirclePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    _borderPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _selectedBorderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3;

    _normalTextStyle = const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    _selectedTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.35;

    // Draw background circle with proper opacity
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.green.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );

    // Calculate and store letter positions
    letterPositions.clear();
    final letterRadius = 25.0;

    for (var i = 0; i < letters.length; i++) {
      final letter = letters[i];
      final angle = -pi / 2 + (2 * pi * i / letters.length);
      final letterPos = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      letterPositions[letter] = letterPos;

      final isSelected = selectedLetters.contains(letter);

      // Draw letter circles more efficiently
      canvas.drawCircle(
        letterPos,
        letterRadius,
        isSelected ? _selectedCirclePaint : _circlePaint,
      );

      // Draw letter circle borders
      canvas.drawCircle(
        letterPos,
        letterRadius,
        isSelected ? _selectedBorderPaint : _borderPaint,
      );

      // Draw letters with cached text painter
      final textPainter = TextPainter(
        text: TextSpan(
          text: letter,
          style: isSelected ? _selectedTextStyle : _normalTextStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        letterPos.translate(-textPainter.width / 2, -textPainter.height / 2),
      );
    }

    // Draw lines between selected letters more efficiently
    if (selectedLetters.isNotEmpty) {
      Path linePath = Path();
      bool isFirst = true;

      for (final letter in selectedLetters) {
        final pos = letterPositions[letter]!;
        if (isFirst) {
          linePath.moveTo(pos.dx, pos.dy);
          isFirst = false;
        } else {
          linePath.lineTo(pos.dx, pos.dy);
        }
      }

      // Add current touch position to path if available
      if (currentLineEnd != null) {
        linePath.lineTo(currentLineEnd!.dx, currentLineEnd!.dy);
      }

      canvas.drawPath(linePath, _linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant LetterCirclePainter oldDelegate) {
    return oldDelegate.selectedLetters != selectedLetters ||
        oldDelegate.currentLineEnd != currentLineEnd ||
        oldDelegate.letters != letters;
  }
}*/