// Helper class to store move calculation results
import 'package:playbazaar/games/games/ludo/models/token.dart';
import '../helper/enums.dart';

class MoveResult {
  final Token? tokenToReset;
  final bool isSelfKill;
  final TokenState finalState;

  MoveResult({
    this.tokenToReset,
    this.isSelfKill = false,
    this.finalState = TokenState.normal,
  });
}