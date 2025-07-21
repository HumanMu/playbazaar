import 'dart:async';
import '../helper/enums.dart';
import '../models/token.dart';
import 'base_ludo_service.dart';

class OfflineLudoService extends BaseLudoService {

  @override
  Future<BaseLudoService> init(int numberOfPlayer, {bool teamPlay = false}) async {
    await initializeBase(numberOfPlayer, teamPlay: teamPlay);
    return this;
  }

  @override
  Future<bool> moveToken(Token token, int steps) async {
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
    if (!isValidToken(token)) return false;

    final newPositionInPath = token.positionInPath + steps;
    final pathLength = getPathLength(token.type);

    // Check if move is valid
    if (newPositionInPath >= pathLength) return false;
    final destination = getPosition(token.type, newPositionInPath);

    // Calculate what will happen at destination
    final moveResult = calculateMoveResult(token, destination);

    // Animate the token movement
    await animateTokenMovement(token, steps);

    // Handle the result based on the calculation
    bool didKill = await handleMoveResult(token, newPositionInPath, destination, moveResult);

    return didKill;
  }
}