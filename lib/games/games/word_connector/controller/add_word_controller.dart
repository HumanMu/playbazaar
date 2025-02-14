import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/word_connector/models/add_word_model.dart';
import 'package:playbazaar/global_widgets/show_custom_snackbar.dart';
import '../../../../controller/user_controller/auth_controller.dart';
import '../../../services/word_connector_service.dart';

class AddWordController extends GetxController {
  final WordConnectorService firebaseService;
  final authController = Get.find<AuthController>();

  // Text controllers
  final TextEditingController wordController = TextEditingController();
  final TextEditingController wordLevelController = TextEditingController();
  final TextEditingController lettersController = TextEditingController();
  RxnString languageDirectory = RxnString("");

  // Observable lists
  final RxList<String> currentWords = <String>[].obs;
  final RxList<String> currentLetters = <String>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  AddWordController({WordConnectorService? firebaseService})
      : firebaseService = firebaseService ?? WordConnectorService();

  @override
  void onClose() {
    wordController.dispose();
    wordLevelController.dispose();
    lettersController.dispose();
    super.onClose();
  }

  void addWord() {
    final word = wordController.text.trim().toUpperCase();

    if (word.isEmpty) {
      showCustomSnackbar("empty_field".tr, false);
      return;
    }

    if (currentWords.contains(word)) {
      showCustomSnackbar("word_already_exist".tr, false);
      return;
    }

    // Track letter frequency in the new word
    final wordLetterFrequency = <String, int>{};
    for (var letter in word.split('')) {
      wordLetterFrequency[letter] = (wordLetterFrequency[letter] ?? 0) + 1;
    }

    // Track the frequency of letters in currentLetters
    final currentLetterFrequency = <String, int>{};
    for (var letter in currentLetters) {
      currentLetterFrequency[letter] = (currentLetterFrequency[letter] ?? 0) + 1;
    }

    // Update currentLetters based on the new word's letter frequencies
    for (var entry in wordLetterFrequency.entries) {
      final letter = entry.key;
      final newCount = entry.value;

      // Get the current count of the letter in currentLetters
      final currentCount = currentLetterFrequency[letter] ?? 0;

      // If the new word increases the frequency of the letter, add the difference
      if (newCount > currentCount) {
        final lettersToAdd = newCount - currentCount;
        for (var i = 0; i < lettersToAdd; i++) {
          currentLetters.add(letter);
        }
      }
    }

    // Add the word to the list
    currentWords.add(word);
    wordController.clear();
  }

  Future<void> saveWordsToFirestore() async {
    if (currentWords.isEmpty || currentLetters.isEmpty) {
      showCustomSnackbar("nothing_to_save".tr, false);
      return;
    }

    if (wordLevelController.value.text == "") {
      showCustomSnackbar("max_level_100".tr, false);
      return;
    }

    if(languageDirectory.value == null || languageDirectory.value == ""){
      showCustomSnackbar("pick_a_language".tr, false);
      return;
    }
    isLoading.value = true;

    try {
      int? wordLevel = int.tryParse(wordLevelController.text);
      AddWordModel newWords = AddWordModel(
          words: currentWords,
          letters: currentLetters,
          level: wordLevel ?? 0,
      );

      final word = await firebaseService.addWord(newWords, languageDirectory.value ??"");
      showCustomSnackbar("quetion_added_title".tr, true);
      currentWords.clear();
      currentLetters.clear();

    } catch (e) {
      showCustomSnackbar("unexpected_result".tr, false);
    } finally {
      isLoading.value = false;
    }
  }

}
