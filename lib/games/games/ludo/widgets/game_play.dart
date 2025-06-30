import 'package:playbazaar/games/games/ludo/widgets/dice_widget.dart';
import '../../../../admob/adaptive_banner_ad.dart';
import '../controller/dice_controller.dart';
import '../controller/game_controller.dart';
import 'package:flutter/material.dart';
import 'player_profile_widget.dart';
import 'package:get/get.dart';
import '../helper/enums.dart';
import '../models/token.dart';
import 'tokens/token_widget.dart';
import 'board.dart';



class GamePlay extends StatefulWidget {
  final GlobalKey appBarKey;

  const GamePlay(this.appBarKey, {super.key});

  @override
  State<GamePlay> createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  bool boardBuilt = false;
  final GlobalKey boardContainerKey = GlobalKey();
  final gameController = Get.find<GameController>();
  final diceController = Get.find<DiceController>();

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
    return LayoutBuilder(
        builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        final boardSize = screenWidth * 0.99;


        // Correctly assign player types
        final greenPlayer = gameController.players.firstWhereOrNull(
              (player) => player.tokenType == TokenType.green,
        );
        final yellowPlayer = gameController.players.firstWhereOrNull(
              (player) => player.tokenType == TokenType.yellow,
        );
        final redPlayer = gameController.players.firstWhereOrNull(
              (player) => player.tokenType == TokenType.red,
        );
        final bluePlayer = gameController.players.firstWhereOrNull(
              (player) => player.tokenType == TokenType.blue,
        );

        return Stack(
          children: [
            Container(
              color: Colors.teal[900],
              width: MediaQuery.of(context).size.width,
              child: AdaptiveBannerAd(
                onAdLoaded: (isLoaded) {
                  if (isLoaded) {
                    debugPrint('Ad loaded in Quiz Screen');
                  } else {
                    debugPrint('Ad failed to load in Quiz Screen');
                  }
                },
              ),  // The BannerAd widget
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.015, vertical: boardSize * 0.01),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Green player
                        Expanded(
                          child: Row(
                            children: [
                              if(greenPlayer != null)
                                PlayerProfileWidget(player: greenPlayer),
                            ],
                          ),
                        ),

                        // Yellow player
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if(yellowPlayer != null)
                                PlayerProfileWidget(player: yellowPlayer),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Board without dice
                Container(
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
                      // The board
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
                              final dimensions = _getTokenPosition(
                                token,
                                gameController,
                                boardSize,
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

                // Bottom row player profiles
                Container(
                  margin: EdgeInsets.symmetric(horizontal: boardSize * 0.015, vertical: boardSize * 0.01),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Red player
                        Expanded(
                          child: Row(
                            children: [
                              if(redPlayer != null)
                                PlayerProfileWidget(player: redPlayer),
                            ],
                          ),
                        ),

                        // Blue player
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if(bluePlayer != null)
                                PlayerProfileWidget(player: bluePlayer),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),

            // Single dice that animates to player positions
            Obx(() {
              final diceColor = diceController.diceColor;
              final double calculatedSize = screenWidth * 0.08;
              final double profileDimension = calculatedSize.clamp(55.0, 70.0);
              final double diceFromSide = profileDimension + (screenWidth * 0.02);
              final double diceFromCenter = (screenHeight * 0.5) - (screenWidth * 0.5 + profileDimension + 10); // 3 pixels gap
              double? left, right, top, bottom;

              switch (diceColor) {
                case TokenType.green:
                  left = diceFromSide;
                  top = diceFromCenter;
                  break;
                case TokenType.yellow:
                  right = diceFromSide;
                  top = diceFromCenter;
                  break;
                case TokenType.red:
                  left = diceFromSide;
                  bottom = diceFromCenter;
                  break;
                case TokenType.blue:
                  right = diceFromSide;
                  bottom = diceFromCenter;
                  break;
              }

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                left: left,
                right: right,
                top: top,
                bottom: bottom,
                child: const ModernDiceWidget(),
              );
            }),
          ],
        );
      },
    );
  }

  // Helper method to calculate token position properly
  List<double> _getTokenPosition(
      Token token,
      GameController gameController,
      double boardSize,
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
        cellSize,
      ];
    }

    // Ensure token stays within the board boundaries
    final clampedX = position[0].clamp(0.0, boardSize - cellSize);
    final clampedY = position[1].clamp(0.0, boardSize - cellSize);

    return [clampedX, clampedY, cellSize, cellSize];
  }
}

