import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/functions/dialog_manager.dart';
import 'package:playbazaar/games/games/ludo/models/ludo_creattion_params.dart';
import 'package:playbazaar/games/games/ludo/models/single_online_player.dart';
import 'package:playbazaar/games/games/ludo/services/online_ludo_service.dart';
import '../../../../global_widgets/show_custom_snackbar.dart';
import '../../../entities/dialog_request_model.dart';
import '../../../helper/enum.dart';
import '../helper/enums.dart';
import '../models/ludo_online_model.dart';
import '../models/ludo_player.dart';
import '../models/position.dart';
import '../models/token.dart';
import '../widgets/ludo_waiting_room_dialog.dart';
import 'base_ludo_controller.dart';


class OnlineLudoController extends BaseLudoController {
  final RxString gameCode = ''.obs;
  final RxBool canStart = false.obs;
  final RxString gameId = ''.obs;
  final user = FirebaseAuth.instance.currentUser;
  final onlineGameService = Get.find<OnlineLudoService>();
  TokenType myTokenType = TokenType.red;

  StreamSubscription<LudoOnlineModel?>? _gameStateSubscription;

  @override
  Future<void> onBoardBuilt() async {
    await initializeOnlineGameState();
  }

  Future<void> initializeOnlineGameState() async {}

  @override
  Future<void> initializePlayers() async {}


  @override
  Future<void> initializeServices(LudoCreationParamsModel params) async {

  }

  Future<void> createLudoGame(LudoCreationParamsModel params) async{
    String? gameRef = await onlineGameService.createLudoGame(params);

    if(gameRef == null){
      showCustomSnackbar("unexpected_result".tr, false);
      return;
    }

    gameId.value = gameRef;
    await _listeningToGameState();
  }

  Future<void> joinExistingGame(String gameCode) async {
    String? gameRef = await onlineGameService.joinExistingGame(gameCode);

    if(gameRef == null){
      showCustomSnackbar("unexpected_result".tr, false);
      return;
    }


    showWaitingRoom();
    gameId.value = gameRef;
    await _listeningToGameState();
  }

  Future<void> _listeningToGameState() async {
    if (gameId.value.isEmpty) {
      debugPrint("Game ID is empty, cannot start listening to players");
      return;
    }

    _gameStateSubscription = onlineGameService.listenToGameStateChanges(gameId.value)
        .listen((gameState) {
      if (gameState != null) {
        debugPrint("Game state received with ${gameState.players.length} players");

        // Only sync players if the count changed or it's the first sync
        final shouldSyncPlayers = players.length != gameState.players.length ||
            players.isEmpty ||
            _hasPlayerListChanged(gameState.players);

        if (shouldSyncPlayers) {
          debugPrint("Player list changed, syncing...");
          _syncPlayersFromFirestore(gameState.players);

          // Initialize active token types in the service
          gameService.activeTokenTypes.clear();
          for (final player in players) {
            gameService.activeTokenTypes.add(player.tokenType);
            gameService.ensurePathInitialized(player.tokenType);
          }
        }

        // Always update tokens (this is what changes frequently)
        _createLocalTokensFromFirestore(gameState.players);

        // Update player progress (tokens finished, etc.)
        _updatePlayerProgress(gameState.players);

        // Only show waiting room if not started
        if (gameState.gameStatus == GameProgress.waitning) {
          showWaitingRoom();
        }
      }
    },
      onError: (error) {
        debugPrint("Error listening to game state: $error");
        showCustomSnackbar("connection_error".tr, false);
      },
    );
  }

  bool _hasPlayerListChanged(List<SingleOnlinePlayer> firestorePlayers) {
    if (players.length != firestorePlayers.length) return true;

    // Check if player IDs match
    final currentPlayerIds = players.map((p) => p.playerId).toSet();
    final newPlayerIds = firestorePlayers.map((p) => p.playerId).toSet();

    return !currentPlayerIds.containsAll(newPlayerIds) ||
        !newPlayerIds.containsAll(currentPlayerIds);
  }


