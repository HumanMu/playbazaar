import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/constants/alphabets.dart';
import 'package:playbazaar/controller/user_controller/auth_controller.dart';
import 'package:playbazaar/games/games/hangman/models/game_participiant.dart';
import 'package:playbazaar/games/games/hangman/models/game_state_change_model.dart';
import 'package:playbazaar/games/services/hangman_services.dart';
import 'package:playbazaar/global_widgets/show_custom_snackbar.dart';
import 'package:playbazaar/global_widgets/string_return_dialog.dart';
import '../../../../functions/generate_strings.dart';
import '../../../../screens/widgets/dialogs/accept_result_dialog.dart';
import '../../../functions/get_hangman_difficulty.dart';
import '../models/online_competition_doc_model.dart';
import '../widgets/waiting_screen.dart';


class PlayController extends GetxController {
  // static
  HangmanService hangmanService = Get.put(HangmanService());
  final authController = Get.find<AuthController>();
  final RxList<String> difficultyNiveaus = <String>[].obs;
  final RxList<String> difficultyLabels = <String>[].obs;
  final RxList<String> localPlayers = <String>[].obs;
  final user = FirebaseAuth.instance.currentUser;
  RxList<String> alphabet = <String>[].obs;
  final RxBool isOfflineMode = false.obs;
  final RxBool isJoiningMode = false.obs;
  final RxBool isOnlineMode = false.obs;
  final RxString gameCode = ''.obs;
  RxBool isAlphabetRTL = false.obs;
  final int maxIncorrectGuesses = 6;
  RxString  language = "".obs;
  Rx<String> dbpath = "".obs;

  //dynamic
  RxList<String> guessedLetters = <String>[].obs;
  final List<String> words = [];
  RxInt incorrectGuesses = 0.obs;
  RxString wordToGuess = ''.obs;
  RxBool gameLost = false.obs;
  RxBool gameWon = false.obs;
  RxInt currentIndex = 0.obs;
  RxString wordHint = ''.obs;
  RxInt playerTurn = 0.obs;

  // online playing
  RxList<GameParticipantModel> participants = <GameParticipantModel>[].obs;
  StreamSubscription<OnlineCompetitionDocModel?>? _gameSubscription;
  final RxString currentGameId = ''.obs;
  final RxBool gameState = true.obs;
  final RxBool isHost = false.obs;


  @override
  void onInit() async {
    super.onInit();
    await getAppLanguage();
    await getDifficultyAndPath();
    _initializeAlphabet();
    ever(authController.language, (_) {
      _initializeAlphabet();
    });
  }

  @override
  void onClose() {
    _gameSubscription?.cancel();
    super.onClose();
  }


  String buildHiddenWord() {
    String hiddenWord = '';
    String normalizedWord = normalizeAlphabet(wordToGuess.value);

    for (int i = 0; i < normalizedWord.length; i++) {
      if (guessedLetters.contains(normalizedWord[i])) {
        hiddenWord += '${normalizedWord[i]} ';
      } else {
        hiddenWord += '_ ';
      }
    }
    return hiddenWord.trim();
  }


  Future<void> checkGuess(String letter) async{
    if (!guessedLetters.contains(letter)) {
      guessedLetters.add(letter);
      String normalizedWord = normalizeAlphabet(wordToGuess.value);

      if(!normalizedWord.contains(letter)) incorrectGuesses.value++;
      if(!buildHiddenWord().contains('_')) {
        gameWon.value = true;
        await handleOnlineGameWin(participants);
      }
      if (incorrectGuesses.value >= maxIncorrectGuesses) gameLost.value = true;
    }
  }

  void prepareNewGame() {
    if(words.isEmpty) return;
    wordToGuess.value = normalizeAlphabet(words[currentIndex.value]);
    guessedLetters.clear();
    incorrectGuesses.value = 0;
    gameLost.value = false;
    gameWon.value = false;
  }


  Future<void> _loadWordsFromFirestore() async {
    try {
      final random = Random();
      final retrievedWords = await hangmanService.getRandomHangmanWords(
          collectionId: dbpath.value
      );

      if (retrievedWords == null || retrievedWords.words.isEmpty) {
        showCustomSnackbar("restart_app_fail".tr, false);
        return;
      }
      words.clear();
      currentIndex.value = 0;
      retrievedWords.words.shuffle(random);
      words.addAll(retrievedWords.words.map((word) => word.trim().toUpperCase()));
      wordHint.value = retrievedWords.hint;
      wordToGuess.value = normalizeAlphabet(words[currentIndex.value]);
    } catch (e) {
      showCustomSnackbar("Failed to load words", false);
    }
  }


