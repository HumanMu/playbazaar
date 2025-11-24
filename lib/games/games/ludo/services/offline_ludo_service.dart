import 'dart:async';
import '../helper/enums.dart';
import '../models/position.dart';
import '../models/token.dart';
import 'base_ludo_service.dart';

class OfflineLudoService extends BaseLudoService {

  @override
  Future<BaseLudoService> init(int numberOfPlayer, {bool teamPlay = false}) async {
    await initializeGame();
    await _initializeOfflineTokens(numberOfPlayer, teamPlay: teamPlay);
    //await initializeBase(numberOfPlayer, teamPlay: teamPlay);
    return this;
  }

  Future<void> _initializeOfflineTokens(int numberOfPlayer, {bool teamPlay = false}) async {
    isTeamPlayEnabled = teamPlay;

    // Offline token configuration
    final playerConfigs = {
      2: [TokenType.yellow, TokenType.red],
      3: [TokenType.green, TokenType.blue, TokenType.red],
      4: [TokenType.green, TokenType.yellow, TokenType.blue, TokenType.red],
    };

    final activeTypes = playerConfigs[numberOfPlayer] ?? playerConfigs[4]!;
    activeTokenTypes.addAll(activeTypes);

    // Initialize paths for active token types
    for (final type in activeTypes) {
      ensurePathInitialized(type);
    }

    // Create and assign tokens - use individual assignment instead of replacing entire list
    for (final type in activeTypes) {
      final tokens = _createHomeTokensForType(type);

      for (int i = 0; i < 4; i++) {
        final tokenIndex = type.index * 4 + i;
        if (tokenIndex < gameTokens.length) {
          gameTokens[tokenIndex] = tokens[i];
        }
      }
    }

    // Trigger UI update
    gameTokens.refresh();
  }

  List<Token> _createHomeTokensForType(TokenType type) {
    final basePosition = getTokenHomePosition(type);

    return List.generate(4, (index) {
      // Create 2x2 grid of tokens in home area
      final row = basePosition.row + (index ~/ 2);
      final column = basePosition.column + (index % 2);

      return Token(
        type,
        Position(column, row),
        TokenState.initial,
        (type.index * 4) + index,
      );
    });
  }



  @override
  Future<bool> moveToken(Token token, int steps, String? gameId, String? nextPlayer, Token? didKill) async { // gameId, and nextPlayer only for online playing
    if (!canMoveToken(token, steps)) return false;

    bool didKill = false;

    if (token.tokenState == TokenState.initial && steps == 6) {
      await moveTokenFromInitial(token);
    } else {
      didKill = await _moveTokenAlongPath(token, steps);
    }

    return didKill;
  }

  Future<bool> _moveTokenAlongPath(Token token, int steps) async {
    if (!canTokenMove(token, steps)) return false;
    final newPositionInPath = token.positionInPath + steps;

    final destination = getPosition(token.type, newPositionInPath);

    // Calculate what will happen at destination
    final moveResult = calculateMoveResult(token, destination);

    // Animate the token movement
    await animateTokenMovement(token, steps);

    // Handle the result based on the calculation
    Token? didKill = await handleMoveResult(token, newPositionInPath, destination, moveResult);

    return didKill == null ? false : true;
  }
}