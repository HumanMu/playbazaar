import 'package:get/get.dart';
import 'package:playbazaar/global_widgets/show_custom_snackbar.dart';
import '../controller/base_ludo_controller.dart';
import '../helper/enums.dart';
import '../controller/dice_controller.dart';
import '../controller/offline_ludo_controller.dart';
import '../controller/online_ludo_controller.dart';
import '../services/base_ludo_service.dart';
import '../services/offline_ludo_service.dart';
import '../services/online_ludo_service.dart';


class LudoServiceLocator {
  static bool _isInitialized = false;
  static GameMode _gameMode = GameMode.offline;

  static Future<void> initialize(GameMode gameMode) async {
    if (_isInitialized) {
      await cleanup();
    }

    _gameMode = gameMode;

    await _registerGameService(gameMode);
    _registerControllers(gameMode);
    _registerCommonServices();

    _isInitialized = true;
  }

  /// Register common services used by all game modes
  static void _registerCommonServices() {
    Get.lazyPut<DiceController>(() => DiceController());
  }


  static Future<void> _registerGameService(GameMode gameMode) async {
    late BaseLudoService gameService;

    switch (gameMode) {
      case GameMode.offline:
        gameService = OfflineLudoService();
        Get.put<OfflineLudoService>(gameService as OfflineLudoService, permanent: false);
        break;

      case GameMode.online:
        gameService = OnlineLudoService();
        Get.put<OnlineLudoService>(gameService as OnlineLudoService, permanent: false);
        break;
    }

    Get.put<BaseLudoService>(gameService, permanent: false);
  }

  static void _registerControllers(GameMode gameMode) {
    late BaseLudoController controller;

    switch (gameMode) {
      case GameMode.offline:
        controller = OfflineLudoController();
        Get.put<OfflineLudoController>(controller as OfflineLudoController, permanent: false);
        break;

      case GameMode.online:
        controller = OnlineLudoController();
        Get.put<OnlineLudoController>(controller as OnlineLudoController, permanent: false);
        break;
    }

    Get.put<BaseLudoController>(controller, permanent: false);
  }

  /// Initialize the game with the specified parameters
  static Future<void> initializeGame({
    int? numberOfPlayers,
    bool teamPlay = false,
    bool enableRobots = false,
    String? gameCode,
    bool isHost = false,
  }) async {
    if (!_isInitialized) {
      throw Exception('GameServiceLocator must be initialized before initializing the game');
    }

    if (_gameMode == GameMode.offline) {
      final offlineService = Get.find<OfflineLudoService>();
      final numberOfPlayersToInit = (teamPlay || enableRobots)? 4 : numberOfPlayers;
      await offlineService.init(numberOfPlayersToInit!, teamPlay: teamPlay);

    } else {
      final onlineService = Get.find<OnlineLudoService>();
      final onlineController = Get.find<OnlineLudoController>();
      await onlineService.init(numberOfPlayers?? 0, teamPlay: teamPlay);

      if (gameCode == null || gameCode.isEmpty) {
        showCustomSnackbar('Game code is required for to create or join a game.', false);
        return;
      }

      if (isHost) {
        await onlineController.createLudoGame(
          teamPlay: teamPlay,
          enableRobots: enableRobots,
          gameCode: gameCode,
        );

      } else {
        await onlineController.joinExistingGame(gameCode);
      }
    }
  }

  static GameMode get currentMode => _gameMode;
  static bool get isInitialized => _isInitialized;

  /// Cleanup all registered services
  static Future<void> cleanup() async {

    // Remove all game-related services
    if (Get.isRegistered<BaseLudoService>()) {
      Get.delete<BaseLudoService>();
    }

    if (Get.isRegistered<OfflineLudoService>()) {
      Get.delete<OfflineLudoService>();
    }

    if (Get.isRegistered<OnlineLudoService>()) {
      Get.delete<OnlineLudoService>();
    }

    if (Get.isRegistered<BaseLudoController>()) {
      Get.delete<BaseLudoController>();
    }

    if (Get.isRegistered<OfflineLudoController>()) {
      Get.delete<OfflineLudoController>();
    }

    if (Get.isRegistered<OnlineLudoController>()) {
      Get.delete<OnlineLudoController>();
    }

    if (Get.isRegistered<DiceController>()) {
      Get.delete<DiceController>();
    }

    _isInitialized = false;
  }


  /// Get a service instance
  static T get<T>() {
    if (!_isInitialized) {
      throw Exception('GameServiceLocator must be initialized before accessing services');
    }
    return Get.find<T>();
  }

  /// Check if a service is registered
  static bool isRegistered<T>() {
    return Get.isRegistered<T>();
  }
}