import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playbazaar/games/games/ludo/helper/functions.dart';
import 'package:playbazaar/games/games/ludo/models/dice_model.dart';
import 'package:playbazaar/games/games/ludo/models/ludo_creattion_params.dart';
import 'package:playbazaar/games/games/ludo/models/ludo_player.dart';
import '../../../../admob/interstitial_rewarded.dart';
import '../../../../config/routes/router_provider.dart';
import '../../../../constants/app_dialog_ids.dart';
import '../../../../core/dialog/dialog_manager.dart';
import '../helper/enums.dart';
import '../interfaces/i_base_ludo_controller.dart';
import '../locator/service_locator.dart';
import '../models/token.dart';
import '../services/base_ludo_service.dart';
import '../widgets/game_over.dart';
import 'dice_controller.dart';

abstract class BaseLudoController extends GetxController implements IBaseLudoController {

  BaseLudoService get gameService => LudoServiceLocator.get<BaseLudoService>();
  DiceController get diceController => LudoServiceLocator.get<DiceController>();
  DialogManager get dialogManager => LudoServiceLocator.get<DialogManager>();

  final _rewardedAdManager = RewardedInterstitialAdManager();


  final List<List<GlobalKey>> keyReferences = LudoHelper.getGlobalKeys();
  final DiceModel diceModel = DiceModel();

  // Common reactive variables
  List<Token?> get gameTokens => gameService.gameTokens;
  final RxList<LudoPlayer> players = <LudoPlayer>[].obs;
  final RxBool wasLastToken = false.obs;
  final RxBool boardBuild = false.obs;
  final RxBool isTeamPlay = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isRobotOn = false.obs;
  final RxInt numberOfHumanPlayers = 4.obs;
  late RxBool isHost = false.obs;
  late GameMode gameMode = GameMode.offline;

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
    LudoHelper.clearKeyCache();

    // Add post frame callback to set boardBuild
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      boardBuild.value = true;
      await onBoardBuilt();
    });
    _rewardedAdManager.loadAd();

    isLoading.value = false;
  }

  // Template method - subclasses can override
  Future<void> onBoardBuilt() async {}

  @override
  Future<void> initializeServices(LudoCreationParamsModel params);


  bool getMovableTokens(TokenType type, int diceValue) {
    return gameService.getMovableTokens(type, diceValue);
  }

  void printMessage(String message) {
    debugPrint(message);
  }


  bool hasEnoughSpaceToMove(Token token, int diceValue) {
    return token.positionInPath + diceValue <= 56;
  }

  Future<void> handleDiceRollResult(int diceValue, TokenType currentPlayerType) async {
    final availableToken = getMovableTokens(currentPlayerType, diceValue);

    if (diceValue != 6 && !availableToken && gameMode == GameMode.offline) {
      await diceController.processNextPlayer();

    } else if (diceValue == 6) {
      final hasInitialToken = gameService.hasInitialToken(currentPlayerType);

      if (!hasInitialToken && !availableToken) {
        await diceController.processNextPlayer();
      } else {
        diceController.setMoveState(true);
        diceController.setDiceRollState(false);
        await onAwaitingTokenSelection(currentPlayerType, diceValue);
      }
    } else {
      diceController.setMoveState(true);
      diceController.setDiceRollState(false);
      await onAwaitingTokenSelection(currentPlayerType, diceValue);
    }
  }

  Future<void> onAwaitingTokenSelection(TokenType player, int diceValue) async {}

  Future<void> updateReachedHome(Token token) async {
    final index = players.indexWhere((e) => e.tokenType == token.type);
    if (index != -1) {
      final player = players[index];
      final newReachedHome = player.numberOfreachedHome + 1;
      final hasFinished = newReachedHome >= 4;

      players[index] = player.copyWith(
        numberOfreachedHome: newReachedHome,
        hasFinished: hasFinished,
      );

      wasLastToken.value = players[index].hasFinished;

      final isGameOver = checkForGameOver();
      if (isGameOver) {
        await Future.delayed(const Duration(), () {
          showGameOverDialog();
        });
        debugPrint(
            'Game over! ${isTeamPlay.value ? "Team ${player.teamId}" : player.name} wins!');
      }
    }
  }

  bool checkForGameOver() {
    if (!isTeamPlay.value) {
      return players
          .where((player) => player.hasFinished == true)
          .length == 1;
    } else {
      Map<int, int> teamMemberCount = {};
      Map<int, int> teamFinishedCount = {};

      for (var player in players) {
        if (player.teamId != null) {
          teamMemberCount[player.teamId!] =
              (teamMemberCount[player.teamId!] ?? 0) + 1;
          if (player.hasFinished) {
            teamFinishedCount[player.teamId!] =
                (teamFinishedCount[player.teamId!] ?? 0) + 1;
          }
        }
      }

      for (var teamId in teamMemberCount.keys) {
        if (teamFinishedCount[teamId] == teamMemberCount[teamId]) {
          return true;
        }
      }

      return false;
    }
  }

  bool basicTokenTapCheck(Token token) {
    diceController.setDiceRollState(false);

    if (token.tokenState == TokenState.home
        || (token.tokenState == TokenState.initial && diceController.diceValue != 6)
        || token.type != diceController.color
        || !diceController.moveState) {
      diceController.setMoveState(false);
      return false;
    }
    diceController.setMoveState(false);

    if (!hasEnoughSpaceToMove(token, diceController.diceValue)) return false;
    return true;
  }

  void syncTeamAssignments(bool teamPlay) {
    if (!teamPlay) {
      gameService.isTeamPlayEnabled = false;
      return;
    }

    Map<TokenType, int?> teamAssignments = {};

    for (final player in players) {
      if (player.teamId != null) {
        teamAssignments[player.tokenType] = player.teamId;
      }
    }

    gameService.setTeamAssignments(teamAssignments);
    gameService.isTeamPlayEnabled = true;
  }

  Future<void> showGameOverDialog({bool isLeaving = false}) async {
    _showRewardedAdBeforeGameOver(isLeaving: isLeaving);
  }


  Future<void> _showRewardedAdBeforeGameOver({bool isLeaving = false}) async {
    if (_rewardedAdManager.isAdReady) {
      await _rewardedAdManager.showAd(
        onUserEarnedReward: () => _displayGameOverDialog(isLeaving: isLeaving),
        onAdDismissed: () => _displayGameOverDialog(isLeaving: isLeaving),
        onAdFailedToShow: ()=> _displayGameOverDialog(isLeaving: isLeaving),
      );
    } else {
      _displayGameOverDialog(isLeaving: isLeaving);
    }
  }

  void _displayGameOverDialog({bool isLeaving = false}) {
    if(isLeaving) {
      rootNavigatorKey.currentContext?.push("/ludoHome");
      return;
    }

    dialogManager.showDialog(
      dialog: GameOverDialog(
        players: players,
        isTeamPlay: isTeamPlay.value,
        onWatchRemaining: () {
          dialogManager.closeDialog();
          _rewardedAdManager.loadAd();
        },
        onLeave: () {
          dialogManager.closeDialog();
          rootNavigatorKey.currentContext?.push("/ludoHome");
        },
      ),
      barrierDismissible: false,
      priority: DialogPriority.critical,
      routeSettings: const RouteSettings(name: AppDialogIds.ludoGameOver),
    );
  }
}