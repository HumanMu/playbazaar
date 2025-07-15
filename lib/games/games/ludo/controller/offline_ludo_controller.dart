import 'package:flutter/cupertino.dart' show WidgetsBinding;
import 'package:get/get.dart';
import '../helper/enums.dart';
import '../models/ludo_player.dart';
import '../models/token.dart';
import 'base_play_controller.dart';
import 'dice_controller.dart';

class OfflineLudoController extends BaseLudoController {

  @override
  Future<void> onBoardBuilt() async {
    await initializeGameState();
  }

  Future<void> initializeGameState() async {
    final diceController = Get.find<DiceController>();
    diceController.initializeFirstPlayer(players);
  }

  @override
  Future<void> initializeServices() async {
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

    if (isTeamPlay.value) {
      Map<TokenType, int?> teamAssignments = {};
      for (var player in players) {
        teamAssignments[player.tokenType] = player.teamId;
      }
      gameService.setTeamAssignments(teamAssignments);
    }
  }

  @override
  Future<void> handleTokenTap(Token token) async {
    final diceController = Get.find<DiceController>();

    if (token.tokenState == TokenState.home ||
        (token.tokenState == TokenState.initial && diceController.diceValue != 6) ||
        !diceController.moveState ||
        token.type != diceController.diceColor) {
      return;
    }

    if (!hasEnoughSpaceToMove(token, diceController.diceValue)) {
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
      final currentPlayerIndex = players.indexWhere((p) => p.tokenType == diceController.diceColor);

      if (currentPlayerIndex >= 0 &&
          players[currentPlayerIndex].isRobot == true &&
          isRobotOn.value) {
        await Future.delayed(const Duration(milliseconds: 800), () {
          diceController.playRobotTurn();
        });
      } else {
        diceController.setDiceState(true);
      }
    }
  }

  @override
  Future<void> moveToken(Token token, dynamic controller) async {
    final diceController = controller as DiceController;
    final didKill = await gameService.moveToken(token, diceController.diceValue);

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

    diceController.dice.giveAnotherTurn = didKill || hasReached || (diceController.diceValue == 6);
  }

  @override
  void restartGame() async {
    isLoading.value = true;

    boardBuild.value = false;
    wasLastToken.value = false;

    await initializeServices();
    await initializePlayers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      boardBuild.value = true;
      initializeGameState();
      isLoading.value = false;
    });
  }
}