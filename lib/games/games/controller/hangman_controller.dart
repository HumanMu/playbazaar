
import 'dart:math';
import 'package:get/get.dart';

import '../../../helper/sharedpreferences/sharedpreferences.dart';

class HangmanController extends GetxController {
  RxList<String> words = <String>['flutter', 'dart', 'programming', 'mobile', 'application', 'computer', 'science', 'algorithm', 'database', 'network'].obs;
  RxString wordToGuess = ''.obs;
  RxList<String> guessedLetters = <String>[].obs;
  RxInt incorrectGuesses = 0.obs;
  final int maxIncorrectGuesses = 6;
  RxBool gameWon = false.obs;
  RxBool gameLost = false.obs;
  RxBool isPersian = false.obs;

  @override
  void onInit() {
    super.onInit();
    getLanguage();
    _loadWords();   // implement it read from
    startNewGame();
  }
  void getLanguage() async{
    List<String>? value = await SharedPreferencesManager.getStringList(SharedPreferencesKeys.appLanguageKey);
    if(value != null && value.isNotEmpty){
      value[0] == 'fa'? isPersian.value = true : false;
    }else{
      isPersian.value = false;
    }
    startNewGame();
  }

  void startNewGame() {
    final random = Random();
    wordToGuess.value = words[random.nextInt(words.length)].toUpperCase();
    guessedLetters.clear();
    incorrectGuesses.value = 0;
    gameWon.value = false;
    gameLost.value = false;
  }

  String buildHiddenWord() {
    String hiddenWord = '';
    for (int i = 0; i < wordToGuess.value.length; i++) {
      if (guessedLetters.contains(wordToGuess.value[i])) {
        hiddenWord += '${wordToGuess.value[i]} ';
      } else {
        hiddenWord += '_ ';
      }
    }
    return hiddenWord;
  }

  void checkGuess(String letter) {
    if (!guessedLetters.contains(letter)) {
      guessedLetters.add(letter);
      if (!wordToGuess.value.contains(letter)) {
        incorrectGuesses.value++;
      }
      if (!buildHiddenWord().contains('_')) {
        gameWon.value = true;
      }
      if (incorrectGuesses.value >= maxIncorrectGuesses) {
        gameLost.value = true;

      }
    }
  }

  void _loadWords() {

  }
}