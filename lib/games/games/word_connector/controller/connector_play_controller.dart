import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../helper/sharedpreferences/sharedpreferences.dart';
import '../../../services/word_connector_service.dart';
import '../models/word_model.dart';


class ConnectorPlayController extends GetxController {
  final WordConnectorService _service;
  AudioPlayer? _soundPlayer;

  final RxList<WordConnectorModel> words = <WordConnectorModel>[].obs;
  final RxString currentWord = ''.obs;
  final RxList<String> letters = <String>[].obs;
  final RxList<int> selectedIndices = <int>[].obs;
  final RxList<String> selectedLetters = <String>[].obs;


  // Game state
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  ConnectorPlayController({WordConnectorService? service})
      : _service = service ?? WordConnectorService();

  @override
  void onInit() {
    super.onInit();
    _initSound();
    loadGameData();
  }

  @override
  void onClose() {
    _soundPlayer?.dispose();
    super.onClose();
  }

  Future<void> loadGameData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final gameData = await _service.getGameData();
      if (gameData.words.isEmpty || gameData.letters.isEmpty) {
        throw Exception('Invalid game data received');
      }

      // Update state atomically
      words.value = gameData.words;
      letters.value = gameData.letters;

    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load game data: ${e.toString()}';
      debugPrint('Error in loadGameData: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initializeGame() async {
    try {
      isLoading.value = true;
      await _service.initializeDefaultData();
      await loadGameData();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to initialize game: ${e.toString()}';
      debugPrint('Error in initializeGame: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // New method: Start word with index
  void startWordWithIndex(int index) {
    if (index < 0 || index >= letters.length) return;

    final letter = letters[index];
    selectedIndices.value = [index];
    selectedLetters.value = [letter];
    currentWord.value = letter;
  }

  // New method: Add letter by index
  void addLetterIndex(int index) {
    if (index < 0 || index >= letters.length) return;
    if (selectedIndices.contains(index)) return;

    final letter = letters[index];
    selectedIndices.add(index);
    selectedLetters.add(letter);
    currentWord.value = currentWord.value + letter;
  }

  // Keeping old methods for compatibility
  void startWord(String letter) {
    if (letter.isEmpty) return;

    final index = letters.indexOf(letter);
    if (index != -1) {
      startWordWithIndex(index);
    }
  }

  void addLetter(String letter) {
    if (letter.isEmpty) return;

    final index = letters.indexWhere((l) =>
    l == letter && !selectedIndices.contains(letters.indexOf(l)));
    if (index != -1) {
      addLetterIndex(index);
    }
  }

  void endWord() {
    final attempt = currentWord.value;
    if (attempt.isEmpty) return;

    try {
      final wordIndex = words.indexWhere((w) => w.text == attempt);

      if (wordIndex != -1 && !words[wordIndex].isFound) {
        final updatedWords = List<WordConnectorModel>.from(words);
        updatedWords[wordIndex] = updatedWords[wordIndex].copyWith(isFound: true);
        words.value = updatedWords;
        _startSound();
      }
    } catch (e) {
      debugPrint('Error in endWord: $e');
    } finally {
      selectedLetters.clear();
      selectedIndices.clear();  // Clear indices too
      currentWord.value = '';
    }
  }

  void resetGame() {
    try {
      final resetWords = words.map(
              (word) => word.copyWith(isFound: false)
      ).toList();

      words.value = resetWords;
      selectedLetters.clear();
      selectedIndices.clear();  // Clear indices too
      currentWord.value = '';
      hasError.value = false;
      errorMessage.value = '';
    } catch (e) {
      debugPrint('Error in resetGame: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to reset game';
    }
  }

  // Helper methods
  bool get isGameComplete => words.every((word) => word.isFound);
  int get currentScore => words.where((word) => word.isFound).length;


  Future<void> resetUserLevel() async{
    await SharedPreferencesManager.setInt(SharedPreferencesGameKeys.wordConnectorUserLevel, 0);
  }

  Future<void> _startSound() async {
    try {
      await _soundPlayer?.seek(Duration.zero);
      await _soundPlayer?.play();
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> _initSound() async {
    try {
      _soundPlayer = AudioPlayer();
      await _soundPlayer?.setAsset('assets/sounds/end_game/found_answer.mp3');

    } catch (e) {
      debugPrint('Error initializing sound player for crying emoji: $e');
    }
  }
}