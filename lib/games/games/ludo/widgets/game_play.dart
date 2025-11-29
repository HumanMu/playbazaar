import 'package:go_router/go_router.dart';
import '../../../../admob/adaptive_banner_ad.dart';
import 'custom_sidebar_menu.dart';
import '../controller/base_ludo_controller.dart';
import '../controller/dice_controller.dart';
import 'package:flutter/material.dart';
import '../controller/offline_ludo_controller.dart';
import 'dice_widget.dart';
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
  final gameController = Get.find<BaseLudoController>();
  final diceController = Get.find<DiceController>();
  bool drawerState = false;

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
    return PopScope(
      canPop: false,
      child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;
            final boardSize = screenWidth * 0.99;

            return Stack(
              children: [
                SafeArea(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        gameController.gameMode == GameMode.online
                            ? CustomSideMenu()
                            : IconButton(
                                onPressed: () => context.go("/ludoHome"),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.red,
                                ),
                              ),
                      ]
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ Wrap player profiles in Obx to make them reactive
                    Obx(() {
                      final greenPlayer = gameController.players.firstWhereOrNull(
                            (player) => player.tokenType == TokenType.green,
                      );
                      final yellowPlayer = gameController.players.firstWhereOrNull(
                            (player) => player.tokenType == TokenType.yellow,
                      );

                      return Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.015,
                            vertical: boardSize * 0.01
                        ),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    if (greenPlayer != null)
                                      PlayerProfileWidget(player: greenPlayer),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (yellowPlayer != null)
                                      PlayerProfileWidget(player: yellowPlayer),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Board without dice
                    Container(
                      key: boardContainerKey,
                      width: boardSize,
                      height: boardSize,
                      constraints: BoxConstraints(
                        maxWidth: boardSize,
                        maxHeight: boardSize,
                      ),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
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
                    ),

                    // ✅ Wrap bottom player profiles in Obx
                    Obx(() {
                      final redPlayer = gameController.players.firstWhereOrNull(
                            (player) => player.tokenType == TokenType.red,
                      );
                      final bluePlayer = gameController.players.firstWhereOrNull(
                            (player) => player.tokenType == TokenType.blue,
                      );

                      return Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: boardSize * 0.015,
                            vertical: boardSize * 0.01
                        ),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    if (redPlayer != null)
                                      PlayerProfileWidget(player: redPlayer),
                                  ],
                                ),
                              ),

                              // Blue player
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (bluePlayer != null)
                                      PlayerProfileWidget(player: bluePlayer),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                // Single dice that animates to player positions
                Obx(() {
                  final diceColor = diceController.color;
                  final double calculatedSize = screenWidth * 0.08;
                  final double profileDimension = calculatedSize.clamp(55.0, 70.0);
                  final double diceFromSide = profileDimension + (screenWidth * 0.02);
                  final double diceFromCenter = (screenHeight * 0.5) - (screenWidth * 0.5 + profileDimension + 10);
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
                Positioned(
                    bottom: 0,
                    child: SafeArea(
                        child: Container(
                          margin: EdgeInsets.zero,
                          color: Colors.teal[900],
                          width: MediaQuery.of(context).size.width,
                          child: AdaptiveBannerAd(
                              onAdLoaded: (isLoaded) {
                                if (isLoaded) {
                                  debugPrint('Ad loaded in Ludo Game Play');
                                } else {
                                  debugPrint('Ad failed to load in Ludo Game Play');
                                }
                              }
                          ),
                        )
                    )
                )
              ],
            );
          }
      ),
    );
  }

  List<double> _getTokenPosition(Token token, double boardSize) {
    List<double>? calculatedPosition;

    // Only use complex positioning for offline mode
    if (gameController is OfflineLudoController) {
      calculatedPosition = (gameController as OfflineLudoController).getPosition(
        token.tokenPosition.row,
        token.tokenPosition.column,
        widget.appBarKey,
      );
    }

    // Let service handle the positioning logic
    return gameController.gameService.getTokenDisplayPosition(
      token,
      boardSize,
      calculatedPosition,
    );
  }
}

