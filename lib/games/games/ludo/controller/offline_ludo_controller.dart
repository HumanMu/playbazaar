import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/ludo/models/ludo_creattion_params.dart';
import '../helper/enums.dart';
import '../models/ludo_player.dart';
import '../models/token.dart';
import 'base_ludo_controller.dart';
import 'dice_controller.dart';

class OfflineLudoController extends BaseLudoController {

  @override
  Future<void> onBoardBuilt() async {
    await initializePlayers();
  }

  @override
  Future<void> initializeServices(LudoCreationParamsModel params) async {
    numberOfHumanPlayers.value = params.numberOfPlayers;
    isRobotOn.value = params.enableRobots;
    isTeamPlay.value = params.teamPlay;
  }

  @override
  Future<void> onAwaitingTokenSelection(TokenType player, int diceValue) async {
    final currentPlayer = players.firstWhereOrNull((p) => p.tokenType == player);
    debugPrint('isRobot: ${currentPlayer?.isRobot}');
    debugPrint('isRobotOn: ${isRobotOn.value}');
    if (currentPlayer?.isRobot == true && isRobotOn.value) {
      await diceController.selectRobotToken();
      //await diceController.playRobotTurn();
    }
  }

  @override
  Future<void> initializePlayers() async {
    players.clear();

    Map<TokenType, bool> isRobot = {
      TokenType.red: false,
      TokenType.green: false,
      TokenType.yellow: false,
      TokenType.blue: false,
    };

    List<TokenType> tokensToUse = [];

    if (isRobotOn.value) {
      tokensToUse = [TokenType.red, TokenType.green, TokenType.yellow, TokenType.blue];

      switch (numberOfHumanPlayers.value) {
        case 1:
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
          tokensToUse = [TokenType.red, TokenType.green, TokenType.yellow, TokenType.blue];
          break;
      }
    }

    Map<TokenType, int> teamAssignments = {};
    if (isTeamPlay.value) {
      teamAssignments = {
        TokenType.red: 1,
        TokenType.yellow: 1,
        TokenType.green: 2,
        TokenType.blue: 2,
      };
    }

    for (var tokenType in tokensToUse) {
      String colorName = tokenType.toString().split('.').last;
      String name = "${colorName[0].toUpperCase()}${colorName.substring(1).toLowerCase()} Player";

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

    syncTeamAssignments(isTeamPlay.value);
  }

  @override
  Future<void> handleTokenTap(Token token) async {

    bool basicCheck = basicTokenTapCheck(token);
    if (!basicCheck) return;

    await moveToken(token, diceController);
    bool giveAnotherTurn = diceController.hasExtraTurn;

    if (!giveAnotherTurn || wasLastToken.value) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        diceController.processNextPlayer();
      });

    } else if (giveAnotherTurn) {
      diceController.dice.hasExtraTurn = false;
      final currentPlayerIndex = players.indexWhere((p) => p.tokenType == diceController.color);

      if (currentPlayerIndex >= 0 &&
          players[currentPlayerIndex].isRobot == true &&
          isRobotOn.value) {
        await Future.delayed(const Duration(milliseconds: 800), () {
          diceController.processRobotTurn();
        });
      } else {
        diceController.setDiceRollState(true);
      }
    }
  }

  @override
  Future<void> moveToken(Token token, dynamic controller) async {
    final diceController = controller as DiceController;
    final didKill = await gameService.moveToken(token, diceController.diceValue, null, "", null);

    bool hasReached = token.positionInPath + diceController.diceValue == 56;
    if (hasReached) {
      await updateReachedHome(token);
      final isOver = checkForGameOver();
      if (isOver) {
        Future.delayed(const Duration(milliseconds: 800), () {
          showGameOverDialog();
        });
      }
    }

    diceController.dice.hasExtraTurn = didKill || hasReached || (diceController.diceValue == 6);
  }

  List<double> getPosition(int row, int column, GlobalKey appBarKey) {
    final cellKey = keyReferences[row][column];
    if (cellKey.currentContext == null) {
      return [0, 0, 0, 0];
    }

    try {
      final RenderBox cellRenderBox = cellKey.currentContext!.findRenderObject() as RenderBox;
      final cellSize = cellRenderBox.size;

      RenderBox? boardBox;
      BuildContext? currentContext = cellKey.currentContext;
      int searchAttempts = 0;

      while (currentContext != null && boardBox == null && searchAttempts < 10) {
        searchAttempts++;

        final renderObject = currentContext.findRenderObject();
        if (renderObject is RenderBox) {
          final size = renderObject.size;
          if (size.width > cellSize.width * 10 && size.height > cellSize.height * 10) {
            boardBox = renderObject;
            break;
          }
        }

        final ancestorState = currentContext.findAncestorStateOfType<State>();
        currentContext = ancestorState?.context;
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

  @override
  void restartGame() async {
    isLoading.value = true;

    boardBuild.value = false;
    wasLastToken.value = false;

    //await initializeServices();
    //await initializePlayers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      boardBuild.value = true;
      //initializeGameState();
      isLoading.value = false;
    });
  }
}