  Future<void> startNextOnlineGame(BuildContext context) async {
    if (currentGameId.isEmpty) return;

    try {
      currentIndex.value++;
      if (words.isEmpty || currentIndex.value >= words.length) {
        await _loadWordsFromFirestore();
      } else {
        prepareNewGame();
      }

      if (words.isEmpty || wordToGuess.value.trim() =="") {
        showCustomSnackbar("unexpected_result".tr, false);
        return;
      }

      // Create game state model
      final GameStateChangeModel newGameData = GameStateChangeModel(
          gameId: currentGameId.value,
          wordHint: wordHint.value,
          word: wordToGuess.value,
      );

      final success = await hangmanService.handleNextGameStart(newGameData);
      if (!success) {
        showCustomSnackbar("unexpected_result".tr, false);
        return;
      }

      resetGameStates();
    } catch (e) {
      showCustomSnackbar("unexpected_result".tr, false);
    }
  }

  Future<void> leaveOnlineCompetition() async{
    try{
      _gameSubscription?.cancel();
      closeWaitingRoom();
      if(isHost.value){
        final success = await hangmanService.destroyGame(currentGameId.value);
        if(success){
          showCustomSnackbar("msg_game_destruction_succed".tr, true);
        }
      }
    }catch(e){
      showCustomSnackbar("unexpected_result".tr, false);
    }finally{
      closeWaitingRoom();
    }
  }


  void _subscribeToGame(String inviteCode) {
    _gameSubscription?.cancel();
    _gameSubscription = hangmanService.streamGameByInviteCode(inviteCode)
        .listen((gameData) {
      if (gameData == null) {
        showCustomSnackbar("msg_game_not_found".tr, false);
        Get.back();
        return;
      }

      if(gameData.hostId == user!.uid) isHost.value = true;
      currentGameId.value = gameData.gameId;
      gameState.value = gameData.gameState == "waiting";
      participants.value = gameData.participants;

      if (gameData.gameState == "playing") {
        if (Get.currentRoute != '/hangman') {
          Get.offNamed('/hangman');
        }
        wordToGuess.value = gameData.wordToGuess;
        wordHint.value = gameData.wordHint??"";
        gameWon.value = false;
        gameLost.value = false;
        closeWaitingRoom();
      }
      if(gameData.gameState == "waiting"){
        guessedLetters.clear();
        showWaitingRoom();
      }
    });
  }

  void showWaitingRoom() { // Dont touch this or dialog will got problem
    if (Get.isDialogOpen == true) {
      debugPrint("A dialog is already open.");
    } else {
      Get.dialog(
        WaitingRoomDialog(),
        barrierDismissible: false,
      );
    }
  }

  void closeWaitingRoom() { // Dont touch this or dialog will got problem
    if (Get.isDialogOpen == true) {
      Get.back();
    } else {
      debugPrint("No dialog is currently open to close.");
    }
  }


  Future<void> startTeamPlayGame(BuildContext context) async {
    if (isOfflineMode.value) {
      if(localPlayers.length < 2){
        showCustomSnackbar("zero_player_error".tr, false);
        return;
      }
      wordHint.value = "";
      await getPlayerGuess(context);
      prepareNewGame();
      closeWaitingRoom();
      Get.toNamed('/hangman');
    }

    if(isOnlineMode.value){
      await _loadWordsFromFirestore();
      prepareNewGame();
      bool success = await hangmanService.createJoinableHangmanGame(
          gameCode.value,
          wordToGuess.value,
          wordHint.value
      );

      if(success) {
        _subscribeToGame(gameCode.value);
      }
    }
  }


  Future<void> handleOnlineGameWin(List<GameParticipantModel> participants) async {
    final numberOfWins = participants
        .firstWhere((p) => p.uid == user!.uid)
        .numberOfWin;

    gameLost.value = false;
    gameWon.value = true;
    if (currentGameId.value.isNotEmpty) {
      final success = await hangmanService.handleGameWin(
          currentGameId.value,
          numberOfWins,
          participants
      );

      if (!success) {
        showCustomSnackbar('msg_game_creator_deleted'.tr, false);
      }
    }
  }

