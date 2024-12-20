import 'package:flutter/material.dart';

class PuzzleShapes {
  final List<List<bool>> matrix;
  final Color color;

  PuzzleShapes({required this.matrix, required this.color});

  int get width => matrix[0].length;
  int get height => matrix.length;
}

class ShapeFactory {
  static final Map<String, PuzzleShapes> shapes = {
    'T': PuzzleShapes(
      matrix: [
        [true, true, true],
        [false, true, false],
      ],
      color: Colors.purple,
    ),
    'L': PuzzleShapes(
      matrix: [
        [true, false],
        [true, false],
        [true, true],
      ],
      color: Colors.orange,
    ),
    'SQUARE4': PuzzleShapes(
      matrix: [
        [true, true],
        [true, true],
      ],
      color: Colors.yellow,
    ),
    'SQUARE9': PuzzleShapes(
      matrix: [
        [true, true, true],
        [true, true, true],
        [true, true, true],
      ],
      color: Colors.blue,
    ),
    'RECT2X3': PuzzleShapes(
      matrix: [
        [true, true, true],
        [true, true, true],
      ],
      color: Colors.green,
    ),
  };

  static PuzzleShapes getRandomShape() {
    final keys = shapes.keys.toList();
    final randomKey = keys[DateTime.now().millisecondsSinceEpoch % keys.length];
    return shapes[randomKey]!;
  }
}