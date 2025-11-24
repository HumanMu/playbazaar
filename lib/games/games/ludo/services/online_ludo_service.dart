import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:playbazaar/games/games/ludo/models/ludo_creattion_params.dart';
import 'package:playbazaar/global_widgets/show_custom_snackbar.dart';
import '../../../helper/enum.dart';
import '../../../helper/enum_converter.dart';
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

  Future<void> updateDiceValue(String gameId, String nextPlayerId) async {
    final gameRef = ludoReference.collection('inProgress').doc(gameId);

    // Build single update with all changes
    await gameRef.update ({
      'currentPlayerTurn': nextPlayerId,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> createLudoGame(LudoCreationParamsModel params) async {
    try {
      if (user == null) throw Exception('No authenticated user found');

      final DocumentReference gameRef = ludoReference.collection('inProgress').doc();
      final SingleOnlinePlayer singlePlayer = SingleOnlinePlayer(
        playerId: user!.uid,
        name: user!.displayName ?? 'Player',
        teamId: null,
        isConnected: true,
        finishedTokensLength: 0,
        color: 'red',
      );

      // Initialize tokens map for first player
      Map<String, int> initialTokens = {
        'p0_t0': -1,
        'p0_t1': -1,
        'p0_t2': -1,
        'p0_t3': -1,
      };

      LudoOnlineModel gameData = LudoOnlineModel(
        gameId: gameRef.id,
        hostId: user!.uid,
        teamPlay: params.teamPlay,
        enableRobots: params.enableRobots,
        gameState: GameProgress.waiting,
        currentPlayerTurn: user!.uid,
        diceValue: null,
        players: {user!.uid: singlePlayer},
        winnerOrder: [],
        gameCode: params.gameCode!,
        tokens: initialTokens,
      );

      await gameRef.set(gameData.toMap());
      return gameData.gameId;

    } catch (e) {
      debugPrint("Creating game failed with error: $e");
      throw Exception('Failed to create game: $e');
    }
  }

  Future<String?> joinExistingGame(String inviteCode) async {
    try {
      if (user == null) throw Exception('No authenticated user found');

      final gameQuery = await ludoReference
          .collection('inProgress')
          .where('gameCode', isEqualTo: inviteCode.trim())
          .limit(1)
          .get();

      if (gameQuery.docs.isEmpty) {
        debugPrint("Game not found");
        return null;
      }

      final gameRef = gameQuery.docs.first.reference;

      return await FirebaseFirestore.instance.runTransaction<String?>((transaction) async {
        final gameSnapshot = await transaction.get(gameRef);

        if (!gameSnapshot.exists) {
          throw Exception("Game was deleted");
        }

        final gameData = LudoOnlineModel.fromMap(gameSnapshot.data()!);

        // Validation checks...
        if (gameData.players.containsKey(user!.uid)) {
          showCustomSnackbar("User already in the game", true);
          return gameData.gameId;
        }

        if (gameData.players.length >= 4) {
          showCustomSnackbar("Game is full", false);
          throw Exception("Game is full");
        }

        if (gameData.gameState == GameProgress.inProgress) {
          showCustomSnackbar("Game already started", false);
          throw Exception("Game already started");
        }

        // Calculate available colors and team
        final assignedColors = gameData.players.values.map((p) => p.color).toSet();
        String? teamId;
        List<String> availableColors;

        if (gameData.teamPlay) {
          final team1Count = gameData.players.values.where((p) => p.teamId == "1").length;
          final team2Count = gameData.players.values.where((p) => p.teamId == "2").length;
          teamId = team1Count <= team2Count ? "1" : "2";
          final teamColors = teamId == "1" ? ["red", "yellow"] : ["green", "blue"];
          availableColors = teamColors.where((c) => !assignedColors.contains(c)).toList();
        } else {
          availableColors = ["red", "yellow", "green", "blue"]
              .where((c) => !assignedColors.contains(c))
              .toList();
        }

        if (availableColors.isEmpty) {
          throw Exception("No available ${gameData.teamPlay ? 'team ' : ''}colors");
        }

        final newPlayer = SingleOnlinePlayer(
          playerId: user!.uid,
          name: user!.displayName ?? 'Player',
          teamId: teamId,
          color: availableColors.first,
          isConnected: true,
          finishedTokensLength: 0,
        );

        final newPlayerIndex = gameData.players.length;

        // Initialize tokens for new player
        Map<String, dynamic> tokenUpdates = {};
        for (int i = 0; i < 4; i++) {
          tokenUpdates['tokens.p${newPlayerIndex}_t$i'] = -1;
        }

        // ✅ Update using Map structure with userId as key
        transaction.update(gameRef, {
          'players.${user!.uid}': newPlayer.toMap(),
          ...tokenUpdates,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        return gameData.gameId;
      });

    } catch (e) {
      debugPrint("Error joining game: $e");
      return null;
    }
  }


  Future<void> initializeLocalTokens(int numberOfPlayer, {bool teamPlay = false}) async {
    isTeamPlayEnabled = teamPlay;

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


  Future<void> startGame(String gameId) async {
    try {
      final gameRef = ludoReference.collection('inProgress').doc(gameId);

      // ✅ Get first player (host) to set turn
      final gameSnapshot = await gameRef.get();
      final gameData = LudoOnlineModel.fromMap(gameSnapshot.data()!);

      await gameRef.update({
        'gameState': gameProgress2String(GameProgress.inProgress),
        'currentPlayerTurn': gameData.hostId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      debugPrint("Failed to start game: $e");
    }
  }

  Future<void> syncMoveToFirestore({
    required Token token,
    required int diceValue,
    required String gameId,
    Token? killedToken,
    required String nextPlayerTurn,
    required bool hasReached,
    required bool isLastReachedToken,
  }) async {
    try {
      final gameRef = ludoReference.collection('inProgress').doc(gameId);

      // Calculate player and token indices
      final playerIndex = _getPlayerIndexFromToken(token);
      final localTokenIndex = token.id % 4;

      // Determine Firestore position value
      int newPosition = token.positionInPath + diceValue;
      int firestorePosition = hasReached ? 56 : newPosition;
      bool isInitialToken = token.tokenState == TokenState.initial && diceValue == 6;

      // Build single update with all changes
      Map<String, dynamic> updates = {
        'tokens.p${playerIndex}_t$localTokenIndex': isInitialToken ? 0 : firestorePosition,
        'currentPlayerTurn': nextPlayerTurn,
        'diceValue': diceValue,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // If a token was killed, reset it
      if (killedToken != null) {
        final killedPlayerIndex = _getPlayerIndexFromToken(killedToken);
        final killedTokenIndex = killedToken.id % 4;
        updates['tokens.p${killedPlayerIndex}_t$killedTokenIndex'] = -1;
      }

      if (isLastReachedToken) {
        updates['winnerOrder'] = FieldValue.arrayUnion([user!.displayName]);
      }

      if(hasReached) {
        updates['players.${user!.uid}.finishedTokensLength'] = FieldValue.increment(1);
      }

      await gameRef.update(updates);

    } catch (e) {
      debugPrint("❌ Failed to sync move to Firestore: $e");
      rethrow;
    }
  }

  // Helper to determine player index from token type
  int _getPlayerIndexFromToken(Token token) {
    return _playerIndexMap[token.type] ?? 0;
  }

// Add this map to track player positions in the array
  final Map<TokenType, int> _playerIndexMap = {};

  void setPlayerIndexMap(Map<TokenType, int> mapping) {
    _playerIndexMap.clear();
    _playerIndexMap.addAll(mapping);
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

  @override
  Future<bool> moveToken(Token token, int steps, String? gameId, String nextPlayer, Token? didKill) {
    return  Future.value(Future.delayed(1.microseconds, () => true));
  }
}