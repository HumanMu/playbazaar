import 'dart:math';
import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:playbazaar/games/games/ludo/helper/functions.dart';
import 'package:playbazaar/games/games/ludo/models/dice_model.dart';
import 'package:playbazaar/games/games/ludo/models/ludo_player.dart';
import '../helper/enums.dart';
import '../models/position.dart';
import '../services/game_service.dart';
import '../models/token.dart';
import '../widgets/game_over.dart';
import 'dice_controller.dart';

class GameController extends GetxController {
  final DiceModel diceModel = DiceModel();
  final List<List<GlobalKey>> keyReferences = LudoHelper.getGlobalKeys();
  final GameService gameService = Get.find<GameService>();

  List<Token?> get gameTokens => gameService.gameTokens;
  RxList<LudoPlayer> players = <LudoPlayer>[].obs;
  final RxBool wasLastToken = RxBool(false);
  final RxBool boardBuild = RxBool(false);
  final RxBool isTeamPlay = RxBool(false);
  final RxBool isLoading = RxBool(false);
  final RxBool isRobotOn = RxBool(false);
  final RxInt numberOfHumanPlayers = RxInt(4);


  @override
  void onInit() async {
    isLoading.value = true;
    super.onInit();

    await _initializeServices();
    await _initializePlayers();

    // Add post frame callback to set boardBuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      boardBuild.value = true;
      initializeGameState(); // to update after DiceController is created
    });

    isLoading.value = false;
  }

  void initializeGameState() {
    final diceController = Get.find<DiceController>();
    diceController.initializeFirstPlayer(players);
  }


  Future<void> _initializeServices() async {
    if (Get.arguments != null) {
      numberOfHumanPlayers.value = Get.arguments['numberOfPlayer'] ?? 4;
      isRobotOn.value = Get.arguments['enabledRobots'] ?? false;
      isTeamPlay.value = Get.arguments['teamPlay'] ?? false;
    }

    final numberOfPlayer = (isTeamPlay.value || isRobotOn.value)
        ? 4
        : numberOfHumanPlayers.value;

    gameService.init(numberOfPlayer, teamPlay: isTeamPlay.value);
  }


  List<Token> getTokensAtPosition(Position position) {
    return gameTokens.whereType<Token>().where((token) =>
    token.tokenPosition.row == position.row &&
        token.tokenPosition.column == position.column
    ).toList();
  }


  Future<void> handleTokenTap(Token token) async {
    final diceController = Get.find<DiceController>();

    if (token.tokenState == TokenState.home
        || (token.tokenState == TokenState.initial &&
            diceController.diceValue != 6)
        || !diceController.moveState
        || token.type != diceController.diceColor) {
      return;
    }

    if (!_hasEnoughSpaceToMove(token, diceController.diceValue)) {
      return;
    }

    diceController.setMoveState(false);
    diceController.setDiceState(false);

    await moveToken(token, diceController);
    bool giveAnotherTurn = diceController.giveAnotherTurn;

    if (!giveAnotherTurn || wasLastToken.value) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        diceController.nextPlayer();
      });
    } else if (giveAnotherTurn) {
      diceController.dice.giveAnotherTurn = false;
      final currentPlayerIndex = players.indexWhere((p) =>
      p.tokenType == diceController.diceColor);

      if (currentPlayerIndex >= 0 &&
          players[currentPlayerIndex].isRobot == true && isRobotOn.value) {
        await Future.delayed(const Duration(milliseconds: 800), () {
          diceController.playRobotTurn();
        });
      }
      else {
        diceController.setDiceState(true);
      }
    }
  }


  Future<void> moveToken(Token token, DiceController controller) async {
    // int diceValue
    final didKill = await gameService.moveToken(token, controller.diceValue);

    bool hasReached = token.positionInPath + controller.diceValue == 56;
    if (hasReached) {
      await updateReachedHome(token);
      final isOver = checkForGameOver();
      if (isOver) {
        Future.delayed(const Duration(milliseconds: 800), () {
          showGameOverDialog();
        });
      }
    }
    controller.dice.giveAnotherTurn =
        didKill || hasReached || (controller.diceValue == 6);
  }


  Future<void> updateReachedHome(Token token) async {
    final index = players.indexWhere((e) => e.tokenType == token.type);
    if (index != -1) {
      final player = players[index];
      final newReachedHome = player.reachedHome + 1;
      final hasFinished = newReachedHome >= 4;

      // Update player with copyWith for immutability
      players[index] = player.copyWith(
        reachedHome: newReachedHome,
        hasFinished: hasFinished,
      );

      wasLastToken.value = players[index].hasFinished;

      // Check game over condition
      final isGameOver = checkForGameOver();
      if (isGameOver) {
        await Future.delayed(const Duration(), () {
          showGameOverDialog();
        });
        debugPrint(
            'Game over! ${isTeamPlay.value ? "Team ${player.teamId}" : player
                .name} wins!');
        // Trigger game over UI or logic
      }
    }
  }


  Future<void> _initializePlayers() async {
    players.clear();

    // Create a map to store which colors should be robots
    Map<TokenType, bool> isRobot = {
      TokenType.red: false,
      TokenType.green: false,
      TokenType.yellow: false,
      TokenType.blue: false,
    };

    List<TokenType> tokensToUse = [];

    if (isRobotOn.value) {
      tokensToUse =
      [TokenType.red, TokenType.green, TokenType.yellow, TokenType.blue];

      switch (numberOfHumanPlayers.value) {
        case 1:
        // Red is human, rest are robots
          isRobot[TokenType.green] = true;
          isRobot[TokenType.yellow] = true;
          isRobot[TokenType.blue] = true;
          break;
        case 2:
          isRobot[TokenType.green] = true;
          isRobot[TokenType.blue] = true;
          break;
        case 3:
          isRobot[TokenType.yellow] = true;
          break;
      // All human for case 4
      }
    } else {
      switch (numberOfHumanPlayers.value) {
        case 1:
          tokensToUse = [TokenType.red];
          break;
        case 2:
          tokensToUse = [TokenType.red, TokenType.yellow];
          break;
        case 3:
          tokensToUse = [TokenType.red, TokenType.green, TokenType.blue];
          break;
        case 4:
          tokensToUse =
          [TokenType.red, TokenType.green, TokenType.yellow, TokenType.blue];
          break;
      }
    }

    // Assign team IDs if team play is enabled
    Map<TokenType, int> teamAssignments = {};
    if (isTeamPlay.value) {
      teamAssignments = {
        TokenType.red: 1,
        TokenType.yellow: 1,
        TokenType.green: 2,
        TokenType.blue: 2,
      };
    }

    // Create all necessary players
    for (var tokenType in tokensToUse) {
      String colorName = tokenType
          .toString()
          .split('.')
          .last;
      String name = "${colorName[0].toUpperCase()}${colorName.substring(1)
          .toLowerCase()} Player";

      // Add team name if team play is enabled
      if (isTeamPlay.value && teamAssignments.containsKey(tokenType)) {
        int teamId = teamAssignments[tokenType]!;

        players.add(LudoPlayer(
          tokenType: tokenType,
          name: name,
          isRobot: isRobot[tokenType] ?? false,
          teamId: teamId,
        ));
      } else {
        players.add(LudoPlayer(
          tokenType: tokenType,
          name: name,
          isRobot: isRobot[tokenType] ?? false,
        ));
      }
    }


    // Set team assignments in game service
    if (isTeamPlay.value) {
      Map<TokenType, int?> teamAssignments = {};
      for (var player in players) {
        teamAssignments[player.tokenType] = player.teamId;
      }
      gameService.setTeamAssignments(teamAssignments);
    }
  }


  Offset getTokenOffsetAtPosition(Token token) {
    final tokensAtPosition = getTokensAtPosition(token.tokenPosition);

    if (tokensAtPosition.length <= 1) {
      return Offset.zero;
    }

    // Find this token's index among those at the same position
    final indexInStack = tokensAtPosition.indexWhere((t) => t.id == token.id);
    if (indexInStack == -1) return Offset.zero; // Safety check

    // Calculate offset amount - make it large enough to not overlap
    final baseOffset = 10.0;

    // Calculate angle based on position in stack - create a spiral
    final angle = (indexInStack * (2 * math.pi / 8)) % (2 * math.pi);

    // Distance increases with each token to create a spiral
    final distance = baseOffset * (1 + indexInStack * 0.3);

    // Convert polar coordinates (angle, distance) to Cartesian (x, y)
    return Offset(
        math.cos(angle) * distance,
        math.sin(angle) * distance
    );
  }


  List<double> getPosition(int row, int column, GlobalKey appBarKey) {

    final cellKey = keyReferences[row][column];
    if (cellKey.currentContext == null) {
      return [0, 0, 0, 0];
    }

    try {
      // Get the render box of the cell
      final RenderBox cellRenderBox = cellKey.currentContext!.findRenderObject() as RenderBox;
      final cellSize = cellRenderBox.size;

      // Find the board container
      RenderBox? boardBox;
      BuildContext? currentContext = cellKey.currentContext;
      int searchAttempts = 0;

      // Try to find the board container by walking up the widget tree
      // Limit the search to avoid infinite loops
      while (currentContext != null && boardBox == null && searchAttempts < 10) {
        searchAttempts++;

        // Check if this context has a RenderBox
        final renderObject = currentContext.findRenderObject();
        if (renderObject is RenderBox) {
          final size = renderObject.size;
          if (size.width > cellSize.width * 10 && size.height > cellSize.height * 10) {
            boardBox = renderObject;
            break;
          }
        }

        // Move up to parent context
        currentContext = currentContext.findAncestorStateOfType<State>() as BuildContext?;
      }

      if (boardBox != null) {
        try {
          final localPosition = cellRenderBox.localToGlobal(
              Offset.zero,
              ancestor: boardBox
          );

          return [
            localPosition.dx,
            localPosition.dy,
            cellSize.width,
            cellSize.height
          ];
        } catch (e) {
          debugPrint('Error calculating local position: $e');
        }
      }

      final globalPosition = cellRenderBox.localToGlobal(Offset.zero);

      // Adjust for app bar height
      final double appBarHeight = appBarKey.currentContext != null
          ? (appBarKey.currentContext!.findRenderObject() as RenderBox).size.height
          : 0.0;

      return [
        globalPosition.dx,
        globalPosition.dy - appBarHeight,
        cellSize.width,
        cellSize.height
      ];
    } catch (e) {
      debugPrint('Error in getPosition: $e');
      return [0, 0, 0, 0];
    }
  }

  bool getMovableTokens(TokenType type, int diceValue) {
    return gameService.getMovableTokens(type, diceValue);
  }

  bool checkForInitialTokens(TokenType type) {
    return gameService.hasInitialToken(type);
  }

  bool _hasEnoughSpaceToMove(Token token, int diceValue) {
    return token.positionInPath + diceValue <= 56;
  }

  void restartGame() async {
    isLoading.value = true;

    // Reset game state
    boardBuild.value = false;
    wasLastToken.value = false;

    // Initialize services and players again
    await _initializeServices();
    await _initializePlayers();

    // Reset board
    WidgetsBinding.instance.addPostFrameCallback((_) {
      boardBuild.value = true;
      initializeGameState();
      isLoading.value = false;
    });
  }

  bool checkForGameOver() {
    if (!isTeamPlay.value) {
      return players
          .where((player) => player.hasFinished == true)
          .length == 1;
    } else {
      // Team play logic - check if any team has all their tokens home
      Map<int, int> teamMemberCount = {};
      Map<int, int> teamFinishedCount = {};

      // Count total members and finished members for each team
      for (var player in players) {
        if (player.teamId != null) {
          teamMemberCount[player.teamId!] =
              (teamMemberCount[player.teamId!] ?? 0) + 1;
          if (player.hasFinished) {
            teamFinishedCount[player.teamId!] =
                (teamFinishedCount[player.teamId!] ?? 0) + 1;
          }
        }
      }

      // Check if any team has all members finished
      for (var teamId in teamMemberCount.keys) {
        if (teamFinishedCount[teamId] == teamMemberCount[teamId]) {
          return true;
        }
      }

      return false;
    }
  }


  void showGameOverDialog() {
    Get.dialog(
      GameOverDialog(
        players: players,
        isTeamPlay: isTeamPlay.value,
        onPlayAgain: () {
          Get.back();
          restartGame();
        },
        onExit: () {
          Get.back();
          Get.back(); // Exit to menu
        },
      ),
      barrierDismissible: false,
    );
  }
}