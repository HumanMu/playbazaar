import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:playbazaar/games/games/ludo/helper/enum_converter.dart';
import '../../../helper/enum.dart';
import '../helper/enums.dart';
import '../models/ludo_online_model.dart';
import '../models/ludo_player.dart';
import '../models/position.dart';
import '../models/token.dart';
import 'base_ludo_service.dart';

class OnlineLudoService extends BaseLudoService {
  final DocumentReference ludoReference
  = FirebaseFirestore.instance.collection("games").doc('ludo');
  final user = FirebaseAuth.instance.currentUser;


  @override
  Future<BaseLudoService> init(int numberOfPlayer, {bool teamPlay = false}) async {
    await initializeGame();
    return this;
  }


  Future<String?> createLudoGame({
    required bool teamPlay,
    bool enableRobots = false,
    required String gameCode,
  }) async {
    try {
      if (user == null) throw Exception('No authenticated user found');

      final DocumentReference gameRef = ludoReference.collection('inProgress').doc();

      LudoOnlineModel gameData = LudoOnlineModel(
          gameId: gameRef.id,
          hostId: user!.uid,
          teamPlay: teamPlay,
          enableRobots: enableRobots,
          gameStatus: GameProgress.waitning,
          currentPlayerTurn: null,
          diceValue: null,
          canRollDice: false,
          gameTokens: [],
          teamAssignments: {},
          winnerOrder: [],
          gameCode: gameCode,
      );

      // Create the game document first
      await gameRef.set(gameData.toMap());
      await _addPlayerToGame(gameRef.id);

      return gameData.gameId;

    } catch (e) {
      debugPrint("Creating game failed with error - online ludo service: $e");
      throw Exception('Failed to create game - online ludo service: $e');
    }
  }


  
  Future<String?> joinExistingGame(String gameCode) async {
    try {
      if (user == null) throw Exception('No authenticated user found');

      LudoOnlineModel? gameDocument = await searchByGameCode(gameCode);

      if (gameDocument == null) {
        debugPrint("Game not found with code: $gameCode");
        return null;
      }

      if (gameDocument.gameStatus != GameProgress.waitning) {
        throw Exception('Game is no longer accepting players');
      }

      // Check if player already exists in this game
      final gameRef = ludoReference.collection('inProgress').doc(gameDocument.gameId);
      final existingPlayer = await gameRef.collection('players').doc(user!.uid).get();

      if (existingPlayer.exists) {
        await gameRef.collection('players').doc(user!.uid).update({
          'isConnected': true,
        });

      } else {
        await _addPlayerToGame(gameDocument.gameId);
      }

      return gameDocument.gameId;

    } catch (e) {
      debugPrint("Joining game failed with error: $e");
      return null;
    }
  }



