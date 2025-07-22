import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../helper/enums.dart';
import '../helper/path.dart';
import '../models/move_result.dart';
import '../models/position.dart';
import '../models/token.dart';

abstract class BaseLudoService extends GetxService {
  final Map<TokenType, int?> teamAssignments = <TokenType, int?>{};
  late bool isTeamPlayEnabled = false;

  final RxList<Token?> gameTokens = RxList<Token?>(List<Token?>.filled(16, null));
  final Set<TokenType> activeTokenTypes = <TokenType>{};

  // Initialize paths once and cache them
  static final Map<TokenType, List<List<int>>> _pathCache = {};

  final RxList<Position> starPositions = RxList<Position>([
    const Position(6, 1),
    const Position(2, 6),
    const Position(1, 8),
    const Position(6, 12),
    const Position(8, 13),
    const Position(12, 8),
    const Position(13, 6),
    const Position(8, 2),
  ]);

  final RxList<Position> greenInitial = RxList<Position>([]);
  final RxList<Position> yellowInitial = RxList<Position>([]);
  final RxList<Position> blueInitial = RxList<Position>([]);
  final RxList<Position> redInitial = RxList<Position>([]);

  // Abstract methods that must be implemented by subclasses
  Future<BaseLudoService> init(int numberOfPlayer, {bool teamPlay = false});
  Future<bool> moveToken(Token token, int steps);

  // Common initialization logic
  Future<void> initializeBase(int numberOfPlayer, {bool teamPlay = false}) async {
    _pathCache.clear();
    activeTokenTypes.clear();
    teamAssignments.clear();
    isTeamPlayEnabled = teamPlay;

    // Prepare token lists
    List<Token?> allTokens = List<Token?>.filled(16, null);

    // Map configurations for different player counts
    final playerConfigs = {
      2: [TokenType.yellow, TokenType.red],
      3: [TokenType.green, TokenType.blue, TokenType.red],
      4: [TokenType.green, TokenType.yellow, TokenType.blue, TokenType.red],
    };

    // Get active token types based on player count
    final activeTypes = playerConfigs[numberOfPlayer] ?? playerConfigs[4]!;
    activeTokenTypes.addAll(activeTypes);

    // Initialize paths for active token types only
    for (final type in activeTypes) {
      _ensurePathInitialized(type);
    }

    // Initialize tokens based on active types
    for (final type in activeTypes) {
      final tokenPositions = _getInitialPositions(type);
      final tokens = _createInitialTokens(type, tokenPositions[0], tokenPositions[1]);

      // Assign tokens to appropriate indices
      for (int i = 0; i < 4; i++) {
        allTokens[type.index * 4 + i] = tokens[i];
      }
    }

    gameTokens.value = allTokens;
  }

  // Ensure path is initialized - loads path only when needed
  void _ensurePathInitialized(TokenType type) {
    if (!_pathCache.containsKey(type)) {
      _pathCache[type] = PathHelper.getPath(type);
    }
  }

  List<int> _getInitialPositions(TokenType type) {
    switch (type) {
      case TokenType.green: return [2, 2];
      case TokenType.yellow: return [2, 11];
      case TokenType.blue: return [11, 11];
      case TokenType.red: return [11, 2];
    }
  }

  // Add a method to set team assignments
  void setTeamAssignments(Map<TokenType, int?> assignments) {
    teamAssignments.clear();
    teamAssignments.addAll(assignments);
  }

  // Add helper method to check teammates
  bool areTeammates(TokenType type1, TokenType type2) {
    if (!isTeamPlayEnabled) return false;
    if (type1 == type2) return true;

    final team1 = teamAssignments[type1];
    final team2 = teamAssignments[type2];

    // For debugging
    if (team1 != null && team2 != null) {
      debugPrint("Team check: $type1 (Team $team1) and $type2 (Team $team2) - ${team1 == team2 ? 'Same team' : 'Different teams'}");
    }

    return team1 != null && team2 != null && team1 == team2;
  }

  List<Token> _createInitialTokens(TokenType type, int startX, int startY) {
    return List.generate(4, (index) {
      return Token(
        type,
        Position(startX + index % 2, startY + index ~/ 2),
        TokenState.initial,
        (type.index * 4) + index,
      );
    });
  }

  // Common token validation logic
  bool isValidToken(Token token) {
    return token.id >= 0 &&
        token.id < gameTokens.length &&
        gameTokens[token.id] != null &&
        activeTokenTypes.contains(token.type);
  }

  // Common move validation logic
  bool canMoveToken(Token token, int steps) {
    if (!isValidToken(token)) return false;
    if (token.tokenState == TokenState.home) return false;
    if (token.tokenState == TokenState.initial && steps != 6) return false;
    return true;
  }

