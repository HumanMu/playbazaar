import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/ludo/config/ludo_config.dart';
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
        teamId: params.teamPlay? 1 : null,
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
        showCustomSnackbar("msg_game_not_found".tr, false);
        return null;
      }

      final gameRef = gameQuery.docs.first.reference;

      return await FirebaseFirestore.instance.runTransaction<String?>((transaction) async {
        final gameSnapshot = await transaction.get(gameRef);

        if (!gameSnapshot.exists) {
          showCustomSnackbar("msg_game_not_found".tr, false);
          throw Exception("Game not found");
        }

        final gameData = LudoOnlineModel.fromMap(gameSnapshot.data()!);

        // Validation checks
        if (gameData.players.containsKey(user!.uid)) {
          showCustomSnackbar("already_member".tr, true);
          return gameData.gameId;
        }

        if (gameData.players.length >= 4) {
          showCustomSnackbar("msg_game_not_found".tr, false);
          throw Exception("The game is full".tr);
        }

        // ✅ Find the first available player slot
        final playerIndex = _findFirstAvailablePlayerSlot(gameData);

        if (playerIndex == -1) {
          throw Exception("game_is_full".tr);
        }

        final assignedColor = GameConfig.colorSequences[playerIndex];

        int? teamId;
        if (gameData.teamPlay) {
          // Red+Yellow=Team1, Green+Blue=Team2
          teamId = (playerIndex == 0 || playerIndex == 1) ? 1 : 2;
        }

        final newPlayer = SingleOnlinePlayer(
          playerId: user!.uid,
          name: user!.displayName ?? 'Player',
          teamId: teamId,
          color: assignedColor,
          isConnected: true,
          finishedTokensLength: 0,
        );

        // Initialize tokens for new player
        Map<String, dynamic> tokenUpdates = {};
        for (int i = 0; i < 4; i++) {
          tokenUpdates['tokens.p${playerIndex}_t$i'] = -1;
        }

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

  // ✅ Helper method to find first available player slot
  int _findFirstAvailablePlayerSlot(LudoOnlineModel gameData) {
    // Sort players to maintain consistent indexing
    final sortedPlayers = gameData.players.values.toList()
      ..sort((a, b) {
        if (a.playerId == gameData.hostId) return -1;
        if (b.playerId == gameData.hostId) return 1;
        return a.playerId.compareTo(b.playerId);
      });

    // Check which indices (0-3) are already taken by existing players
    Set<int> occupiedIndices = {};

    for (final player in sortedPlayers) {
      final colorIndex = GameConfig.colorSequences.indexOf(player.color);
      if (colorIndex != -1) {
        occupiedIndices.add(colorIndex);
      }
    }

    // Find first available index (0-3)
    for (int i = 0; i < 4; i++) {
      if (!occupiedIndices.contains(i)) {
        return i;
      }
    }

    return -1; // No slots available
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

  Future<void> removePlayerFromGame(String gameId, String playerIdToRemove) async {
    try {
      final gameRef = ludoReference.collection('inProgress').doc(gameId);

      return await FirebaseFirestore.instance.runTransaction((transaction) async {
        final gameSnapshot = await transaction.get(gameRef);

        if (!gameSnapshot.exists) {
          throw Exception("Game not found");
        }

        final gameData = LudoOnlineModel.fromMap(gameSnapshot.data()!);

        // Validation: Only host can remove players
        if (gameData.hostId != user?.uid) {
          showCustomSnackbar("only_host_can_remove".tr, false);
          throw Exception("Only host can remove players");
        }

        // Validation: Can't remove yourself as host
        if (playerIdToRemove == user?.uid) {
          showCustomSnackbar("host_cannot_remove_self".tr, false);
          throw Exception("Host cannot remove themselves");
        }

        // Validation: Player must exist
        if (!gameData.players.containsKey(playerIdToRemove)) {
          showCustomSnackbar("player_not_found".tr, false);
          throw Exception("Player not found in game");
        }

        // ✅ Find player index based on their COLOR (not sorted position)
        final playerToRemove = gameData.players[playerIdToRemove]!;
        const colorSequence = ["red", "yellow", "green", "blue"];
        final playerIndex = colorSequence.indexOf(playerToRemove.color);

        if (playerIndex == -1) {
          throw Exception("Player index not found");
        }

        // Build update to remove player and their tokens
        Map<String, dynamic> updates = {
          'players.$playerIdToRemove': FieldValue.delete(),
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        // Remove player's tokens
        for (int i = 0; i < 4; i++) {
          updates['tokens.p${playerIndex}_t$i'] = FieldValue.delete();
        }

        // If it's this player's turn, move to next player
        if (gameData.currentPlayerTurn == playerIdToRemove) {
          // ✅ Sort remaining players by color order to find next turn
          final remainingPlayers = gameData.players.values
              .where((p) => p.playerId != playerIdToRemove)
              .toList()
            ..sort((a, b) {
              final indexA = colorSequence.indexOf(a.color);
              final indexB = colorSequence.indexOf(b.color);
              return indexA.compareTo(indexB);
            });

          // Find next player in turn order starting from removed player's position
          String? nextPlayerId;

          for (int i = 0; i < remainingPlayers.length; i++) {
            final candidateIndex = colorSequence.indexOf(remainingPlayers[i].color);

            // Find first player with higher color index than removed player
            if (candidateIndex > playerIndex) {
              nextPlayerId = remainingPlayers[i].playerId;
              break;
            }
          }

          // If no player found after removed player, wrap around to first player
          if (nextPlayerId == null && remainingPlayers.isNotEmpty) {
            nextPlayerId = remainingPlayers.first.playerId;
          }

          // If we found a next player, update turn
          if (nextPlayerId != null) {
            updates['currentPlayerTurn'] = nextPlayerId;
          } else {
            // Only one player left or no players, end game
            updates['gameState'] = gameProgress2String(GameProgress.finished);
          }
        }

        transaction.update(gameRef, updates);
      });

    } catch (e) {
      debugPrint("Failed to remove player: $e");
      rethrow;
    }
  }

  Future<void> leaveGame(String? gameId) async {
    if (gameId == null || user == null) {
      debugPrint("Cannot leave game: missing gameId or user");
      return;
    }

    try {
      final gameRef = ludoReference.collection('inProgress').doc(gameId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final gameSnapshot = await transaction.get(gameRef);

        if (!gameSnapshot.exists) {
          throw Exception("Game not found");
        }

        final gameData = LudoOnlineModel.fromMap(gameSnapshot.data()!);

        // Validation: Player must be in the game
        if (!gameData.players.containsKey(user!.uid)) {
          throw Exception("Player not in game");
        }

        final leavingPlayer = gameData.players[user!.uid]!;
        const colorSequence = ["red", "yellow", "green", "blue"];
        final playerIndex = colorSequence.indexOf(leavingPlayer.color);

        if (playerIndex == -1) {
          throw Exception("Player index not found");
        }

        Map<String, dynamic> updates = {
          'players.${user!.uid}': FieldValue.delete(),
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        // Remove player's tokens
        for (int i = 0; i < 4; i++) {
          updates['tokens.p${playerIndex}_t$i'] = FieldValue.delete();
        }

        if (gameData.currentPlayerTurn == user!.uid) {
          // ✅ Sort remaining players by color order
          final remainingPlayers = gameData.players.values
              .where((p) => p.playerId != user!.uid)
              .toList()
            ..sort((a, b) {
              final indexA = colorSequence.indexOf(a.color);
              final indexB = colorSequence.indexOf(b.color);
              return indexA.compareTo(indexB);
            });

          String? nextPlayerId;

          for (int i = 0; i < remainingPlayers.length; i++) {
            final candidateIndex = colorSequence.indexOf(remainingPlayers[i].color);

            if (candidateIndex > playerIndex) {
              nextPlayerId = remainingPlayers[i].playerId;
              break;
            }
          }

          if (nextPlayerId == null && remainingPlayers.isNotEmpty) {
            nextPlayerId = remainingPlayers.first.playerId;
          }

          if (nextPlayerId != null) {
            updates['currentPlayerTurn'] = nextPlayerId;
          } else {
            updates['gameState'] = gameProgress2String(GameProgress.finished);
          }
        }

        // If host is leaving, transfer host to next player
        if (gameData.hostId == user!.uid) {
          // ✅ Sort by color order to find new host
          final remainingPlayers = gameData.players.values
              .where((p) => p.playerId != user!.uid)
              .toList()
            ..sort((a, b) {
              final indexA = colorSequence.indexOf(a.color);
              final indexB = colorSequence.indexOf(b.color);
              return indexA.compareTo(indexB);
            });

          if (remainingPlayers.isNotEmpty) {
            updates['hostId'] = remainingPlayers.first.playerId;
          } else {
            transaction.delete(gameRef);
            return;
          }
        }

        // Check if only one player remains after leaving
        if (gameData.players.length <= 1) {
          updates['gameState'] = gameProgress2String(GameProgress.finished);
        }

        transaction.update(gameRef, updates);
      });

      debugPrint("Successfully left game");
    } catch (e) {
      debugPrint("Failed to leave game: $e");
      rethrow;
    }
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

  @override
  Future<bool> moveToken(Token token, int steps, String? gameId, String nextPlayer, Token? didKill) {
    return  Future.value(Future.delayed(1.microseconds, () => true));
  }
}