import 'package:playbazaar/games/games/ludo/models/token.dart';

class TokenMoveOnline {
  final Token token;
  final int diceValue;
  final Token? killed;
  final String gameId;
  final String nextPlayerTurn;

  TokenMoveOnline({
    required this.token,
    required this.diceValue,
    this.killed,
    required this.gameId,
    required this.nextPlayerTurn,
  });
}