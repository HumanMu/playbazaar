import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:playbazaar/games/games/ludo/helper/functions.dart';
import 'package:playbazaar/games/games/ludo/models/dice_model.dart';
import 'package:playbazaar/games/games/ludo/models/ludo_player.dart';
import '../helper/enums.dart';
import '../models/position.dart';
import '../services/game_service.dart';
import '../models/token.dart';
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
  int numberOfHumanPlayers = 4;




  @override
  void onInit() {
    isLoading.value = true;
    super.onInit();

    if (Get.arguments != null) {
      numberOfHumanPlayers = Get.arguments['numberOfPlayer'] ?? 4;
      isRobotOn.value = Get.arguments['enabledRobots'] ?? false;
      isTeamPlay.value = Get.arguments['teamPlay'] ?? false;
    }

    _initializePlayers();

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


  List<Token> getTokensAtPosition(Position position) {
    return gameTokens.whereType<Token>().where((token) =>
    token.tokenPosition.row == position.row &&
        token.tokenPosition.column == position.column
    ).toList();
  }


  Offset getTokenOffsetAtPosition(Token token) {
    final tokensAtSamePosition = getTokensAtPosition(token.tokenPosition);

    // If only one token at this position
    if (tokensAtSamePosition.length <= 1) {
      return Offset.zero;
    }

    // Find other tokens in this x position
    final indexInStack = tokensAtSamePosition.indexWhere((t) => t.id == token.id);
    if (indexInStack == -1) return Offset.zero; // Safety check

    // This creates a diagonal pattern where tokens are slightly shifted
    final offsetX = indexInStack * 8.0;
    final offsetY = indexInStack * 8.0;

    return Offset(offsetX, offsetY);
  }

  List<double> getPosition(int row, int column, GlobalKey keyBar) {
    final cellBoxKey = keyReferences[row][column];
    if (cellBoxKey.currentContext == null) {
      return [0, 0, 0, 0];
    }

    final RenderBox renderBoxBar = keyBar.currentContext!.findRenderObject() as RenderBox;
    final sizeBar = renderBoxBar.size;
    final RenderBox renderBoxCell = cellBoxKey.currentContext!.findRenderObject() as RenderBox;
    final positionCell = renderBoxCell.localToGlobal(Offset.zero);

    final double x = positionCell.dx + 1;
    final double y = positionCell.dy - sizeBar.height + 1;
    final double w = renderBoxCell.size.width - 1;
    final double h = renderBoxCell.size.height - 1;

    return [x, y, w, h];
  }


  Future<void> handleTokenTap(Token token) async {
    final diceController = Get.find<DiceController>();

    if (token.tokenState == TokenState.home
        || (token.tokenState == TokenState.initial && diceController.diceValue != 6)
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

    if ( !giveAnotherTurn || wasLastToken.value ) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        diceController.nextPlayer();
      });

    } else if (giveAnotherTurn) {
      diceController.dice.giveAnotherTurn = false;
      final currentPlayerIndex = players.indexWhere((p) => p.tokenType == diceController.diceColor);

      if (currentPlayerIndex >= 0 && players[currentPlayerIndex].isRobot == true && isRobotOn.value) {
        await Future.delayed(const Duration(milliseconds: 800), () {
          diceController.playRobotTurn();
        });
      }
      else{
        diceController.setDiceState(true);
      }
    }
  }


  Future<void> moveToken(Token token, DiceController controller) async { // int diceValue
    final didKill = await gameService.moveToken(token, controller.diceValue);

    bool hasReached = token.positionInPath + controller.diceValue == 56;
    if(hasReached){
      updateReachedHome(token);
      final isOver = checkForGameOver();
      if(isOver){

      }
    }
    controller.dice.giveAnotherTurn = didKill || hasReached || (controller.diceValue == 6);
    /*if (controller.diceValue == 6 && controller.consecvative6 >= 3) {
      controller.dice.rxConsecutiveSixes = 0;
      controller.dice.giveAnotherTurn = false;
    } else {
      controller.dice.giveAnotherTurn = didKill || hasReached || (controller.diceValue == 6);
    }*/
  }

  void updateReachedHome(Token token) {
    final index = players.indexWhere((e) => e.tokenType == token.type);
    if (index != -1) {
      final user = players[index];
      players[index] = LudoPlayer(
          tokenType: user.tokenType,
          reachedHome: user.reachedHome + 1,
          hasFinished: user.reachedHome + 1 == 4,
          name: user.name,
          isRobot: user.isRobot
      );
    }

    wasLastToken.value = players[index].hasFinished;
  }

  void _initializePlayers() {
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
      // Always use all four colors when robots are enabled
      tokensToUse = [TokenType.red, TokenType.green, TokenType.yellow, TokenType.blue];

      switch (numberOfHumanPlayers) {
        case 1:
        // Red is human, rest are robots
          isRobot[TokenType.green] = true;
          isRobot[TokenType.yellow] = true;
          isRobot[TokenType.blue] = true;
          break;
        case 2:
        // Red and Yellow are human, Green and Blue are robots
          isRobot[TokenType.green] = true;
          isRobot[TokenType.blue] = true;
          break;
        case 3:
          isRobot[TokenType.yellow] = true;
          break;
      // All human for case 4
      }
    } else {
      switch (numberOfHumanPlayers) {
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

    // Create all necessary players
    for (var tokenType in tokensToUse) {
      String colorName = tokenType.toString().split('.').last;
      String name = "${colorName[0].toUpperCase()}${colorName.substring(1).toLowerCase()} Player";

      players.add(LudoPlayer(
        tokenType: tokenType,
        name: name,
        isRobot: isRobot[tokenType] ?? false,
      ));
    }
  }


  bool checkForGameOver() {
    return players.where((users) => users.hasFinished == true).length == 1;
  }

  bool getMovableTokens(TokenType type, int diceValue) {
    return gameService.getMovableTokens(type, diceValue);
  }

  bool checkForInitialTokens(TokenType type) {
    return gameService.hasInitialToken(type);
  }

  bool _hasEnoughSpaceToMove (Token token, int diceValue) {
    return token.positionInPath + diceValue <= 56;
  }

}