import 'dart:ui';

import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../puzzle/models/puzzle_shapes.dart';

class WallPuzzleController extends GetxController {
  static const int boardWidth = 10;
  static const int boardHeight = 20;

  final board = List.generate(
      boardHeight,
          (_) => List.generate(boardWidth, (_) => null as Color?).obs
  ).obs;

  final currentPieces = <PuzzleShapes>[].obs;
  final score = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadHighScore();
    generateNewPieces();
  }

  void generateNewPieces() {
    currentPieces.clear();
    for (int i = 0; i < 3; i++) {
      currentPieces.add(ShapeFactory.getRandomShape());
    }
  }

  bool canPlacePiece(PuzzleShapes piece, int row, int col) {
    if (row < 0 || col < 0) return false;
    if (row + piece.height > boardHeight || col + piece.width > boardWidth) return false;

    for (int i = 0; i < piece.height; i++) {
      for (int j = 0; j < piece.width; j++) {
        if (piece.matrix[i][j] && board[row + i][col + j] != null) {
          return false;
        }
      }
    }
    return true;
  }

  void placePiece(PuzzleShapes piece, int row, int col) {
    for (int i = 0; i < piece.height; i++) {
      for (int j = 0; j < piece.width; j++) {
        if (piece.matrix[i][j]) {
          board[row + i][col + j] = piece.color;
        }
      }
    }
    currentPieces.remove(piece);
    if (currentPieces.isEmpty) {
      generateNewPieces();
    }
    checkLines();
  }

  void checkLines() {
    List<int> completeLines = [];

    for (int i = 0; i < boardHeight; i++) {
      if (board[i].every((cell) => cell != null)) {
        completeLines.add(i);
      }
    }

    if (completeLines.isNotEmpty) {
      removeLines(completeLines);
      score.value += completeLines.length * 100;
      saveHighScore();
    }
  }

  void removeLines(List<int> lines) {
    lines.sort();
    for (int line in lines.reversed) {
      board.removeAt(line);
      board.insert(0, List.generate(boardWidth, (_) => null).obs);
    }
  }

  Future<void> loadHighScore() async {
    var box = await Hive.openBox('gameBox');
    int highScore = box.get('highScore', defaultValue: 0);
    if (highScore > score.value) {
      score.value = highScore;
    }
  }

  Future<void> saveHighScore() async {
    var box = await Hive.openBox('gameBox');
    await box.put('highScore', score.value);
  }
}
