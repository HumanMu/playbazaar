/// Central registry for all dialog IDs in one place
class AppDialogIds {
  AppDialogIds._(); // Private constructor

  // Game dialogs
  static const String ludoWaitingRoom = 'ludo_waiting_room';
  static const String ludoGameOver = 'ludo_game_over';
  static const String ludoOnlineGameCreation = 'ludo_online_game_creation';
  static const String optionizedQuizDialog = 'quiz_end_game_dialog';
  static const String noneOptionizedQuizDialog = 'quiz_end_game_dialog';


  // System dialogs
  static const String networkError = 'network_error';
  static const String maintenanceMode = 'maintenance_mode';

  // User dialogs
  static const String confirmLogout = 'confirm_logout';
  static const String profileSettings = 'profile_settings';
  static const String acceptDialog = 'accept_dialog';
}