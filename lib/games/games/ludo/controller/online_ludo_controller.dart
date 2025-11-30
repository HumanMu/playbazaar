import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:playbazaar/config/routes/router_provider.dart';
import 'package:playbazaar/core/dialog/dialog_manager.dart';
import 'package:playbazaar/games/games/ludo/config/ludo_config.dart';
import 'package:playbazaar/games/games/ludo/helper/enum_converter.dart';
import 'package:playbazaar/games/games/ludo/models/ludo_creattion_params.dart';
import 'package:playbazaar/games/games/ludo/models/single_online_player.dart';
import 'package:playbazaar/games/games/ludo/services/online_ludo_service.dart';
import 'package:playbazaar/global_widgets/dialog/accept_dialog.dart';
import '../../../../constants/app_dialog_ids.dart';
import '../../../../global_widgets/show_custom_snackbar.dart';
import '../../../helper/enum.dart';
import '../helper/enums.dart';
import '../helper/functions.dart';
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
  final onlineLudoService = Get.find<OnlineLudoService>();
  TokenType myTokenType = TokenType.red;
  final RxBool isSelfLeave = false.obs;
  StreamSubscription<LudoOnlineModel?>? _gameStateSubscription;
  LudoOnlineModel? _currentGameState;
  LudoOnlineModel? _previousGameState;
  final Set<String> _pendingMoves = {}; // Current user move to prevet double moves


  @override
  onInit() {
    super.onInit();
    gameMode = GameMode.online;
  }

  @override
  Future<void> onBoardBuilt() async {}


  @override
  Future<void> initializePlayers() async {}

  @override
  Future<void> initializeServices(LudoCreationParamsModel params) async {}

  Future<void> createLudoGame(LudoCreationParamsModel params) async{
    gameMode = GameMode.online;
    String? gameRef = await onlineLudoService.createLudoGame(params);

    if(gameRef == null){
      showCustomSnackbar("unexpected_result".tr, false);
      return;
    }

    gameId.value = gameRef;
    await _listeningToGameState();
  }

  Future<void> joinExistingGame(String gameCode) async {
    String? gameRef = await onlineLudoService.joinExistingGame(gameCode);

    if(gameRef == null){
      showCustomSnackbar("unexpected_result".tr, false);
      return;
    }

    gameId.value = gameRef;
    await _listeningToGameState();
  }

  @override
  Future<void> onAwaitingTokenSelection(TokenType player, int diceValue) async {
    if (player != myTokenType) {
      return;
    }
  }

  @override
  Future<void> handleDiceRollResult(int diceValue, TokenType currentPlayerType) async {
    final availableToken = getMovableTokens(currentPlayerType, diceValue);
    if(diceValue != 6 && !availableToken) {
      final nextPlayer = getNextPlayerInSequence(myTokenType);
      await Future.delayed(const Duration(milliseconds: 500));
      await onlineLudoService.updateDiceValue(gameId.value, nextPlayer);
      diceController.setDiceRollState(false);
      return;
    }
    // Then handle normally
    await super.handleDiceRollResult(diceValue, currentPlayerType);
  }

  Future<void> _listeningToGameState() async {
    if (gameId.value.isEmpty) return;

    _gameStateSubscription = onlineLudoService.listenToGameStateChanges(gameId.value)
        .listen((gameState) async {
      if (gameState != null) {

        _currentGameState = gameState;
        await _updateChangedTokens(gameState, _previousGameState);
        final shouldSyncPlayers = players.length != gameState.players.length
            || players.isEmpty
            || _hasPlayerListChanged(gameState.players);

        if (shouldSyncPlayers) {
          if (_previousGameState != null
              && _previousGameState!.players.containsKey(user!.uid)
              && !gameState.players.containsKey(user!.uid)) {
            debugPrint("Current user has been removed from the game");
            await _updatePlayerRemoved();
            return;
          }
          _syncPlayersProfileWithFirestore(gameState.players, gameState.teamPlay);
          gameCode.value = gameState.gameCode;
          isHost.value = gameState.hostId == user?.uid;

          gameService.activeTokenTypes.clear();
          for (final player in players) {
            gameService.activeTokenTypes.add(player.tokenType);
            gameService.ensurePathInitialized(player.tokenType);
          }
        }

        _checkWinState(gameState.winnerOrder, gameState.gameState);
        _createLocalTokens(gameState.players);
        _updatePlayerProgress(gameState.players);
        _gameStateDialog(gameState.gameState);
        _handleTurnChange(gameState, _previousGameState);
        _previousGameState = gameState;
      }
      else{
        showCustomSnackbar("unexpected_result".tr, false);
      }
    },
      onError: (error) {
        debugPrint("Error listening to game state: $error");
        showCustomSnackbar("connection_error".tr, false);
      },
    );
  }

  Future<void> _updatePlayerRemoved() async{
    await _gameStateSubscription?.cancel();
    _gameStateSubscription = null;
    !isSelfLeave.value? await dialogManager.showDialog(
        dialog: AcceptDialogWidget(
            title: "removed_from_game_title".tr,
            message: "removed_from_game_description".tr,
            onOk: () {
              dialogManager.closeAllDialogs();
              rootNavigatorKey.currentContext?.push("/ludoHome");
            },
        ),
      priority: DialogPriority.critical,
    ) : null;
  }

  void _checkWinState(List<String>? winnersOrder, GameProgress gameState) {
    if(winnersOrder == null) return;

    if(winnersOrder.length >= (players.length-1)) {
      gameState != GameProgress.waiting ? showGameOverDialog() : null;
    }
  }

  void _handleTurnChange(LudoOnlineModel newState, LudoOnlineModel? previousState) {

    final currentPlayer = players.firstWhereOrNull(
            (p) => p.playerId == newState.currentPlayerTurn
    );

    if (currentPlayer != null) {
      diceController.setColor(currentPlayer.tokenType);

      if (newState.currentPlayerTurn == user?.uid) {
        diceController.setMoveState(false);
        diceController.setDiceRollState(true);
      } else {
        debugPrint("It's ${currentPlayer.name}'s turn");
        diceController.setDiceRollState(false);
        diceController.setMoveState(false);
      }

      diceController.update();
    }
  }

  bool _hasPlayerListChanged(Map<String, SingleOnlinePlayer> firestorePlayers) {
    if (players.length != firestorePlayers.length) return true;
    final currentPlayerIds = players.map((p) => p.playerId).toSet();
    final newPlayerIds = firestorePlayers.keys.toSet();

    return !currentPlayerIds.containsAll(newPlayerIds) ||
        !newPlayerIds.containsAll(currentPlayerIds);
  }

  void _updatePlayerProgress(Map<String, SingleOnlinePlayer> firestorePlayers){
    for (final entry in firestorePlayers.entries) {
      final firestorePlayer = entry.value;

      final playerIndex = players.indexWhere((p) => p.playerId == firestorePlayer.playerId);
      if (playerIndex != -1) {
        players[playerIndex] = players[playerIndex].copyWith(
          numberOfreachedHome: firestorePlayer.finishedTokensLength,
          hasFinished: firestorePlayer.finishedTokensLength == 4 ? true : false,
        );
      }
    }
  }

  void _createLocalTokens(Map<String, SingleOnlinePlayer> firestorePlayers) {
    final localTokenTypeMap = _mapPlayersToLocalTokenTypes(firestorePlayers);

    final sortedPlayers = firestorePlayers.values.toList()
      ..sort((a, b) {
        final indexA = GameConfig.colorSequences.indexOf(a.color);
        final indexB = GameConfig.colorSequences.indexOf(b.color);

        if (indexA == -1 || indexB == -1) {
          return a.playerId.compareTo(b.playerId);
        }

        return indexA.compareTo(indexB);
      });

    // ✅ Create mapping from player to their actual Firestore index
    Map<String, int> playerToFirestoreIndex = {};
    for (int i = 0; i < sortedPlayers.length; i++) {
      final colorIndex = GameConfig.colorSequences.indexOf(sortedPlayers[i].color);
      playerToFirestoreIndex[sortedPlayers[i].playerId] = colorIndex;
    }

    // Create reverse mapping for service
    Map<TokenType, int> playerIndexMap = {};
    for (int i = 0; i < sortedPlayers.length; i++) {
      final tokenType = localTokenTypeMap[sortedPlayers[i].playerId];
      if (tokenType != null) {
        final firestoreIndex = playerToFirestoreIndex[sortedPlayers[i].playerId]!;
        playerIndexMap[tokenType] = firestoreIndex;
      }
    }

    onlineLudoService.setPlayerIndexMap(playerIndexMap);

    // Get tokens from game state
    final tokensMap = _currentGameState?.tokens ?? {};

    for (int i = 0; i < sortedPlayers.length; i++) {
      final firestorePlayer = sortedPlayers[i];
      final localTokenType = localTokenTypeMap[firestorePlayer.playerId]!;

      // ✅ Use actual Firestore player index (based on color)
      final firestorePlayerIndex = playerToFirestoreIndex[firestorePlayer.playerId]!;

      for (int tokenIndex = 0; tokenIndex < 4; tokenIndex++) {
        final globalTokenId = (firestorePlayerIndex * 4) + tokenIndex;

        // ✅ Use Firestore index for token key
        final tokenKey = 'p${firestorePlayerIndex}_t$tokenIndex';
        final firestorePosition = tokensMap[tokenKey] ?? -1;

        final existingToken = gameTokens[globalTokenId];
        if (existingToken != null) {
          final existingFirestorePos = _getFirestorePosition(existingToken);

          if (existingFirestorePos == firestorePosition) {
            continue;
          }
        }

        Position localPosition;
        TokenState tokenState;
        int positionInPath;

        if (firestorePosition == -1) {
          final basePosition = gameService.getTokenHomePosition(localTokenType);
          localPosition = Position(
            basePosition.column + (tokenIndex % 2),
            basePosition.row + (tokenIndex ~/ 2),
          );
          tokenState = TokenState.initial;
          positionInPath = 0;
        } else if (firestorePosition == 57) {
          localPosition = gameService.getPosition(localTokenType, 56);
          tokenState = TokenState.home;
          positionInPath = 56;
        } else {
          positionInPath = firestorePosition;
          localPosition = gameService.getPosition(localTokenType, positionInPath);
          tokenState = TokenState.normal;
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

// Helper to convert token state to Firestore position
  int _getFirestorePosition(Token token) {
    if (token.tokenState == TokenState.initial) {
      return -1;
    } else if (token.tokenState == TokenState.home) {
      return 57;
    } else {
      return token.positionInPath;
    }
  }

  Map<String, TokenType> _mapPlayersToLocalTokenTypes(Map<String, SingleOnlinePlayer> firestorePlayers) {
    final Map<String, TokenType> mapping = {};

    for (final entry in firestorePlayers.entries) {
      final player = entry.value;
      final TokenType tokenType = string2TokenType(player.color);
      mapping[player.playerId] = tokenType;

      // Store your own token type
      if (player.playerId == user?.uid) {
        myTokenType = tokenType;
      }
    }

    return mapping;
  }

  void _syncPlayersProfileWithFirestore(Map<String, SingleOnlinePlayer> firePlayers, bool teamPlay) {
    final previousPlayerIds = players.map((p) => p.playerId).toSet();

    players.clear();

    final sortedPlayers = firePlayers.values.toList()
      ..sort((a, b) {
        final indexA = GameConfig.colorSequences.indexOf(a.color);
        final indexB = GameConfig.colorSequences.indexOf(b.color);

        // Fallback to playerId comparison if colors are somehow invalid
        if (indexA == -1 || indexB == -1) {
          return a.playerId.compareTo(b.playerId);
        }

        return indexA.compareTo(indexB);
      });

    // Map each Firestore player to a LudoPlayer
    final localTokenTypeMap = _mapPlayersToLocalTokenTypes(firePlayers);

    for (final firestorePlayer in sortedPlayers) {
      final localTokenType = localTokenTypeMap[firestorePlayer.playerId];

      if (localTokenType == null) {
        debugPrint("WARNING: No token type found for player ${firestorePlayer.playerId}");
        continue;
      }

      players.add(LudoPlayer(
        playerId: firestorePlayer.playerId,
        name: firestorePlayer.name,
        tokenType: localTokenType,
        numberOfreachedHome: firestorePlayer.finishedTokensLength,
        hasFinished: firestorePlayer.finishedTokensLength == 4 ? true : false,
        isRobot: false,
        teamId: firestorePlayer.teamId,
        isConnected: firestorePlayer.isConnected,
      ));

      if (firestorePlayer.playerId == user?.uid) {
        myTokenType = localTokenType;
      }
    }

    // If the host has removed anyone from the game..
    final currentPlayerIds = players.map((p) => p.playerId).toSet();
    final removedPlayerIds = previousPlayerIds.difference(currentPlayerIds);

    if (removedPlayerIds.isNotEmpty) {
      _clearTokensForRemovedPlayers(removedPlayerIds, localTokenTypeMap);
    }

    syncTeamAssignments(teamPlay);
  }

  void _clearTokensForRemovedPlayers(Set<String?> removedPlayerIds, Map<String, TokenType> localTokenTypeMap) {
    for (final playerId in removedPlayerIds) {
      if (playerId == null) continue;

      // Find the token type this player had
      // Since they're removed from the map, we need to find their tokens by checking existing tokens
      for (int i = 0; i < gameTokens.length; i++) {
        final token = gameTokens[i];
        if (token != null) {

          // Check if this token belongs to a removed player
          final tokenTypeStillActive = players.any((p) => p.tokenType == token.type);
          if (!tokenTypeStillActive) {
            gameTokens[i] = null;
          }
        }
      }
    }

    gameService.gameTokens.refresh();
  }

  // Update game state when players change
  void _updatePlayerStates() {
    numberOfHumanPlayers.value = players.length;
    canStart.value = players.length >= 2 && players.length <= 4;

    if (players.isNotEmpty && boardBuild.value) {
      players.refresh();
    }
  }

  @override
  Future<void> handleTokenTap(Token token) async {
    try {
      bool basicCheck = basicTokenTapCheck(token);
      if (!basicCheck || token.type != myTokenType) return;

      final playerIndex = getPlayerIndexFromTokenType(token.type);
      final tokenIndex = token.id % 4;
      final tokenKey = 'p${playerIndex}_t$tokenIndex';

      // Track pending move to avoid duplicate animations
      _pendingMoves.add(tokenKey);

      // Calculate move result BEFORE animation
      final newPositionInPath = token.positionInPath + diceController.diceValue;
      final destination = gameService.getPosition(token.type, newPositionInPath);
      final moveResult = gameService.calculateMoveResult(token, destination);


      await gameService.animateTokenMovement(token, diceController.diceValue);
      bool hasReached = newPositionInPath == 56;
      bool isLastToken = false;

      if (hasReached) {
        await updateReachedHome(token);
        isLastToken = players[playerIndex].numberOfreachedHome >= 4;
      }

      bool hasExtraTurn = (hasReached && !isLastToken)
          || (moveResult.tokenToReset != null && !moveResult.isSelfKill)
          || (diceController.diceValue == 6 && diceController.dice.rxConsecutiveSixes < 3);

      String nextPlayer = hasExtraTurn ? user!.uid : getNextPlayerInSequence(myTokenType);

      await onlineLudoService.syncMoveToFirestore(
        token: token,
        diceValue: diceController.diceValue,
        gameId: gameId.value,
        killedToken: moveResult.tokenToReset,
        nextPlayerTurn: nextPlayer,
        hasReached: hasReached,
        isLastReachedToken: isLastToken,
      );

      if (hasExtraTurn && nextPlayer == user!.uid) {
        await Future.delayed(const Duration(milliseconds: 300));
        diceController.setDiceRollState(true);
      }

      _pendingMoves.remove(tokenKey);

    } catch (e) {
      diceController.setDiceRollState(true);
      diceController.setMoveState(false);
    }
  }

  // helper method to get player index from token type
  int getPlayerIndexFromTokenType(TokenType tokenType) {
    for (int i = 0; i < players.length; i++) {
      if (players[i].tokenType == tokenType) {
        return i;
      }
    }
    return 0;
  }

  String getNextPlayerInSequence(TokenType currentTokenType) {

    final turnOrder = [TokenType.red, TokenType.green, TokenType.yellow, TokenType.blue];
    int currentTurnIndex = turnOrder.indexOf(currentTokenType);

    if (currentTurnIndex == -1) {
      // Fallback to first active player
      return players.firstOrNull?.playerId ?? '';
    }

    // Find next active player in turn order
    for (int i = 1; i <= turnOrder.length; i++) {
      int nextTurnIndex = (currentTurnIndex + i) % turnOrder.length;
      TokenType nextType = turnOrder[nextTurnIndex];

      // Check if this token type is active and not finished
      final nextPlayer = players.firstWhereOrNull(
              (p) => p.tokenType == nextType && p.numberOfreachedHome < 4
      );

      if (nextPlayer != null) {
        return nextPlayer.playerId!;
      }
    }

    // Failsafe: return current player (game should end anyway)
    final currentPlayer = players.firstWhereOrNull((p) => p.tokenType == currentTokenType);
    return currentPlayer?.playerId ?? '';
  }


  @override
  Future<void> moveToken(Token token, dynamic controller) async {
    return;
  }

  Future<void> _updateChangedTokens(LudoOnlineModel newState, LudoOnlineModel? prevState) async {
    final localTokenTypeMap = _mapPlayersToLocalTokenTypes(newState.players);

    final sortedPlayers = newState.players.values.toList()
      ..sort((a, b) {
        final indexA = GameConfig.colorSequences.indexOf(a.color);
        final indexB = GameConfig.colorSequences.indexOf(b.color);

        if (indexA == -1 || indexB == -1) {
          return a.playerId.compareTo(b.playerId);
        }

        return indexA.compareTo(indexB);
      });

    // ✅ Create mapping from player to their actual Firestore index
    Map<String, int> playerToFirestoreIndex = {};
    for (int i = 0; i < sortedPlayers.length; i++) {
      final colorIndex = GameConfig.colorSequences.indexOf(sortedPlayers[i].color);
      playerToFirestoreIndex[sortedPlayers[i].playerId] = colorIndex;
    }

    // Set player index map
    Map<TokenType, int> playerIndexMap = {};
    for (int i = 0; i < sortedPlayers.length; i++) {
      final tokenType = localTokenTypeMap[sortedPlayers[i].playerId];
      if (tokenType != null) {
        final firestoreIndex = playerToFirestoreIndex[sortedPlayers[i].playerId]!;
        playerIndexMap[tokenType] = firestoreIndex;
      }
    }
    onlineLudoService.setPlayerIndexMap(playerIndexMap);

    final newTokensMap = newState.tokens ?? {};
    final oldTokensMap = prevState?.tokens ?? {};

    bool hasChanges = false;
    List<Future<void>> animations = [];

    for (final tokenKey in newTokensMap.keys) {
      final newPosition = newTokensMap[tokenKey];
      final oldPosition = oldTokensMap[tokenKey];

      if (newPosition == oldPosition) continue;

      hasChanges = true;

      final parts = tokenKey.split('_');
      final firestorePlayerIndex = int.parse(parts[0].substring(1));
      final tokenIndex = int.parse(parts[1].substring(1));

      final globalTokenId = (firestorePlayerIndex * 4) + tokenIndex;

      // ✅ Find player by Firestore index (color)
      final firestorePlayer = sortedPlayers.firstWhereOrNull(
              (p) => GameConfig.colorSequences.indexOf(p.color) == firestorePlayerIndex
      );

      if (firestorePlayer == null) continue;

      final localTokenType = localTokenTypeMap[firestorePlayer.playerId]!;

      final existingToken = gameTokens[globalTokenId];
      final isPendingMove = _pendingMoves.contains(tokenKey);

      final shouldAnimate = !isPendingMove &&
          existingToken != null &&
          oldPosition != null &&
          oldPosition != -1 &&
          newPosition != -1 &&
          newPosition != oldPosition;

      if (shouldAnimate) {
        final steps = newPosition! - oldPosition;
        animations.add(gameService.animateTokenMovement(existingToken, steps));
      } else {
        _updateTokenDirectly(
            globalTokenId,
            localTokenType,
            newPosition!,
            tokenIndex
        );
      }

      if (isPendingMove) _pendingMoves.remove(tokenKey);
    }

    if (animations.isNotEmpty) await Future.wait(animations);
    if (hasChanges) gameService.gameTokens.refresh();

    _updatePlayerStates();
  }

  void _updateTokenDirectly(int globalTokenId, TokenType localTokenType, int firePos, int tIndex ) {

    Position localPosition;
    TokenState tokenState;
    int positionInPath;

    if (firePos == -1) {
      final basePosition = gameService.getTokenHomePosition(localTokenType);
      localPosition = Position(
        basePosition.column + (tIndex % 2),
        basePosition.row + (tIndex ~/ 2),
      );
      tokenState = TokenState.initial;
      positionInPath = 0;
    } else if (firePos == 57) {
      localPosition = gameService.getPosition(localTokenType, 56);
      tokenState = TokenState.home;
      positionInPath = 56;
    } else {
      positionInPath = firePos;
      localPosition = gameService.getPosition(localTokenType, positionInPath);
      tokenState = TokenState.normal;
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

  @override
  void restartGame() async {
    isLoading.value = true;
    boardBuild.value = false;
    wasLastToken.value = false;

    LudoHelper.clearKeyCache();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      boardBuild.value = true;
      isLoading.value = false;
    });
  }

  Future<void> startGame() async {
    if (!isHost.value) {
      showCustomSnackbar("only_host_can_start".tr, false);
      return;
    }

    if (players.length < 2) {
      showCustomSnackbar("need_more_players".tr, false);
      return;
    }

    try {
      await onlineLudoService.startGame(gameId.value);
      await closeWaitingRoom();
      diceController.setDiceRollState(true);
      diceController.setMoveState(false);
    } catch (e) {
      debugPrint("Failed to start game: $e");
      showCustomSnackbar("start_game_failed".tr, false);
    }
  }

  Future<void> removePlayer(String userId) async{
    try{
      await onlineLudoService.removePlayerFromGame(gameId.value, userId);
      if(userId == user!.uid) _gameStateSubscription?.cancel();

    }catch(e){
      showCustomSnackbar("unexpected_result".tr, false);
    }
  }

  Future<void> leaveGame() async{
    try{
      isSelfLeave.value = true;
      await _gameStateSubscription?.cancel();
      _gameStateSubscription = null;
      await onlineLudoService.leaveGame(gameId.value);
      dialogManager.closeAllDialogs();
      showCustomSnackbar("leaving_game_succeeded".tr, false);
    }catch(e){
      showCustomSnackbar("unexpected_result".tr, false);
    }
  }

  Future<void> _gameStateDialog(GameProgress gameStatus) async {
    switch (gameStatus) {
      case GameProgress.waiting:
        showWaitingRoom();
        break;

      case GameProgress.inProgress:
        await closeWaitingRoom();
        break;

      case GameProgress.finished:
        showGameOverDialog();
        break;

      default:
        debugPrint("Unknown game status: $gameStatus");
    }
  }

  void showWaitingRoom({bool isManaging = false}) {
    if (dialogManager.isDialogShowingByRouteName(AppDialogIds.ludoWaitingRoom)) {
      debugPrint("Waiting room already showing");
      return;
    }

    dialogManager.showDialog(
      dialog: LudoWaitingRoomDialog(isManaging: isManaging),
      barrierDismissible: false,
      priority: DialogPriority.high,
      canBeInterrupted: false,
      timeout: const Duration(minutes: 10),
      routeSettings: RouteSettings(
        name: AppDialogIds.ludoWaitingRoom,
      ),
    );
  }

  Future<void> closeWaitingRoom() async {
    if (dialogManager.isDialogShowingByRouteName(AppDialogIds.ludoWaitingRoom)) {
      dialogManager.closeDialogByRouteName(AppDialogIds.ludoWaitingRoom);
    }
  }
}