import 'package:get/get.dart';
import '../controller/base_ludo_controller.dart';
import '../helper/enums.dart';
import '../controller/dice_controller.dart';
import '../controller/offline_ludo_controller.dart';
import '../controller/online_ludo_controller.dart';
import '../services/base_ludo_service.dart';
import '../services/offline_ludo_service.dart';
import '../services/online_ludo_service.dart';

/// Centralized service locator for managing game dependencies
class LudoServiceLocator {
  static bool _isInitialized = false;
  static GameMode _currentMode = GameMode.offline;

  static Future<void> initialize(GameMode mode) async {
    if (_isInitialized) {
      await cleanup();
    }

    _currentMode = mode;

    await _registerGameService(mode);
    _registerControllers(mode);
    _registerCommonServices();

    _isInitialized = true;
  }

  /// Register common services used by all game modes
  static void _registerCommonServices() {
    Get.lazyPut<DiceController>(() => DiceController());
  }


  static Future<void> _registerGameService(GameMode mode) async {
    late BaseLudoService gameService;

    switch (mode) {
      case GameMode.offline:
        gameService = OfflineLudoService();
        Get.put<OfflineLudoService>(gameService as OfflineLudoService, permanent: false);
        break;

      case GameMode.online:
        gameService = OnlineLudoService();
        Get.put<OnlineLudoService>(gameService as OnlineLudoService, permanent: false);
        break;
    }

    // Register the base service
    Get.put<BaseLudoService>(gameService, permanent: false);
  }

  static void _registerControllers(GameMode mode) {
    late BaseLudoController controller;

    switch (mode) {
      case GameMode.offline:
        controller = OfflineLudoController();
        Get.put<OfflineLudoController>(controller as OfflineLudoController, permanent: false);
        break;

      case GameMode.online:
        controller = OnlineLudoController();
        Get.put<OnlineLudoController>(controller as OnlineLudoController, permanent: false);
        break;
    }

    // Register the base controller
    Get.put<BaseLudoController>(controller, permanent: false);
  }

  /// Initialize the game with the specified parameters
  static Future<void> initializeGame({
    required int numberOfPlayers,
    bool teamPlay = false,
    bool enableRobots = false,
  }) async {
    if (!_isInitialized) {
      throw Exception('GameServiceLocator must be initialized before initializing the game');
    }

    final gameService = Get.find<BaseLudoService>();
    final numberOfPlayersToInit = (teamPlay || enableRobots) ? 4 : numberOfPlayers;

    await gameService.init(numberOfPlayersToInit, teamPlay: teamPlay);
  }

  /// Get the current game mode
  static GameMode get currentMode => _currentMode;

  /// Check if services are initialized
  static bool get isInitialized => _isInitialized;

  /// Cleanup all registered services
  static Future<void> cleanup() async {
    if (!_isInitialized) return;

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