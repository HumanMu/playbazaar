import '../helper/enums.dart';

class GameConfig {
  static const bool enableOnlineMode = false;

  /// Get the appropriate game mode based on configuration and parameters
  static GameMode getGameMode({bool? forceOffline}) {
    if (forceOffline == true || !enableOnlineMode) {
      return GameMode.offline;
    }
    return GameMode.online;
  }

  static const colorSequences = ["red", "yellow", "green", "blue"];
}