  // Common logic for moving token from initial position
  Future<void> moveTokenFromInitial(Token token) async {
    if (!isValidToken(token)) return;

    final destination = getPosition(token.type, 0);
    updateInitialPositions(token);
    updateTokenState(token, TokenState.normal, newPosition: destination);
    gameTokens[token.id]?.positionInPath = 0;

    // Add a small delay to simulate animation time
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Common move result calculation
  MoveResult calculateMoveResult(Token token, Position destination) {
    // Check if destination is a star position (safe)
    if (starPositions.contains(destination)) {
      return MoveResult(finalState: TokenState.safe);
    }

    // Find tokens at destination
    final tokensAtDestination = gameTokens
        .where((tkn) => tkn != null && tkn.id != token.id &&
        tkn.tokenPosition == destination &&
        tkn.tokenState != TokenState.home)
        .cast<Token>()
        .toList();

    if (tokensAtDestination.isEmpty) {
      return MoveResult(finalState: TokenState.normal);
    }

    // If ALL tokens at destination are the same type as the incoming token, don't kill
    final allSameType = tokensAtDestination.every((tkn) => tkn.type == token.type);
    if (allSameType) {
      return MoveResult(finalState: TokenState.safeinpair);
    }

    // Separate teammates and opponents
    final List<Token> teammatesAtDestination = [];
    final List<Token> opponentsAtDestination = [];

    for (final tkn in tokensAtDestination) {
      if (areTeammates(token.type, tkn.type)) {
        teammatesAtDestination.add(tkn);
      } else {
        opponentsAtDestination.add(tkn);
      }
    }

    // Apply game rules
    if (opponentsAtDestination.length >= 2) {
      // Self-kill if 2+ opponents
      return MoveResult(
          tokenToReset: token,
          isSelfKill: true,
          finalState: TokenState.normal
      );
    } else if (opponentsAtDestination.isNotEmpty) {
      // Kill one opponent
      return MoveResult(
          tokenToReset: opponentsAtDestination.first,
          finalState: TokenState.normal
      );
    } else if (teammatesAtDestination.isNotEmpty) {
      // Safe with teammates
      return MoveResult(finalState: TokenState.safeinpair);
    }

    return MoveResult(finalState: TokenState.normal);
  }

  // Common animation logic
  Future<void> animateTokenMovement(Token token, int steps) async {
    List<Future<void>> animationFutures = [];

    for (int i = 1; i <= steps; i++) {
      final stepDelay = Duration(milliseconds: 200 * i);
      final stepPosition = token.positionInPath + i;

      final stepFuture = Future.delayed(stepDelay, () {
        updateTokenState(
          token,
          token.tokenState,
          newPosition: getPosition(token.type, stepPosition),
        );
        gameTokens[token.id]?.positionInPath = stepPosition;
      });

      animationFutures.add(stepFuture);
    }

    await Future.wait(animationFutures);
  }

  // Common move result handling
  Future<bool> handleMoveResult(Token token, int newPositionInPath, Position destination, MoveResult result) async {
    final pathLength = getPathLength(token.type);

    // Update token state for normal movement (not self-kill)
    if (!result.isSelfKill) {
      final finalState = newPositionInPath == pathLength - 1
          ? TokenState.home
          : result.finalState;

      updateTokenState(token, finalState, newPosition: destination);

      // Update teammates if forming a safe pair
      if (result.finalState == TokenState.safeinpair) {
        updateTeammatesState(token, destination);
      }
    }

    // Handle token reset (either opponent or self)
    if (result.tokenToReset != null) {
      if (result.isSelfKill) {
        // Brief pause for self-kill visual feedback
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Immediate reset animation with no delay between steps
      await animateTokenReset(result.tokenToReset!);
      return true;
    }

    return false;
  }

  // Update teammates at destination to be safe in pair
  void updateTeammatesState(Token token, Position destination) {
    final teammatesAtDestination = gameTokens
        .where((tkn) => tkn != null && tkn.id != token.id &&
        tkn.tokenPosition == destination &&
        areTeammates(token.type, tkn.type))
        .cast<Token>()
        .toList();

    for (final teammate in teammatesAtDestination) {
      final teammateIndex = gameTokens.indexWhere((t) => t?.id == teammate.id);
      if (teammateIndex != -1) {
        final currentTeammate = gameTokens[teammateIndex];
        if(currentTeammate != null){
          gameTokens[teammateIndex] = currentTeammate.copyWith(tokenState: TokenState.safeinpair);
        }
      }
    }
    gameTokens.refresh();
  }

  // Animate token reset with faster animation
  Future<void> animateTokenReset(Token tokenToReset) async {
    List<Future<void>> resetFutures = [];

    // Use faster animation for reset (40ms per step instead of 70ms)
    for (int i = 1; i <= tokenToReset.positionInPath; i++) {
      final stepLoc = tokenToReset.positionInPath - i;
      final resetDelay = Duration(milliseconds: 40 * i);

      final resetStepFuture = Future.delayed(resetDelay, () {
        updateTokenState(
          tokenToReset,
          tokenToReset.tokenState,
          newPosition: getPosition(tokenToReset.type, stepLoc),
        );
        gameTokens[tokenToReset.id]?.positionInPath = stepLoc;
      });

      resetFutures.add(resetStepFuture);
    }

    await Future.wait(resetFutures);
    resetToken(tokenToReset);
  }

  // Get path length with safety check
  int getPathLength(TokenType type) {
    _ensurePathInitialized(type);
    return _pathCache[type]?.length ?? 0;
  }

  Position getPosition(TokenType type, int step) {
    _ensurePathInitialized(type);

    if (!_pathCache.containsKey(type) || step >= _pathCache[type]!.length) {
      return Position(0, 0);
    }

    final node = _pathCache[type]![step];
    return Position(node[0], node[1]);
  }

  bool getMovableTokens(TokenType type, int diceRoll) {
    if (!activeTokenTypes.contains(type)) return false;

    return gameTokens
        .where((element) =>
    element?.type == type &&
        element?.tokenState != TokenState.initial &&
        element != null &&
        (57 - (element.positionInPath + diceRoll) > 0))
        .isNotEmpty;
  }

  bool hasInitialToken(TokenType type) {
    if (!activeTokenTypes.contains(type)) return false;

    return gameTokens
        .where((tkn) => tkn?.type == type && tkn?.tokenState == TokenState.initial)
        .isNotEmpty;
  }

  // Common token state update logic
  void updateTokenState(Token token, TokenState newState, {Position? newPosition}) {
    final index = gameTokens.indexWhere((t) => t?.id == token.id);
    if (index != -1) {
      final currentToken = gameTokens[index];
      if (currentToken != null) {
        gameTokens[index] = currentToken.copyWith(
          tokenState: newState,
          tokenPosition: newPosition ?? currentToken.tokenPosition,
        );
        gameTokens.refresh();
      }
    } else {
      debugPrint("Error: Token with ID ${token.id} not found in gameTokens for state update.");
    }
  }

  void updateInitialPositions(Token token) {
    switch (token.type) {
      case TokenType.green:
        greenInitial.add(token.tokenPosition);
        break;
      case TokenType.yellow:
        yellowInitial.add(token.tokenPosition);
        break;
      case TokenType.blue:
        blueInitial.add(token.tokenPosition);
        break;
      case TokenType.red:
        redInitial.add(token.tokenPosition);
        break;
    }
  }

  void resetToken(Token token) {
    final colorMap = {
      TokenType.green: () => greenInitial.removeAt(0),
      TokenType.yellow: () => yellowInitial.removeAt(0),
      TokenType.blue: () => blueInitial.removeAt(0),
      TokenType.red: () => redInitial.removeAt(0),
    };

    final updateFunction = colorMap[token.type];
    if (updateFunction != null) {
      final position = updateFunction();
      gameTokens[token.id]?.tokenState = TokenState.initial;
      gameTokens[token.id]?.tokenPosition = position;
    }
  }

  // Common game logic methods
  List<Token> getTokensAtPosition(Position position) {
    return gameTokens.whereType<Token>().where((token) =>
    token.tokenPosition.row == position.row &&
        token.tokenPosition.column == position.column
    ).toList();
  }

  Offset getTokenOffsetAtPosition(Token token) {
    final tokensAtPosition = getTokensAtPosition(token.tokenPosition);

    if (tokensAtPosition.length <= 1) {
      return Offset.zero;
    }

    final indexInStack = tokensAtPosition.indexWhere((t) => t.id == token.id);
    if (indexInStack == -1) return Offset.zero;

    final baseOffset = 9.0;
    final angle = (indexInStack * (2 * math.pi / 8)) % (2 * math.pi);
    final distance = baseOffset * (1 + indexInStack * 0.3);

    return Offset(
        math.cos(angle) * distance,
        math.sin(angle) * distance
    );
  }

  List<double> getTokenDisplayPosition(
      Token token,
      double boardSize,
      List<double>? calculatedPosition, // Pass the calculated position
      ) {
    final cellSize = boardSize / 15;

    // If no calculated position provided or calculation failed, use logical position
    if (calculatedPosition == null ||
        (calculatedPosition[0] == 0 && calculatedPosition[1] == 0 &&
            calculatedPosition[2] == 0 && calculatedPosition[3] == 0)) {
      return [
        token.tokenPosition.column * cellSize,
        token.tokenPosition.row * cellSize,
        cellSize,
        cellSize,
      ];
    }

    // Ensure token stays within board boundaries
    final clampedX = calculatedPosition[0].clamp(0.0, boardSize - cellSize);
    final clampedY = calculatedPosition[1].clamp(0.0, boardSize - cellSize);

    return [clampedX, clampedY, cellSize, cellSize];
  }
}