  Future<void> _addTokens2Firestore(String gameId, TokenType tokenType) async {
    final gameRef = ludoReference.collection('inProgress').doc(gameId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final gameDoc = await transaction.get(gameRef);
      if (!gameDoc.exists) return;

      final gameData = LudoOnlineModel.fromMap(gameDoc.data()!);
      List<dynamic> currentTokens = List.from(gameData.gameTokens);

      // Each player gets 4 tokens, IDs should continue from the last
      final startTokenId = currentTokens.length;

      // Add 4 new tokens for this player
      for (int i = 0; i < 4; i++) {
        final tokenId = startTokenId + i;
        currentTokens.add({
          'id': tokenId,
          'state': 'initial',
          'positionInPath': 0,
        });
      }

      // Increment player count safely
      transaction.update(gameRef, {
        'gameTokens': currentTokens,
      });
    });
  }


  Future<void> initializeLocalTokens(int numberOfPlayer, {bool teamPlay = false}) async {
    isTeamPlayEnabled = teamPlay;

    // Offline token configuration
    final playerConfigs = {
      1: [TokenType.red],
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

  Future<LudoOnlineModel?> searchByGameCode(String gameCode) async {
    try {
      final querySnapshot = await ludoReference
          .collection('inProgress')
          .where('gameCode', isEqualTo: gameCode.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;

      return LudoOnlineModel.fromMap({
        ...doc.data(),
        'id': doc.id,
      });
    } catch (e) {
      debugPrint("Error searching game: $e");
      return null;
    }
  }


  Future<void> _addPlayerToGame(String gameId) async {
    final gameRef = ludoReference.collection('inProgress').doc(gameId);

    final gameDoc = await gameRef.get();
    final playersSnapshot = await gameRef.collection('players').get();

    if (!gameDoc.exists) throw Exception('Game not found');

    final gameData = LudoOnlineModel.fromMap(gameDoc.data()!);
    //final existingPlayers = playersSnapshot.docs.length;

    if (gameData.gameStatus != GameProgress.waitning) {
      throw Exception('Game is full');
    }

    // Determine available token type
    final existingTokenTypes = playersSnapshot.docs
        .map((doc) => doc.data()['tokenType'] as String)
        .toList();

    final availableTypes = ['green', 'yellow', 'blue', 'red'];
    final assignedTypeStr = availableTypes.firstWhere(
          (type) => !existingTokenTypes.contains(type),
      orElse: () => throw Exception('No available token types'),
    );

    final tokenType = string2TokenType(assignedTypeStr);

    // Create player data
    LudoPlayer playerData = LudoPlayer(
      playerId: user!.uid,
      name: user!.displayName ?? 'Player',
      avatarImg: user!.photoURL ?? '',
      tokenType: tokenType,
      teamId: null,
      isRobot: false,
      isConnected: true,
      numberOfreachedHome: 0,
      endedPosition: 0,
      hasFinished: false,
    );

    await _addTokens2Firestore(gameId, tokenType);
    await gameRef.collection('players').doc(user!.uid).set(playerData.toMap());
  }



  // Update game state in Firebase
  Future<void> updateGameState(Map<String, dynamic> updates, String gameId) async {
    try {
      final gameRef = ludoReference.collection('inProgress').doc(gameId);
      updates['lastUpdated'] = FieldValue.serverTimestamp();
      await gameRef.update(updates);
    } catch (e) {
      debugPrint("Failed to update game state: $e");
    }
  }



  Future<void> startGame(String gameId) async {

  }



  @override
  Future<bool> moveToken(Token token, int steps) async {

    if (!canMoveToken(token, steps)) return false;

    // Send move to server/other players first
    //await _sendMoveToServer(token, steps);

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

    // Check if move does not goes beyond the path length
    if (newPositionInPath >= pathLength) return false;
    final destination = getPosition(token.type, newPositionInPath);

    // Calculate what will happen at destination
    final moveResult = calculateMoveResult(token, destination);

    await animateTokenMovement(token, steps);
    bool didKill = await handleMoveResult(token, newPositionInPath, destination, moveResult);

    return didKill;
  }


  Future<void> leaveGame(String? gameId) async {

  }

  Future<void> removePlayerFromGame(String gameId, String userId) async {

  }

  Future<void> deleteGameWithPlayers(String gameId) async {
    final batch = FirebaseFirestore.instance.batch();
    final gameRef = ludoReference.collection('inProgress').doc(gameId);
    final playersSnapshot = await gameRef.collection('players').get();

    // Add all player deletions to batch
    for (final playerDoc in playersSnapshot.docs) {
      batch.delete(playerDoc.reference);
    }

    batch.delete(gameRef);
    await batch.commit();
  }

  // Restart game
  Future<void> restartGame(String gameId) async {

  }



  Stream<List<LudoPlayer>> listenToPlayersChanges(String gameId) {
    return ludoReference
        .collection('inProgress')
        .doc(gameId)
        .collection('players')
        .orderBy('joinedAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LudoPlayer.fromMap(doc.data()))
          .toList();
    }).handleError((error) {
      debugPrint('Error in getPlayersStreamByGameId: $error');
      return <LudoPlayer>[];
    });
  }

  Stream<LudoOnlineModel?> listenToGameStateChanges(String gameId) {
    return ludoReference
        .collection('inProgress')
        .doc(gameId)
        .snapshots()
        .map((doc) {
      try {
        if (doc.exists && doc.data() != null) {
          return LudoOnlineModel.fromMap(doc.data()!);
        }
        return null;
      } catch (e) {
        debugPrint('Error parsing game data: $e');
        return null;
      }
    }).handleError((error) {
      debugPrint('Error in listenToGameStateChanges: $error');
    });
  }


  @override
  void onClose() {
    leaveGame(null);
    super.onClose();
  }
}