  Future<void> startNextGame(BuildContext context) async {
    if(isOnlineMode.value) return;

    if(isOfflineMode.value) {
      await getPlayerGuess(context);
      prepareNewGame();
      return;
    }
    if(currentIndex.value == words.length -1){
      await _loadWordsFromFirestore();
      showCustomSnackbar("game_hint_has_changed".tr, false);
    }
    currentIndex.value++;
    prepareNewGame();
  }

  Future<void> startSoloGamePlay() async {
    _gameSubscription?.cancel();
    if(isOfflineMode.value || isOnlineMode.value){
      return acceptResultDialog( Get.context,
          "deactive_other_options".tr,
          "deactive_play_with_friends".tr
      );
    }
    else{
      await _loadWordsFromFirestore();
      prepareNewGame();
      Get.toNamed('/hangman');
    }
  }

  Future<void> joinGameWithCode(String code) async {
    final uppercasedCode = code.toUpperCase();
    final success = await hangmanService.joinGame(uppercasedCode);
    if (success) {
      gameCode.value = uppercasedCode;
      _subscribeToGame(uppercasedCode);
    } else {
      showCustomSnackbar("Failed to join game", false);
      return;
    }
  }

  Future<void> getPlayerGuess(BuildContext context) async {
    String? playerGuess = await showDialog<String>(
      context: context,
      builder: (context) => StringReturnDialog(
        title: "${"player_turn".tr} ${localPlayers[playerTurn.value]}",
        hintText: "write_here".tr,
        description: "guess_a_word_description".tr,
      ),
    );

    if (playerGuess != "" && playerGuess != null) {
      words.clear();
      words.add(playerGuess);
      wordToGuess.value = words[0];
      playerTurn.value++;
      if(playerTurn.value >= localPlayers.length) playerTurn.value = 0;

    } else {
      wordToGuess.value = "";
      words.clear();
    }
  }

  // Static functions
  Future<void> getAppLanguage() async{
    if(authController.language[0] == "fa" || authController.language[0]=="ar"){
      isAlphabetRTL.value = true;
    }else{
      isAlphabetRTL.value = false;
    }
  }

  Future<void> getDifficultyAndPath() async {
    final result = await getHangmanDifficulty();
    difficultyNiveaus.value = result['difficultyNivea'] as List<String>;
    difficultyLabels.value = result['difficultyLabels'] as List<String>;
    dbpath.value = result['firestorePath'];
  }

  void addLocalPlayer(String playerName) {
    if (playerName.trim().isNotEmpty) {
      localPlayers.add(playerName.trim());
    }
  }

  void removeLocalPlayer(int index) {
    if (index >= 0 && index < localPlayers.length) {
      localPlayers.removeAt(index);
    }
  }

  void clearLocalPlayers() => localPlayers.clear();

  void setOfflineMode(bool value){
    _gameSubscription?.cancel();
    isOfflineMode.value = value;
    isJoiningMode.value = false;
    if (!value) {
      clearLocalPlayers();
    }
  }

  void setOnlineMode(bool value) {
    isOnlineMode.value = value;
    value? generateGameCode() : {
      clearGameCode(),
      isJoiningMode.value = false,
    };
  }

  void setJoinMode(bool value){
    isJoiningMode.value = value;
    if(value){
      isOfflineMode.value = false;
      isOnlineMode.value = false;
    }
  }

  void generateGameCode() => gameCode.value = generateStrings(6);
  void clearGameCode() => gameCode.value = '';

  void _initializeAlphabet(){
    final Map<String, List<String>> alphabetMap = {
      "fa": Alphabets.persian,
      "ar": Alphabets.arabic,
      "dk": Alphabets.danish,
    };
    alphabet.value = alphabetMap[authController.language[0]] ?? Alphabets.english;
    update();
  }

  String normalizeAlphabet(String guessWord) {
    String normalized = guessWord.replaceAll(RegExp(r'\s+'), '').trim(); // First remove any extra spaces
    bool isRtlLanguage = authController.language[0] == "fa" || authController.language[0] == "ar";

    // For Arabic and Persian, also remove special RTL characters
    if (isRtlLanguage) {
      normalized = normalized
          .replaceAll('\u200C', '')
          .replaceAll(RegExp(r'[\u200B-\u200F\u061C\uFEFF\u200D]'), '')
          .replaceAll(RegExp(r'[\u202A-\u202E\u2066-\u2069]'), '');
    }
    return isRtlLanguage? normalized : normalized.toUpperCase();
  }

  void resetGameStates() {
    guessedLetters.clear();
    incorrectGuesses.value = 0;
    gameLost.value = false;
    gameWon.value = false;
    wordHint.value = "";
  }
}