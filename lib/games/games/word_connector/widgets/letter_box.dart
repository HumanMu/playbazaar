import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/word_model.dart';

class LetterBox extends StatelessWidget {
  final WordConnectorModel word;
  final int letterIndex;

  // Cached styles and decorations
  static const double _boxWidth = 35;
  static const double _boxHeight = 33;
  static const double _borderRadius = 8;
  static const EdgeInsets _boxMargin = EdgeInsets.symmetric(horizontal: 3);

  static final _foundTextStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  );

  static final _hiddenTextStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black54,
  );

  const LetterBox({
    super.key,
    required this.word,
    required this.letterIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _boxWidth,
      height: _boxHeight,
      margin: _boxMargin,
      decoration: BoxDecoration(
        border: Border.all(
          color: word.isFound
              ? Colors.green.shade200
              : Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Center(
        child: Text(
          word.isFound ? word.text[letterIndex] : '_',
          style: word.isFound ? _foundTextStyle : _hiddenTextStyle,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<WordConnectorModel>('word', word));
    properties.add(IntProperty('letterIndex', letterIndex));
  }
}
