import 'package:get/get.dart';
import 'dart:async';
import '../helper/enums.dart';
import '../helper/path.dart';
import '../models/position.dart';
import '../models/token.dart';


class GameService extends GetxService {
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


  Future<GameService> init(int numberOfPlayer) async {
    _pathCache.clear();
    activeTokenTypes.clear();

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
    //int tokenIndex = 0;
    for (final type in activeTypes) {
      final tokenPositions = _getInitialPositions(type);
      final tokens = _createInitialTokens(type, tokenPositions[0], tokenPositions[1]);

      // Assign tokens to appropriate indices
      for (int i = 0; i < 4; i++) {
        allTokens[type.index * 4 + i] = tokens[i];
      }
    }

    gameTokens.value = allTokens;
    return this;
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

  
  Future<bool> moveToken(Token token, int steps) async {
    if (!_isValidToken(token)) return false;

    if (token.tokenState == TokenState.home) return false;
    if (token.tokenState == TokenState.initial && steps != 6) return false;

    bool didKill = false;

    if (token.tokenState == TokenState.initial && steps == 6) {
      await _moveTokenFromInitial(token);
    } else {
      didKill = await _moveTokenAlongPath(token, steps);
    }

    return didKill;
  }

  // Validate token to prevent errors
  bool _isValidToken(Token token) {
    return token.id >= 0 &&
        token.id < gameTokens.length &&
        gameTokens[token.id] != null &&
        activeTokenTypes.contains(token.type);
  }


  Future<void> _moveTokenFromInitial(Token token) async {
    if (!_isValidToken(token)) return;

    final destination = _getPosition(token.type, 0);
    _updateInitialPositions(token);
    _updateTokenState(token, TokenState.normal, newPosition: destination);
    gameTokens[token.id]?.positionInPath = 0;

    // Add a small delay to simulate animation time
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<bool> _moveTokenAlongPath(Token token, int steps) async {
    if (!_isValidToken(token)) return false;

    final newPositionInPath = token.positionInPath + steps;
    final pathLength = _getPathLength(token.type);

    // Check if move is valid
    if (newPositionInPath >= pathLength) return false;
    final destination = _getPosition(token.type, newPositionInPath);
    final resetToken = _updateBoardState(token, destination);

    // Create a list to store all animation futures
    List<Future<void>> animationFutures = [];
    int duration = 0;

    // Create all step animations
    for (int i = 1; i <= steps; i++) {
      duration = duration + 200;
      final stepDelay = Duration(milliseconds: duration);
      final stepFuture = Future.delayed(stepDelay, () {
        final stepLoc = token.positionInPath + i;
        _updateTokenState(
          token,
          token.tokenState,
          newPosition: _getPosition(token.type, stepLoc),
        );
        gameTokens[token.id]?.positionInPath = stepLoc;
      });
      animationFutures.add(stepFuture);
    }

    if (resetToken != null) {
      // Handle reset token animation
      for (int i = 1; i <= resetToken.positionInPath; i++) {
        duration = duration + 70;
        final resetDelay = Duration(milliseconds: duration);
        final resetStepFuture = Future.delayed(resetDelay, () {
          final stepLoc = resetToken.positionInPath - i;
          _updateTokenState(
            resetToken,
            resetToken.tokenState,
            newPosition: _getPosition(resetToken.type, stepLoc),
          );
          gameTokens[resetToken.id]?.positionInPath = stepLoc;
        });
        animationFutures.add(resetStepFuture);
      }

      final resetFinalFuture = Future.delayed(Duration(milliseconds: duration), () {
        _resetToken(resetToken);
      });
      animationFutures.add(resetFinalFuture);
    }

    if (newPositionInPath == pathLength - 1) {
      _updateTokenState(token, TokenState.home);
    }

    // Wait for ALL animations to complete before returning
    await Future.wait(animationFutures);

    bool didKill = resetToken != null;
    return didKill;
  }

  // Get path length with safety check
  int _getPathLength(TokenType type) {
    _ensurePathInitialized(type);
    return _pathCache[type]?.length ?? 0;
  }

  Position _getPosition(TokenType type, int step) {
    _ensurePathInitialized(type);

    if (!_pathCache.containsKey(type) || step >= _pathCache[type]!.length) {
      return Position(0, 0);
    }

    final node = _pathCache[type]![step];
    return Position(node[0], node[1]);
  }

  bool getMovableTokens(TokenType type, int diceRoll) {
    // Only check if token type is active
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
    // Only check if token type is active
    if (!activeTokenTypes.contains(type)) return false;

    return gameTokens
        .where((tkn) => tkn?.type == type && tkn?.tokenState == TokenState.initial)
        .isNotEmpty;
  }


  Token? _updateBoardState(Token token, Position destination) {
    // Star Check
    if (starPositions.contains(destination)) {
      gameTokens[token.id]?.tokenState = TokenState.safe;
      return null;
    }

    // Find Tokens at Destination
    final tokensAtDestination = gameTokens
        .where((tkn) => tkn != null && tkn.tokenPosition == destination)
        .cast<Token>()
        .toList();

    // Empty Destination
    if (tokensAtDestination.isEmpty) {
      gameTokens[token.id]?.tokenState = TokenState.normal;
      return null;
    }

    // Same Type Tokens at Destination
    final sameTypeTokens = tokensAtDestination
        .where((tkn) => tkn.type == token.type)
        .toList();

    if (sameTypeTokens.length == tokensAtDestination.length) {
      for (final tkn in sameTypeTokens) {
        gameTokens[tkn.id]?.tokenState = TokenState.safeinpair;
      }
      gameTokens[token.id]?.tokenState = TokenState.safeinpair;
      return null;
    }

    // Different Type Tokens at Destination
    Token? resetToken;
    for (final tkn in tokensAtDestination) {
      if (tkn.type != token.type && tkn.tokenState != TokenState.safeinpair) {
        resetToken = tkn;
      } else if (tkn.type == token.type) {
        gameTokens[tkn.id]?.tokenState = TokenState.safeinpair;
      }
    }

    // Place Token
    gameTokens[token.id]?.tokenState = tokensAtDestination.isNotEmpty
        ? TokenState.safeinpair
        : TokenState.normal;

    return resetToken;
  }

  void _updateTokenState(Token token, TokenState newState, {Position? newPosition}) {
    final index = gameTokens.indexWhere((t) => t?.id == token.id);
    if (index != -1) {
      final updatedToken = token.copyWith(
        tokenState: newState,
        tokenPosition: newPosition,
      );

      // Update the gameTokens list with the updated token
      final newList = List<Token?>.from(gameTokens);
      newList[index] = updatedToken;
      gameTokens.value = newList;
    }
  }

  void _updateInitialPositions(Token token) {
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

  void _resetToken(Token token) {
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

}

