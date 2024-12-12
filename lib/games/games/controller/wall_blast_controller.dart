import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../puzzle/models/wall_blast_model.dart';
import '../services/wall_hive_service.dart';

class WallBlastController extends GetxController {
  // Game configuration
  static const int gridSize = 8;
  static const int matchLength = 3;

  // Dependencies
  final WallHiveService _hiveService = WallHiveService();

  // Reactive game state
  final RxList<WallBlastModel> blocks = <WallBlastModel>[].obs;
  final RxInt score = 0.obs;
  final RxInt highScore = 0.obs;
  final Rx<WallBlastModel?> selectedBlock = Rx<WallBlastModel?>(null);

  // Color palette
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  @override
  void onInit() async {
    super.onInit();
    await _hiveService.initHive();
    await loadHighScore();
    initializeGame();
  }

  Future<void> loadHighScore() async {
    highScore.value = await _hiveService.getHighScore();
  }

  void initializeGame() {
    blocks.clear();
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        blocks.add(
          WallBlastModel(
            x: x,
            y: y,
            color: colors[Random().nextInt(colors.length)],
          ),
        );
      }
    }
    findAndRemoveMatches();
  }

  void selectBlock(WallBlastModel block) {
    if (selectedBlock.value == null) {
      selectedBlock.value = block;
    } else {
      // Check if blocks are adjacent
      if (isAdjacent(selectedBlock.value!, block)) {
        swapBlocks(selectedBlock.value!, block);
        selectedBlock.value = null;
      } else {
        // If not adjacent, select the new block
        selectedBlock.value = block;
      }
    }
  }

  bool isAdjacent(WallBlastModel block1, WallBlastModel block2) {
    return (block1.x == block2.x && (block1.y - block2.y).abs() == 1) ||
        (block1.y == block2.y && (block1.x - block2.x).abs() == 1);
  }

  void swapBlocks(WallBlastModel block1, WallBlastModel block2) {
    // Swap block colors
    final temp = block1.color;
    block1.color = block2.color;
    block2.color = temp;

    // Update blocks
    final index1 = blocks.indexWhere((b) => b.x == block1.x && b.y == block1.y);
    final index2 = blocks.indexWhere((b) => b.x == block2.x && b.y == block2.y);

    blocks[index1] = block1;
    blocks[index2] = block2;

    // Check for matches
    findAndRemoveMatches();
  }

  void findAndRemoveMatches() {
    // Reset previous matches
    for (var block in blocks) {
      block.isMatched = false;
    }

    // Check horizontal matches
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize - (matchLength - 1); x++) {
        final matchingBlocks = blocks.where((block) =>
        block.x >= x &&
            block.x < x + matchLength &&
            block.y == y &&
            block.color == blocks.firstWhere((b) => b.x == x && b.y == y).color);

        if (matchingBlocks.length >= matchLength) {
          for (var block in matchingBlocks) {
            block.isMatched = true;
          }
        }
      }
    }

    // Similar logic for vertical matches can be added

    // Remove matched blocks and update score
    final matchedBlocks = blocks.where((block) => block.isMatched).toList();
    if (matchedBlocks.isNotEmpty) {
      score.value += matchedBlocks.length * 10;
      blocks.removeWhere((block) => block.isMatched);

      // Update high score if needed
      if (score.value > highScore.value) {
        highScore.value = score.value;
        _hiveService.saveHighScore(highScore.value);
      }

      // Refill the grid
      refillGrid();
    }
  }

  void refillGrid() {
    // Add new blocks to fill the grid
    for (int x = 0; x < gridSize; x++) {
      final existingBlocksInColumn = blocks.where((block) => block.x == x).length;

      for (int y = existingBlocksInColumn; y < gridSize; y++) {
        blocks.add(
          WallBlastModel(
            x: x,
            y: y,
            color: colors[Random().nextInt(colors.length)],
          ),
        );
      }
    }

    // Recheck for matches
    findAndRemoveMatches();
  }
}