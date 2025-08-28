import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:playbazaar/games/games/ludo/services/online_ludo_service.dart';
import '../../../../global_widgets/show_custom_snackbar.dart';
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

  StreamSubscription<List<LudoPlayer>>?  _playersSubscription;
  StreamSubscription<LudoOnlineModel?>? _gameStateSubscription;

  @override
  Future<void> onBoardBuilt() async {
    await initializeOnlineGameState();
  }

  Future<void> initializeOnlineGameState() async {}

  @override
  Future<void> initializePlayers() async {}

  Future<void> initializeOnlinePlayer(List<LudoPlayer> joinedPlayers) async {
    for(var tokenType in joinedPlayers){
      debugPrint("Recieved player: ${tokenType.tokenType}");
      players.add(
        LudoPlayer(
          tokenType: tokenType.tokenType,
          name: tokenType.name,
          isRobot: false
        ),
      );
    }

    await onlineGameService.initializeLocalTokens(players.length);

    update();

  }


  @override
  Future<void> initializeServices() async {
    if (Get.arguments != null) {
      isRobotOn.value = Get.arguments['enabledRobots'] ?? false;
      isTeamPlay.value = Get.arguments['teamPlay'] ?? false;
      isHost = Get.arguments['isHost']?? false;
      gameCode.value = Get.arguments['gameCode']??"";
    }
  }

  Future<void> createLudoGame({
    required bool teamPlay,
    bool enableRobots = false,
    required String gameCode
  }) async{
    String? gameRef = await onlineGameService.createLudoGame(
      teamPlay: teamPlay,
      enableRobots: enableRobots,
      gameCode: gameCode,
    );

    if(gameRef == null){
      showCustomSnackbar("unexpected_result".tr, false);
      return;
    }

    gameId.value = gameRef;
    await  _listeningToGameState();
    await _listeningToPlayers();
  }

  Future<void> joinExistingGame(String gameCode) async {
    String? gameRef = await onlineGameService.joinExistingGame(gameCode);

    if(gameRef == null){
      showCustomSnackbar("unexpected_result".tr, false);
      return;
    }


    //showWaitingRoom();
    gameId.value = gameRef;
    await _listeningToGameState();
    await _listeningToPlayers();
  }

  Future<void> _listeningToGameState() async {
    if (gameId.value.isEmpty) {
      debugPrint("Game ID is empty, cannot start listening to players");
      return;
    }

    _gameStateSubscription = onlineGameService.listenToGameStateChanges(gameId.value)
        .listen((gameState) {
        if (gameState != null) {
          _createLocalTokensFromFirestore(gameState.gameTokens);
          //_updateGameState(gameState);
        }
      },
      onError: (error) {
        debugPrint("Error listening to players: $error");
        showCustomSnackbar("connection_error".tr, false);
      },
    );
  }


  Future<void> _listeningToPlayers() async {
    if (gameId.value.isEmpty) {
      debugPrint("Game ID is empty, cannot start listening to players");
      return;
    }

    _playersSubscription = onlineGameService.listenToPlayersChanges(gameId.value).listen(
          (playersData) {
        if (playersData.isNotEmpty) {
          //players.assignAll(playersData);
          initializeOnlinePlayer(playersData);
          _updatePlayerStates();
        }
      },
      onError: (error) {
        debugPrint("Error listening to players: $error");
        showCustomSnackbar("connection_error".tr, false);
      },
    );
  }


  // Update game state when players change
  void _updatePlayerStates() {
    numberOfHumanPlayers.value = players.length;
    canStart.value = players.length >= 2 && players.length <= 4;

    if (players.isNotEmpty && boardBuild.value) {

    }
  }

  // Add this method to OnlineLudoController
  List<Token> _createLocalTokensFromFirestore(List<dynamic> firestoreTokens) {
    List<Token> localTokens = [];

    for (int i = 0; i < firestoreTokens.length; i++) {
      if (firestoreTokens[i] != null) {
        final tokenData = firestoreTokens[i] as Map<String, dynamic>;

        // Determine which player owns this token (based on token ID ranges)
        final tokenId = tokenData['id'] as int;
        final playerIndex = tokenId ~/ 4; // 0-3 tokens = player 0, 4-7 = player 1, etc.

        // Get the display color for this player index
        final displayTokenType = _getDisplayColorForPlayerIndex(playerIndex);

        // Get local position based on display color
        final basePosition = gameService.getTokenHomePosition(displayTokenType);
        final tokenIndexWithinPlayer = tokenId % 4;
        final localPosition = Position(
          basePosition.row + (tokenIndexWithinPlayer ~/ 2),
          basePosition.column + (tokenIndexWithinPlayer % 2),
        );

        final tokenState = TokenState.values.firstWhere(
              (e) => e.toString().split('.').last == tokenData['state'],
        );

        final token = Token(
          displayTokenType,
          localPosition,
          tokenState,
          tokenId,
          positionInPath: tokenData['positionInPath'] as int,
        );

        localTokens.add(token);
      }
    }

    return localTokens;
  }

  // Add this helper method
  TokenType _getDisplayColorForPlayerIndex(int playerIndex) {
    // Find which player index corresponds to current player
    final myPlayerIndex = players.indexWhere((p) => p.playerId == FirebaseAuth.instance.currentUser?.uid);

    if (playerIndex == myPlayerIndex) {
      return myTokenType; // Always use chosen color for self
    }

    // Map other players to remaining colors
    final availableColors = [TokenType.red, TokenType.green, TokenType.yellow, TokenType.blue];
    availableColors.remove(myTokenType);

    // Calculate display index for other players
    final otherPlayerIndex = playerIndex > myPlayerIndex ? playerIndex - 1 : playerIndex;
    return availableColors[otherPlayerIndex % availableColors.length];
  }

  /*void _updateGameState(LudoOnlineModel gameState) {
    switch (gameState.gameStatus) {
      case GameProgress.waitning:
        if (gameState.gameTokens.isNotEmpty) {

          _updateTokensFromFirestore(gameState.gameTokens);
          //List<String> activeTypeStrings = List<String>.from(gameState.activeTokenTypes);
          Set<TokenType> activeTypes = {};

          for (String typeStr in activeTypeStrings) {
            try {
              activeTypes.add(string2TokenType(typeStr));
              debugPrint("Active type token: $typeStr");
            } catch (e) {
              debugPrint("Error parsing token type: $typeStr");
            }
          }
          gameService.activeTokenTypes.clear();
          gameService.activeTokenTypes.addAll(activeTypes);
        }
        break;
      case GameProgress.inProgress:
        _updateTokensFromFirestore(gameState.gameTokens);
        break;
      case GameProgress.finished:
        break;
      case GameProgress.cancelled:
        break;
    }
  }

  void _updateTokensFromFirestore(List<dynamic> firestoreTokens) {
    gameService.gameTokens.clear();

    final localTokens = _createLocalTokensFromFirestore(firestoreTokens);

    // Create array with correct indices
    List<Token?> updatedTokens = List<Token?>.filled(16, null);
    for (final token in localTokens) {
      updatedTokens[token.id] = token;
    }

    gameService.gameTokens.addAll(updatedTokens);
    update();
  }*/


  /*void _updateTokensFromFirestore(List<dynamic> firestoreTokens) {
    gameService.gameTokens.clear();
    List<Token?> updatedTokens = List<Token?>.filled(16, null);

    for (int i = 0; i < firestoreTokens.length && i < 16; i++) {
      if (firestoreTokens[i] != null) {
        final tokenData = firestoreTokens[i] as Map<String, dynamic>;

        try {
          final positionData = tokenData['position'] as Map<String, dynamic>;
          final position = Position(
            positionData['row'] as int,
            positionData['column'] as int,
          );

          final token = Token(
            string2TokenType(tokenData['type']),
            position,
            string2TokenState(tokenData['state']),
            tokenData['id'] as int,
            positionInPath: tokenData['positionInPath'] as int,
          );

          updatedTokens[i] = token;

        } catch (e) {
          debugPrint("Error parsing token at index $i: $e");
        }
      }
    }

    // Add all tokens to the service
    gameService.gameTokens.addAll(updatedTokens);

    // Update active token types
    Set<TokenType> activeTypes = {};
    for (var token in updatedTokens) {
      if (token != null) {
        activeTypes.add(token.type);
      }
    }
    gameService.activeTokenTypes.clear();
    gameService.activeTokenTypes.addAll(activeTypes);

    update();
  }*/


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
      Get.back();
    } else {
      debugPrint("No dialog is currently open to close.");
    }
  }

  void deleteGame() {
    _playersSubscription?.cancel();
    _gameStateSubscription?.cancel();
    onlineGameService.deleteGameWithPlayers(gameId.value);
  }




}