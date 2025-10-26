import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:playbazaar/games/games/ludo/models/ludo_creattion_params.dart';
import '../../../helper/enum.dart';
import '../helper/enums.dart';
import '../models/ludo_online_model.dart';
import '../models/position.dart';
import '../models/single_online_player.dart';
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


  Future<String?> createLudoGame(LudoCreationParamsModel params) async {
    try {
      if (user == null) throw Exception('No authenticated user found');

      final DocumentReference gameRef = ludoReference.collection('inProgress').doc();
      final SingleOnlinePlayer singlePlayer = SingleOnlinePlayer(
          playerId: user!.uid,
          name: user!.displayName ?? 'Player',
          teamId: null,
          tokens: [-1, -1, -1, -1],
          color: null,
      );

      LudoOnlineModel gameData = LudoOnlineModel(
          gameId: gameRef.id,
          hostId: user!.uid,
          teamPlay: params.teamPlay,
          enableRobots: params.enableRobots,
          gameStatus: GameProgress.waitning,
          currentPlayerTurn: null,
          diceValue: null,
          canRollDice: false,
          players: [singlePlayer],
          winnerOrder: [],
          gameCode: params.gameCode!,
      );

      // Create the game document first
      await gameRef.set(gameData.toMap());
      //await _addPlayerToGame(gameRef.id);

      return gameData.gameId;

    } catch (e) {
      debugPrint("Creating game failed with error - online ludo service: $e");
      throw Exception('Failed to create game - online ludo service: $e');
    }
  }



  Future<String?> joinExistingGame(String inviteCode) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      final gameData = await searchByGameCode(inviteCode);

      if (gameData == null) {
        debugPrint("Game not found");
        return null;
      }

      // Check if user is already in the game
      if (gameData.players.any((player) => player.playerId == user.uid)) {
        debugPrint("User already in the game");
        return gameData.gameId;
      }

      // Check if the game is full
      if (gameData.players.length >= 4) {
        debugPrint("Game is full");
        return null;
      }

      final newPlayer = SingleOnlinePlayer(
        playerId: user.uid,
        name: user.displayName ?? 'Player',
        teamId: null,
        tokens: [-1, -1, -1, -1],
        color: null,
      );

      await ludoReference
          .collection('inProgress')
          .doc(gameData.gameId)
          .update({
        'players': FieldValue.arrayUnion([newPlayer.toMap()]),
      });

      return gameData.gameId;
    } catch (e) {
      debugPrint("Error joining game: $e");
      return null;
    }
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

      return LudoOnlineModel.fromMap(doc.data()).copyWith(gameId: doc.id);//LudoOnlineModel.fromMap(doc.data());
    } catch (e) {
      debugPrint("Error searching game: $e");
      return null;
    }
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



  Stream<LudoOnlineModel?> listenToGameStateChanges(String gameId) {
    debugPrint("Listening to game state changes for game ID: $gameId");

    return ludoReference
        .collection('inProgress')
        .doc(gameId)
        .snapshots()
        .map((doc) {
      try {
        debugPrint("Listening to game state changes for game ID: ${doc.data()}");

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