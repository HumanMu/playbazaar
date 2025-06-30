import 'dart:math';
import 'package:flutter/material.dart';

class LetterCirclePosition {
  final String letter;
  final int index;
  final Offset position;
  final double radius;

  const LetterCirclePosition({
    required this.letter,
    required this.index,
    required this.position,
    required this.radius,
  });
}

/// Configuration for the letter circle painter's theme
class LetterCircleTheme {
  final Color backgroundColor;
  final Color circleFillColor;
  final Color selectedCircleFillColor;
  final Color borderColor;
  final Color selectedBorderColor;
  final Color lineColor;
  final TextStyle normalTextStyle;
  final TextStyle selectedTextStyle;
  final double strokeWidth;
  final double letterRadius;
  final double lineStrokeWidth;

  const LetterCircleTheme({
    this.backgroundColor = Colors.white38,//const Color(0x33228B22),  // Semi-transparent green
    this.circleFillColor = Colors.white,
    this.selectedCircleFillColor = Colors.blue,
    this.borderColor = const Color(0x66228B22),  // Semi-transparent green
    this.selectedBorderColor = Colors.blue,
    this.lineColor = Colors.blue,
    this.normalTextStyle = const TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    this.selectedTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    this.strokeWidth = 2,
    this.letterRadius = 20,
    this.lineStrokeWidth = 3,
  });

  /// Creates a copy of this theme with the given fields replaced with new values
  LetterCircleTheme copyWith({
    Color? backgroundColor,
    Color? circleFillColor,
    Color? selectedCircleFillColor,
    Color? borderColor,
    Color? selectedBorderColor,
    Color? lineColor,
    TextStyle? normalTextStyle,
    TextStyle? selectedTextStyle,
    double? strokeWidth,
    double? letterRadius,
    double? lineStrokeWidth,
  }) {
    return LetterCircleTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      circleFillColor: circleFillColor ?? this.circleFillColor,
      selectedCircleFillColor: selectedCircleFillColor ?? this.selectedCircleFillColor,
      borderColor: borderColor ?? this.borderColor,
      selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
      lineColor: lineColor ?? this.lineColor,
      normalTextStyle: normalTextStyle ?? this.normalTextStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      letterRadius: letterRadius ?? this.letterRadius,
      lineStrokeWidth: lineStrokeWidth ?? this.lineStrokeWidth,
    );
  }
}

/// A custom painter that draws an interactive circle of letters
class LetterCirclePainter extends CustomPainter {
  final List<String> letters;
  final List<int> selectedIndices;
  final List<LetterCirclePosition> letterPositions;
  final Offset? currentLineEnd;
  final LetterCircleTheme theme;
  final double radiusMultiplier;

  // Cached paint objects
  late final Paint _backgroundPaint;
  late final Paint _circlePaint;
  late final Paint _selectedCirclePaint;
  late final Paint _borderPaint;
  late final Paint _selectedBorderPaint;
  late final Paint _linePaint;

  LetterCirclePainter({
    required this.letters,
    required this.selectedIndices,
    required this.letterPositions,
    this.currentLineEnd,
    this.theme = const LetterCircleTheme(),
    this.radiusMultiplier = 0.35,
  }) {
    _initializePaints();
  }

  void _initializePaints() {
    _backgroundPaint = Paint()
      ..color = theme.backgroundColor
      ..style = PaintingStyle.fill;

    _circlePaint = Paint()
      ..color = theme.circleFillColor
      ..style = PaintingStyle.fill;

    _selectedCirclePaint = Paint()
      ..color = theme.selectedCircleFillColor
      ..style = PaintingStyle.fill;

    _borderPaint = Paint()
      ..color = theme.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.strokeWidth;

    _selectedBorderPaint = Paint()
      ..color = theme.selectedBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.strokeWidth;

    _linePaint = Paint()
      ..color = theme.lineColor
      ..strokeWidth = theme.lineStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * radiusMultiplier;

    _drawBackground(canvas, center, radius);
    _drawLetterCircles(canvas, center, radius);
    _drawConnectingLines(canvas);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, _backgroundPaint);
  }

  void _drawLetterCircles(Canvas canvas, Offset center, double radius) {
    letterPositions.clear();

    for (var i = 0; i < letters.length; i++) {
      final angle = -pi / 2 + (2 * pi * i / letters.length);
      final letterPos = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      final isSelected = selectedIndices.contains(i);
      _drawLetterCircle(canvas, letterPos, letters[i], isSelected);

      letterPositions.add(LetterCirclePosition(
        letter: letters[i],
        index: i,
        position: letterPos,
        radius: theme.letterRadius,
      ));
    }
  }

  void _drawLetterCircle(Canvas canvas, Offset position, String letter, bool isSelected) {
    // Draw circle background
    canvas.drawCircle(
      position,
      theme.letterRadius,
      isSelected ? _selectedCirclePaint : _circlePaint,
    );

    // Draw circle border
    canvas.drawCircle(
      position,
      theme.letterRadius,
      isSelected ? _selectedBorderPaint : _borderPaint,
    );

    // Draw letter
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: isSelected ? theme.selectedTextStyle : theme.normalTextStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      position.translate(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  void _drawConnectingLines(Canvas canvas) {
    if (selectedIndices.isEmpty) return;

    // Draw lines between selected circles
    for (var i = 0; i < selectedIndices.length - 1; i++) {
      final startPos = letterPositions[selectedIndices[i]].position;
      final endPos = letterPositions[selectedIndices[i + 1]].position;
      canvas.drawLine(startPos, endPos, _linePaint);
    }

    // Draw line to current touch position
    if (currentLineEnd != null && selectedIndices.isNotEmpty) {
      final lastPos = letterPositions[selectedIndices.last].position;
      canvas.drawLine(lastPos, currentLineEnd!, _linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant LetterCirclePainter oldDelegate) {
    return oldDelegate.selectedIndices != selectedIndices ||
        oldDelegate.currentLineEnd != currentLineEnd ||
        oldDelegate.letters != letters ||
        oldDelegate.theme != theme;
  }
}
