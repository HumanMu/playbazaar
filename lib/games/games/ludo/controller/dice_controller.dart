import 'dart:math';
import 'package:get/get.dart';
import 'dart:async';
import '../models/dice_model.dart';
import '../models/ludo_player.dart';
import '../models/token.dart';
import '../helper/enums.dart';
import 'base_play_controller.dart';

class DiceController extends GetxController {
  final DiceModel dice = DiceModel();
  final BaseLudoController gameController = Get.find<BaseLudoController>();

  // Expose getters for easier access
  bool get giveAnotherTurn => dice.giveAnotherTurn;
  TokenType get diceColor => dice.diceColor;
  bool get moveState => dice.isAwaitingMove;
  bool get isRobotTurn => dice.isRobotTurn;
  bool get diceState => dice.isInteractive;
  int get consecvative6 => dice.rxConsecutiveSixes;
  int get diceValue => dice.diceValue;

  @override
  void onReady() {
    initializeFirstPlayer(gameController.players);
    super.onReady();
  }

  void initializeFirstPlayer(List<LudoPlayer> currentPlayers) {
    dice.rxConsecutiveSixes = 0;
    dice.giveAnotherTurn = false;

    for (var player in currentPlayers) {
      if (!player.hasFinished) {
        dice.diceColor = player.tokenType;
        dice.isRobotTurn = (player.isRobot ?? false) && gameController.isRobotOn.value;
        dice.isInteractive = !dice.isRobotTurn;
        dice.isAwaitingMove = false;
        dice.isRolling = false;

        if (dice.isRobotTurn) {
          Future.delayed(Duration(milliseconds: 800), () {
            if (dice.isRobotTurn && dice.diceColor == player.tokenType) {
              playRobotTurn();
            }
          });
        }
        break; // Found the first active player
      }
    }
  }


  Future<void> rollDice() async {
    if ((dice.isRobotTurn && !dice.canBeRolledByRobot) ||
        (!dice.isRobotTurn && !dice.canBeRolledByHuman)) {
      return;
    }

    try {
      // Start rolling animation
      dice.isRolling = true;
      if (!dice.isRobotTurn) {
        dice.isInteractive = false;
      }

      int finalValue = 0;
      for (int i = 0; i < 6; i++) {
        await Future.delayed(Duration(milliseconds: i == 0 ? 0 : 200));
        finalValue = _generateRandomDiceValue();
        dice.diceValue = finalValue;
      }

      dice.handleDiceRollResult(finalValue);
      dice.isRolling = false;

      if (finalValue == 6) {
        if (dice.rxConsecutiveSixes >= 3) {
          dice.rxConsecutiveSixes = 0;
          dice.giveAnotherTurn = false;
          await nextPlayer();
          return;
        }
      }else{
        dice.rxConsecutiveSixes = 0;
      }

      await moveToNextPlayerCheck(finalValue);

    } catch (e) {
      _resetDiceState();
    }
  }

  int _generateRandomDiceValue() {
    return Random().nextInt(6) + 1;
  }

  // Reset dice state in case of errors
  void _resetDiceState() {
    dice.isRolling = false;
    dice.isInteractive = true;
    dice.isAwaitingMove = false;
  }

  Future<void> moveToNextPlayerCheck(int diceValue) async {
    final availableToken = gameController.getMovableTokens(dice.diceColor, diceValue);

    if (diceValue != 6 && !availableToken) {
      await nextPlayer();
    }
    else if(diceValue == 6) {
      final hasInitialToken = gameController.checkForInitialTokens(dice.diceColor);
      if(!hasInitialToken && !availableToken) {
        await nextPlayer();
      }
      else {
        // Wait for token selection
        dice.isInteractive = false;
        dice.isAwaitingMove = true;
      }
    }
    else {
      // Wait for token selection
      dice.isInteractive = false;
      dice.isAwaitingMove = true;
    }
  }

  Future<void> nextPlayer() async {
    dice.giveAnotherTurn = false;
    dice.isAwaitingMove = false;
    dice.isRolling = false;

    await Future.delayed(const Duration(milliseconds: 500));
    final players = gameController.players;

    // Find current player index
    int currentIndex = players.indexWhere((player) => player.tokenType == dice.diceColor);
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
      dice.isInteractive = false;
      return;
    }

    final nextPlayer = players[nextIndex];
    dice.diceColor = nextPlayer.tokenType;
    dice.isInteractive = true;
    dice.isRobotTurn = (nextPlayer.isRobot ?? false) && gameController.isRobotOn.value;
    dice.rxConsecutiveSixes = 0;

    // Auto-play for robot
    if (dice.isRobotTurn) {
      dice.isInteractive = false;
      await Future.delayed(const Duration(milliseconds: 800));
      await playRobotTurn();
    } else {
      // Human turn, dice is already set to interactive
    }
  }


  Future<void> playRobotTurn() async {
    dice.isRobotTurn = true;
    dice.isInteractive = false;

    await rollDice();

    if (dice.isAwaitingMove) {
      await _selectRobotToken();
    }

    if (giveAnotherTurn && consecvative6 < 3) {
      await Future.delayed(const Duration(milliseconds: 800));
      await playRobotTurn();
    }
  }

  Future<void> _selectRobotToken() async {
    final tokens = gameController.gameTokens
        .whereType<Token>()
        .where((token) => token.type == diceColor)
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
      await nextPlayer();
    }
  }

  // For backward compatibility
  void setDiceState(bool state) {
    dice.isInteractive = state;
  }

  void setMoveState(bool state) {
    dice.isAwaitingMove = state;
  }
}
