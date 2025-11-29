import 'package:get/get.dart';
import '../helper/enums.dart';

class DiceModel {
  // Core state
  final RxInt _diceValue = RxInt(1);
  final Rx<TokenType> _color = Rx<TokenType>(TokenType.blue);
  final RxInt _consecutiveSixes = RxInt(0);

  // UI state
  final RxBool _isRolling = RxBool(false);
  final RxBool _isAwaitingMove = RxBool(false);
  final RxBool _isRobotTurn = RxBool(false);
  final RxBool _rollState = RxBool(true);
  final RxBool _hasExtraTurn = RxBool(false);


  // Public Getters (read-only)
  int get diceValue => _diceValue.value;
  TokenType get color => _color.value;
  int get rxConsecutiveSixes => _consecutiveSixes.value;

  RxBool get rxIsRolling => _isRolling;
  bool get isAwaitingMove => _isAwaitingMove.value;
  bool get isRobotTurn => _isRobotTurn.value;
  bool get rollState => _rollState.value;
  bool get hasExtraTurn  => _hasExtraTurn.value;

  // Computed state
  bool get canBeRolledByHuman => rollState && !_isRolling.value && !isRobotTurn;
  bool get canBeRolledByRobot => !_isRolling.value;

  // Legacy compatibility
  bool get moveState => isAwaitingMove;
  bool get diceState => rollState;

  // Setters
  set diceValue(int value) => _diceValue.value = value;
  set color(TokenType value) => _color.value = value;
  set isRolling(bool value) => _isRolling.value = value;
  set isAwaitingMove(bool value) => _isAwaitingMove.value = value;
  set isRobotTurn(bool value) => _isRobotTurn.value = value;
  set rollState(bool value) => _rollState.value = value;
  set hasExtraTurn(bool value) => _hasExtraTurn.value = value;
  set rxConsecutiveSixes(int value) => _consecutiveSixes.value = value;

  // Business Logic: Maintainability first
  void handleDiceRollResult(int value) {
    if (value == 6) {
      _consecutiveSixes.value++;
    } else {
      _consecutiveSixes.value = 0;
    }
  }

  void refreshDiceColor() {
    _color.refresh();
  }
}
