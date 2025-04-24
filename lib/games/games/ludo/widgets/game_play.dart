import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/game_controller.dart';
import '../models/token.dart';
import 'board.dart';
import 'token_widget.dart';

class GamePlay extends StatefulWidget {
  final GlobalKey appBarKey;

  const GamePlay(this.appBarKey, {super.key});

  @override
  State<GamePlay> createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  bool boardBuilt = false;
  final GlobalKey boardContainerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Set boardBuilt to true after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        boardBuilt = true;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();

    return LayoutBuilder(
      builder: (context, constraints) {

        final screenWidth = constraints.maxWidth;
        final boardSize = screenWidth * 0.98; // 98% of screen width for smaller screens

        return Center(
          child: Container(
            key: boardContainerKey,
            width: boardSize,
            height: boardSize,
            constraints: BoxConstraints(
              maxWidth: boardSize,
              maxHeight: boardSize,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // The board widget - always visible
                Positioned.fill(
                  child: LudoBoard(
                    keyReferences: gameController.keyReferences,
                  ),
                ),

                // Tokens - only visible once board is built
                if (boardBuilt)
                  Obx(() {
                    final tokens = gameController.gameTokens
                        .whereType<Token>()
                        .toList();

                    return Stack(
                      fit: StackFit.expand,
                      children: tokens.map((token) {
                        // Get position data for this token
                        final dimensions = _getTokenPosition(
                            token,
                            gameController,
                            boardSize
                        );

                        return TokenWidget(
                          token: token,
                          dimensions: dimensions,
                        );
                      }).toList(),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to calculate token position properly
  List<double> _getTokenPosition(
      Token token,
      GameController gameController,
      double boardSize
      ) {
    // Get raw position from game controller
    final position = gameController.getPosition(
      token.tokenPosition.row,
      token.tokenPosition.column,
      widget.appBarKey,
    );

    // Calculate cell size based on board size
    final cellSize = boardSize / 15;

    // If position calculation failed, use calculated position
    if (position[0] == 0 && position[1] == 0 && position[2] == 0 && position[3] == 0) {
      // Calculate position directly based on row/column
      return [
        token.tokenPosition.column * cellSize,
        token.tokenPosition.row * cellSize,
        cellSize,
        cellSize
      ];
    }

    // Ensure token stays within the board boundaries
    final clampedX = position[0].clamp(0.0, boardSize - cellSize);
    final clampedY = position[1].clamp(0.0, boardSize - cellSize);

    return [clampedX, clampedY, cellSize, cellSize];
  }
}

/*class GamePlay extends StatefulWidget {
  final GlobalKey keyBar;

  const GamePlay(this.keyBar, {super.key});

  @override
  State<GamePlay> createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  bool boardBuilt = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        boardBuilt = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();

    return Obx(() {
      final tokens = gameController.gameTokens.whereType<Token>().toList();

      return Directionality(
        textDirection: TextDirection.ltr,  // Force LTR layout
        child: Stack(
          children: [
            Board(gameController.keyReferences), // the old way
            if (boardBuilt) // Only show tokens after board is built
              ...tokens.map((token) =>
                  TokenWidget(
                    token: token,
                    dimensions: gameController.getPosition(
                      token.tokenPosition.row,
                      token.tokenPosition.column,
                      widget.keyBar,
                    ),
                  )),
          ],
        ),
      );
    });
  }
}*/