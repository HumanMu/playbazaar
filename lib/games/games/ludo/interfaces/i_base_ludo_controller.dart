
import '../models/token.dart';

abstract class IBaseLudoController {
  Future<void> initializeServices();
  Future<void> initializePlayers();
  Future<void> handleTokenTap(Token token);
  Future<void> moveToken(Token token, dynamic controller);
  void restartGame();
}