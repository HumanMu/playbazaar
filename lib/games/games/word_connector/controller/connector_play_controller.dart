import '../../../../controller/user_controller/auth_controller.dart';
import '../../../../global_widgets/dialog/yes_no_dialog.dart';
import '../../../../helper/sharedpreferences/sharedpreferences.dart';
import '../../../services/word_connector_service.dart';
import '../models/dto/sharedpreferences_dto.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import '../models/word_model.dart';
import 'package:get/get.dart';


class ConnectorPlayController extends GetxController {
  AudioPlayer? _soundPlayer;
  final WordConnectorService _service;
  final authController = Get.find<AuthController>();

  final RxInt points = 0.obs;
  final RxString currentWord = ''.obs;
  final RxList<String> letters = <String>[].obs;
  final RxList<int> selectedIndices = <int>[].obs;
  final RxList<String> gameLevel = <String>[].obs;
  final RxList<String> selectedLetters = <String>[].obs;
  final RxList<WordConnectorModel> words = <WordConnectorModel>[].obs;

  RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<SharedpreferencesDto> gameState = SharedpreferencesDto(
    level: 1,
    count: 1,
    points: 0,
    language: 'en',
  ).obs;


  ConnectorPlayController({WordConnectorService? service})
      : _service = service ?? WordConnectorService();

  @override
  void onInit() {
    super.onInit();
    initializeGame();
    _initSound();
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
      points.value = 0;
      gameState.value = await getGameData();

      final gameData = await _service.getConnectorWords(gameState.value);
      if (gameData.words.isEmpty || gameData.letters.isEmpty) {
        throw Exception('Invalid game data received');
      }

      words.assignAll(gameData.words);
      letters.assignAll(gameData.letters);

    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load game data: ${e.toString()}';
      debugPrint('Error in loadGameData: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> initializeGame() async {
    try {
      isLoading.value = true;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to initialize game';
      debugPrint('Error in initializeGame: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<SharedpreferencesDto> getGameData() async{
    final String dataKey = "${SharedPreferencesGameKeys.wordConnectorUserLevel}_${gameState.value.language}";
    SharedpreferencesDto? pref = await SharedPreferencesManager.getWordConnectorData(dataKey);
    if(pref == null) {
      pref = SharedpreferencesDto(level: 1, count: 1, language: gameState.value.language, points: 0);
      return pref;
    }
    return pref;
  }

  Future<void> resetUserLevel() async{
    try {
      final String dataKey = "${SharedPreferencesGameKeys.wordConnectorUserLevel}_${gameState.value.language}";
      final resetData = SharedpreferencesDto(level: 1, count: 1, language: gameState.value.language, points: 0);
      await SharedPreferencesManager.setWordConnectorData(dataKey, resetData);
      gameState.value = resetData;
      update();
    }catch(e){
      debugPrint("Error while resetting your level $e");
    }
  }

  void startWordWithIndex(int index) {
    if (index < 0 || index >= letters.length) return;

    final letter = letters[index];
    selectedIndices.value = [index];
    selectedLetters.value = [letter];
    currentWord.value = letter;
  }

  void addLetterIndex(int index) {
    if (index < 0 || index >= letters.length) return;
    if (selectedIndices.contains(index)) return;

    final letter = letters[index];
    selectedIndices.add(index);
    selectedLetters.add(letter);
    currentWord.value = currentWord.value + letter;
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
        points.value +=15;

        // Update points by creating a new instance of SharedpreferencesDto
        gameState.value = gameState.value.copyWith(
          points: gameState.value.points + 15,
        );

        // Check if this was the last word
        if (words.where((w) => w.isFound).length == words.length) {
          _playSound('assets/sounds/end_game/game_complete.mp3');
          setGameData();
        } else {
          _playSound('assets/sounds/end_game/found_answer.mp3');
        }
      } else {
        // Update points by creating a new instance of SharedpreferencesDto
        gameState.value = gameState.value.copyWith(
          points: gameState.value.points - 1,
        );
        points.value -=1;
      }
    } catch (e) {
      debugPrint('Error in endWord: $e');
    } finally {
      selectedLetters.clear();
      selectedIndices.clear();
      currentWord.value = '';
      update();
    }
  }

  Future<void> setGameData() async{
    if(gameState.value.count >= 10) {
      gameState.value.count = 0;
      gameState.value.level++;
    }else{
      gameState.value.count++;
    }
    final String levelKey = "${SharedPreferencesGameKeys.wordConnectorUserLevel}_${gameState.value.language}";
    await SharedPreferencesManager.setWordConnectorData(levelKey, gameState.value);
    showResult();
  }


  Future<void> _initSound() async {
    try {
      _soundPlayer = AudioPlayer();
    } catch (e) {
      debugPrint('Error initializing sound player: $e');
    }
  }

  Future<void> _playSound(String assetPath) async {
    try {
      await _soundPlayer?.setAsset(assetPath);
      await _soundPlayer?.seek(Duration.zero);
      await _soundPlayer?.play();
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }


  void showResult() {
    Get.dialog(
      YesNoDialog(
        title: 'game_result'.tr,
        description: 'round_result'.tr.replaceAll('%1',points.value.toString()),
        onYes: () {
          Get.back();
          loadGameData();
        },
        onNo: () {
          Get.back();
        },
      ),
    );
  }

}