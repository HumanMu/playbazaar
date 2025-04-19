import 'dart:math';

import 'package:get/get.dart';
import 'dart:async';
import '../models/dice_model.dart';
import '../models/ludo_player.dart';
import '../models/token.dart';
import '../helper/enums.dart';
import './game_controller.dart';

class DiceController extends GetxController {
  final DiceModel dice = DiceModel();
  final GameController gameController = Get.find<GameController>();

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

  void initializeFirstPlayer(List<LudoPlayer> players) {
    for (var player in players) {
      if (!player.hasFinished) {
        dice.diceColor = player.tokenType;
        dice.isRobotTurn = player.isRobot ?? false;

        // Prepare initial state
        dice.isInteractive = true;
        dice.isAwaitingMove = false;
        dice.isRolling = false;

        // If robot starts, trigger its turn
        if (dice.isRobotTurn && gameController.isRobotOn.value) {
          Future.delayed(Duration(milliseconds: 800), () => playRobotTurn());
        }
        break;
      }
    }
  }

  Future<void> rollDice() async {
    // Skip if conditions not met based on who's rolling
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

      // Generate random values with animation delay
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
          return; // Critical to return here and skip token selection
        }
      }else{
        dice.rxConsecutiveSixes = 0;
      }

      await moveToNextPlayerCheck(finalValue);

    } catch (e) {
      _resetDiceState();
    }
  }

  // Generate a random dice value between 1-6
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
    await Future.delayed(const Duration(milliseconds: 500));
    final players = gameController.players;

    // Find the next player
    int currentIndex = players.indexWhere((player) => player.tokenType == dice.diceColor);
    int nextIndex = (currentIndex + 1) % players.length;
    int checkedCount = 0;

    while (checkedCount < players.length) {
      if (!players[nextIndex].hasFinished) break;
      nextIndex = (nextIndex + 1) % players.length;
      checkedCount++;
    }

    // Set the dice for next player
    dice.diceColor = players[nextIndex].tokenType;
    dice.isInteractive = true;
    dice.isAwaitingMove = false;
    dice.isRolling = false;

    // Check if robot player
    final isNextRobot = players[nextIndex].isRobot ?? false;
    dice.isRobotTurn = isNextRobot && gameController.isRobotOn.value;

    // Auto-play for robot
    if (dice.isRobotTurn) {
      await Future.delayed(const Duration(milliseconds: 800));
      await playRobotTurn();
    }
  }

  Future<void> playRobotTurn() async {
    dice.isRobotTurn = true;
    dice.isInteractive = false;

    await rollDice();

    // Handle token selection if needed
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

    // Priority 1: Get tokens out of home with a 6
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