  void _updatePlayerProgress(List<SingleOnlinePlayer> firestorePlayers) {
    final localTokenTypeMap = _mapPlayersToLocalTokenTypes(firestorePlayers);

    for (final firestorePlayer in firestorePlayers) {
      final localTokenType = localTokenTypeMap[firestorePlayer.playerId];
      if (localTokenType == null) continue;

      final playerIndex = players.indexWhere((p) => p.playerId == firestorePlayer.playerId);
      if (playerIndex != -1) {
        players[playerIndex] = players[playerIndex].copyWith(
          numberOfreachedHome: firestorePlayer.tokensFinished,
          hasFinished: firestorePlayer.hasWon,
        );
      }
    }
  }


  void _createLocalTokensFromFirestore(List<SingleOnlinePlayer> firestorePlayers) {
    // Clear existing tokens
    for (int i = 0; i < gameTokens.length; i++) {
      gameTokens[i] = null;
    }

    // Map each player to a local TokenType
    final localTokenTypeMap = _mapPlayersToLocalTokenTypes(firestorePlayers);

    for (int playerIndex = 0; playerIndex < firestorePlayers.length; playerIndex++) {
      final firestorePlayer = firestorePlayers[playerIndex];
      final localTokenType = localTokenTypeMap[firestorePlayer.playerId]!;

      // Create 4 tokens for this player
      for (int tokenIndex = 0; tokenIndex < 4; tokenIndex++) {
        final globalTokenId = (playerIndex * 4) + tokenIndex;
        final firestorePosition = firestorePlayer.tokens[tokenIndex]; // -1, 0-56, or 57

        Position localPosition;
        TokenState tokenState;
        int positionInPath;

        if (firestorePosition == -1) {
          // Token at home (initial state)
          final basePosition = gameService.getTokenHomePosition(localTokenType);
          localPosition = Position(
            basePosition.row + (tokenIndex ~/ 2),
            basePosition.column + (tokenIndex % 2),
          );
          tokenState = TokenState.initial;
          positionInPath = 0;
        } else if (firestorePosition == 57) {
          // Token finished
          localPosition = gameService.getPosition(localTokenType, 56);
          tokenState = TokenState.home;
          positionInPath = 56;
        } else {
          // Token on board (0-56)
          positionInPath = firestorePosition;
          localPosition = gameService.getPosition(localTokenType, positionInPath);
          tokenState = TokenState.normal; // You may need logic to determine safe/safeinpair
        }

        final token = Token(
          localTokenType,
          localPosition,
          tokenState,
          globalTokenId,
          positionInPath: positionInPath,
        );

        gameTokens[globalTokenId] = token;
      }
    }

    gameService.gameTokens.refresh();
    _updatePlayerStates();
  }


  Map<String, TokenType> _mapPlayersToLocalTokenTypes(List<SingleOnlinePlayer> firestorePlayers) {
    final myUserId = user?.uid;
    final Map<String, TokenType> mapping = {};

    // Find my player index
    final myPlayerIndex = firestorePlayers.indexWhere((p) => p.playerId == myUserId);

    if (myPlayerIndex != -1) {
      mapping[firestorePlayers[myPlayerIndex].playerId] = myTokenType;
    }

    // Assign colors to other players
    final availableColors = [TokenType.red, TokenType.green, TokenType.yellow, TokenType.blue];
    availableColors.remove(myTokenType);

    int colorIndex = 0;
    for (int i = 0; i < firestorePlayers.length; i++) {
      if (i == myPlayerIndex) continue; // Skip self

      mapping[firestorePlayers[i].playerId] = availableColors[colorIndex % availableColors.length];
      colorIndex++;
    }

    return mapping;
  }


