import 'dart:math';
import 'package:get/get.dart';
import 'dart:async';
import '../models/dice_model.dart';
import '../models/ludo_player.dart';
import '../models/token.dart';
import '../helper/enums.dart';
import 'base_ludo_controller.dart';

class DiceController extends GetxController {
  final DiceModel dice = DiceModel();
  final BaseLudoController gameController = Get.find<BaseLudoController>();

  // Expose getters for easier access
  bool get hasExtraTurn  => dice.hasExtraTurn;
  TokenType get color => dice.color;
  bool get moveState => dice.isAwaitingMove;
  bool get isRobotTurn => dice.isRobotTurn;
  bool get diceState => dice.rollState;
  int get consecvative6 => dice.rxConsecutiveSixes;
  int get diceValue => dice.diceValue;

  @override
  void onReady() {
    initializeFirstPlayer(gameController.players);
    super.onReady();
  }

  void initializeFirstPlayer(List<LudoPlayer> currentPlayers) {
    dice.rxConsecutiveSixes = 0;
    dice.hasExtraTurn = false;

    for (var player in currentPlayers) {
      if (!player.hasFinished) {
        dice.color = player.tokenType;
        dice.isRobotTurn = (player.isRobot ?? false) && gameController.isRobotOn.value;
        dice.rollState = !dice.isRobotTurn;
        dice.isAwaitingMove = false;
        dice.isRolling = false;

        if (dice.isRobotTurn) {
          Future.delayed(Duration(milliseconds: 800), () {
            if (dice.isRobotTurn && dice.color == player.tokenType) {
              processRobotTurn();
            }
          });
        }
        break;
      }
    }
  }


  Future<void> handleDiceRoll() async {
    if ((dice.isRobotTurn && !dice.canBeRolledByRobot) ||
        (!dice.isRobotTurn && !dice.canBeRolledByHuman)) {
      return;
    }

    try {
      dice.isRolling = true;
      if (!dice.isRobotTurn) {
        dice.rollState = false;
      }

      int finalValue = 0;
      for (int i = 0; i < 6; i++) {
        await Future.delayed(Duration(milliseconds: i == 0 ? 0 : 200));
        finalValue = _rollDice();
        dice.diceValue = finalValue;
      }

      dice.isRolling = false;
      dice.handleDiceRollResult(finalValue);

      if (finalValue == 6) {
        if (dice.rxConsecutiveSixes >= 3) {
          dice.hasExtraTurn = false;
          await processNextPlayer();
          return;
        }
      }else{
        dice.rxConsecutiveSixes = 0;
      }

      await gameController.handleDiceRollResult(finalValue, dice.color);

    } catch (e) {
      _resetDiceState();
    }
  }

  int _rollDice() {
    return Random.secure().nextInt(6) + 1;
  }

  // Reset dice state in case of errors
  void _resetDiceState() {
    dice.isRolling = false;
    dice.rollState = true;
    dice.isAwaitingMove = false;
  }


  Future<void> processNextPlayer() async {
    dice.hasExtraTurn = false;
    dice.isAwaitingMove = false;
    dice.isRolling = false;

    await Future.delayed(const Duration(milliseconds: 500));
    final players = gameController.players;

    // Find current player index
    int currentIndex = players.indexWhere((player) => player.tokenType == dice.color);
    if (currentIndex == -1) {
      initializeFirstPlayer(players);
      return;
    }

    // Find the next *active* player in sequence
    int nextIndex = currentIndex;
    int checkedCount = 0;

    do {
      nextIndex = (nextIndex + 1) % players.length;
      checkedCount++;
      // Break if we found an unfinished player or checked everyone
      if (!players[nextIndex].hasFinished || checkedCount >= players.length) {
        break;
      }
    } while (true);


    if (checkedCount >= players.length && players.every((p) => p.hasFinished)) {
      dice.rollState = false;
      return;
    }

    final nextPlayer = players[nextIndex];
    dice.color = nextPlayer.tokenType;
    dice.rollState = true;
    dice.isRobotTurn = (nextPlayer.isRobot ?? false) && gameController.isRobotOn.value;
    dice.rxConsecutiveSixes = 0;

    // Auto-play for robot
    if (dice.isRobotTurn) {
      dice.rollState = false;
      await Future.delayed(const Duration(milliseconds: 800));
      await processRobotTurn();
    } else {
      // Human turn
    }
  }


  Future<void> processRobotTurn() async {
    dice.isRobotTurn = true;
    dice.rollState = false;

    await handleDiceRoll();

    /*if (dice.isAwaitingMove) {
      await selectRobotToken();
    }*/
    if (hasExtraTurn && consecvative6 < 3) {
      await Future.delayed(const Duration(milliseconds: 800));
      await processRobotTurn();
    }
  }

  Future<void> selectRobotToken() async {
    final tokens = gameController.gameTokens
        .whereType<Token>()
        .where((token) => token.type == color)
        .toList();

    // AI logic for token selection
    Token? tokenToMove;

    if (diceValue == 6) {
      tokenToMove = tokens.firstWhereOrNull(
              (token) => token.tokenState == TokenState.initial
      );
    }

    // Priority 2: Move existing tokens on board
    tokenToMove ??= tokens.firstWhereOrNull(
            (token) => token.tokenState != TokenState.initial &&
            token.tokenState != TokenState.home &&
            token.positionInPath + diceValue <= 56
    );

    if (tokenToMove != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      await gameController.handleTokenTap(tokenToMove);
    } else {
      await processNextPlayer();
    }
  }

  // For backward compatibility
  void setDiceRollState(bool state) {
    dice.rollState = state;
  }

  void setMoveState(bool state) {
    dice.isAwaitingMove = state;
  }

  void setColor(TokenType newColor) {
    dice.color = newColor;
    update();
  }

}
