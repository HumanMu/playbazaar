
import 'package:playbazaar/games/games/ludo/models/ludo_creattion_params.dart';

import '../models/token.dart';

abstract class IBaseLudoController {
  Future<void> initializeServices(LudoCreationParamsModel params);
  Future<void> initializePlayers();
  Future<void> handleTokenTap(Token token);
  Future<void> moveToken(Token token, dynamic controller);
  void restartGame();
}