  void _syncPlayersFromFirestore(List<SingleOnlinePlayer> firestorePlayers) {
    players.clear();

    // Map each Firestore player to a LudoPlayer
    final localTokenTypeMap = _mapPlayersToLocalTokenTypes(firestorePlayers);

    for (final firestorePlayer in firestorePlayers) {
      final localTokenType = localTokenTypeMap[firestorePlayer.playerId]!;

      // Check if this is the current user
      final isMe = firestorePlayer.playerId == user?.uid;

      players.add(LudoPlayer(
        playerId: firestorePlayer.playerId,
        name: firestorePlayer.name,
        tokenType: localTokenType,
        numberOfreachedHome: firestorePlayer.tokensFinished,
        hasFinished: firestorePlayer.hasWon,
        isRobot: false,
        teamId: firestorePlayer.teamId != null ? int.tryParse(firestorePlayer.teamId!) : null,
        isConnected: true,
      ));

      // Store your token type for future reference
      if (isMe) {
        myTokenType = localTokenType;
      }
    }

    debugPrint("Synced ${players.length} players");
  }


  // Update game state when players change
  void _updatePlayerStates() {
    numberOfHumanPlayers.value = players.length;
    canStart.value = players.length >= 2 && players.length <= 4;

    if (players.isNotEmpty && boardBuild.value) {

    }
  }


  @override
  Future<void> handleTokenTap(Token token) async {
    try {
      await onlineGameService.moveToken(token, diceController.diceValue);
    } catch (e) {
      debugPrint("Failed to make move: $e");
      showCustomSnackbar("move_failed".tr, false);
    }
  }

  @override
  Future<void> moveToken(Token token, dynamic controller) async {
    try {
      await onlineGameService.moveToken(token, diceController.diceValue);
    } catch (e) {
      debugPrint("Failed to make move: $e");
      showCustomSnackbar("move_failed".tr, false);
    }
  }

  @override
  void restartGame() async {
    try {
      await onlineGameService.restartGame(gameId.value);
    } catch (e) {
      debugPrint("Failed to restart game: $e");
      showCustomSnackbar("restart_failed".tr, false);
    }
  }

  Future<void> startNextGame() async {
    if (!isHost) {
      showCustomSnackbar("only_host_can_start".tr, false);
      return;
    }

    if (players.length < 2) {
      showCustomSnackbar("need_more_players".tr, false);
      return;
    }

    try {
      await onlineGameService.startGame(user!.uid);
      closeWaitingRoom();
    } catch (e) {
      debugPrint("Failed to start game: $e");
      showCustomSnackbar("start_game_failed".tr, false);
    }
  }


  Future<void> removePlayer(String userId) async{
    try{
      await onlineGameService.removePlayerFromGame("gameID here", userId);

    }catch(e){
      showCustomSnackbar("unexpected_result".tr, false);
    }
  }

  Future<void> startGame() async {
    await onlineGameService.startGame(user!.uid);
  }


  void showWaitingRoom() {
    if (dialogManager.isDialogShowingByRouteName(LudoWaitingRoomDialog.dialogId)) {
      debugPrint("Waiting room already showing");
      return;
    }

    dialogManager.showDialog(
      dialog: const LudoWaitingRoomDialog(),
      barrierDismissible: false,
      priority: DialogPriority.high,
      canBeInterrupted: false,
      timeout: const Duration(minutes: 10),
      routeSettings: const RouteSettings(
          name: LudoWaitingRoomDialog.dialogId,
      ),
    );
  }

  Future<void> closeWaitingRoom() async {
    dialogManager.closeDialogByRouteName(LudoWaitingRoomDialog.dialogId);
  }
  /*void showWaitingRoom() {
    if (Get.isDialogOpen == true) {
      debugPrint("A dialog is already open.");
    } else {
      Get.dialog(
        LudoWaitingRoomDialog(),
        barrierDismissible: false,
      );
    }
  }

  void closeWaitingRoom() {
    if (Get.isDialogOpen == true) {
      Get.back();
    } else {
      debugPrint("No dialog is currently open to close.");
    }
  */

  void deleteGame() {
    _gameStateSubscription?.cancel();
    onlineGameService.deleteGameWithPlayers(gameId.value);
  }



}