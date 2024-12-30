import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/constants/alphabets.dart';
import 'package:playbazaar/games/services/hangman_services.dart';
import 'package:playbazaar/global_widgets/show_custom_snackbar.dart';
import 'package:playbazaar/global_widgets/string_return_dialog.dart';
import '../../../../functions/generate_strings.dart';
import '../../../../helper/sharedpreferences/sharedpreferences.dart';
import '../../../../screens/widgets/dialogs/accept_result_dialog.dart';
import '../../../functions/get_hangman_difficulty.dart';


class PlayController extends GetxController {
  // static
  HangmanService hangmanService = Get.put(HangmanService());
  final RxList<String> difficultyNiveaus = <String>[].obs;
  final RxList<String> difficultyLabels = <String>[].obs;
  final RxList<String> localPlayers = <String>[].obs;
  final RxBool isLocalMultiplayerMode = false.obs;
  RxList<String> alphabet = <String>[].obs;
  final RxBool isOnlineMode = false.obs;
  final RxString gameCode = ''.obs;
  RxBool isAlphabetRTL = false.obs;
  RxString  language = "".obs;
  Rx<String> dbpath = "".obs;
  final int maxIncorrectGuesses = 6;

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




  @override
  void onInit() async {
    super.onInit();
    await getAppLanguage();
    await getDifficultyAndPath();
    _initializeAlphabet();
  }

  void startNewGame() {
    if(words.isEmpty) return;
    wordToGuess.value = normalizeAlphabet(words[currentIndex.value]).toUpperCase();
    guessedLetters.clear();
    incorrectGuesses.value = 0;
    gameLost.value = false;
    gameWon.value = false;
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


  void checkGuess(String letter) {
    if (!guessedLetters.contains(letter)) {
      guessedLetters.add(letter);
      String normalizedWord = normalizeAlphabet(wordToGuess.value);

      if(!normalizedWord.contains(letter)) incorrectGuesses.value++;
      if(!buildHiddenWord().contains('_')) gameWon.value = true;
      if (incorrectGuesses.value >= maxIncorrectGuesses) gameLost.value = true;
    }
  }

  Future<void> startNextGame(BuildContext context) async {
    currentIndex.value++;
    if(isLocalMultiplayerMode.value) {
      await getPlayerGuess(context);
      startNewGame();
      return;
    }
    if(currentIndex.value == words.length -1){
      await _loadWords();
      showCustomSnackbar("Reading new words", false);
    }
    startNewGame();
  }



  Future<void> _loadWords() async {
    final random = Random();
    final retrievedWords = await hangmanService.getRandomHangmanWords(collectionId: dbpath.value);
    if(retrievedWords == null || retrievedWords.words.isEmpty) {
      showCustomSnackbar("restart_app_fail".tr, false);
      return;
    }
    currentIndex.value = 0;
    words.clear();
    retrievedWords.words.shuffle(random);
    words.addAll(retrievedWords.words.map((word) => word.trim().toUpperCase()));
    wordHint.value = retrievedWords.hint;
  }

  // Offline part
  void toggleLocalMultiplayerMode(bool value) {
    isLocalMultiplayerMode.value = value;
    if (!value) {
      clearLocalPlayers();
    }
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

  // online part
  void generateGameCode() => gameCode.value = generateStrings(6);
  void clearGameCode() => gameCode.value = '';

  void toggleOnlineMode(bool value) {
    isOnlineMode.value = value;
    value? generateGameCode() : clearGameCode();
  }

  // Navigation
  Future<void> startSoloGamePlay() async {
    if(isLocalMultiplayerMode.value || isOnlineMode.value){
      return acceptResultDialog( Get.context,
        "deactive_other_options".tr,
        "deactive_play_with_friends".tr
      );
    }
    else{
      await _loadWords();
      startNewGame();
      Get.toNamed('/hangman');
    }
  }

  Future<void> startTeamPlayGame(BuildContext context) async {
    if(isLocalMultiplayerMode.value && localPlayers.length < 2){
      showCustomSnackbar("zero_player_error".tr, false);
      return;
    }
    if (isLocalMultiplayerMode.value) {
      words.clear();
      wordHint.value = "";
      await getPlayerGuess(context);
    }
    Get.toNamed('/hangman');
    startNewGame();
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
    List<String>? value = await SharedPreferencesManager.getStringList(SharedPreferencesKeys.appLanguageKey);
    if(value != null && value.isNotEmpty){
      language.value = value[0];
      value[0] == 'fa'? isAlphabetRTL.value = true : false;
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

  void _initializeAlphabet() {
    final Map<String, List<String>> alphabetMap = {
      'fa': Alphabets.persian,
      'ar': Alphabets.arabic,
      'da': Alphabets.danish,
    };
    alphabet.value = alphabetMap[language.value] ?? Alphabets.english;
  }

  String normalizeAlphabet(String guessWord) {
    if (language.value == 'fa' || language.value == 'ar') {
      return guessWord.replaceAll(
        // This is important for none-visible characters in RTL alphabets
          RegExp(r'[\u200c\u200e\u200f\u202a-\u202e\u2066-\u2069\u00a0\s]+'),
          ''
      ).trim();
    }
    return guessWord.trim();
  }

}