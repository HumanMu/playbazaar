import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:playbazaar/games/games/ludo/helper/functions.dart';
import 'package:playbazaar/games/games/ludo/models/dice_model.dart';
import 'package:playbazaar/games/games/ludo/models/ludo_player.dart';
import '../helper/enums.dart';
import '../interfaces/i_base_ludo_controller.dart';
import '../locator/service_locator.dart';
import '../models/position.dart';
import '../models/token.dart';
import '../services/base_ludo_service.dart';
import '../widgets/game_over.dart';
import 'dice_controller.dart';

abstract class BaseLudoController extends GetxController implements IBaseLudoController {

  BaseLudoService get gameService => LudoServiceLocator.get<BaseLudoService>();
  DiceController get diceController => LudoServiceLocator.get<DiceController>();

  final DiceModel diceModel = DiceModel();
  final List<List<GlobalKey>> keyReferences = LudoHelper.getGlobalKeys();

  // Common reactive variables
  List<Token?> get gameTokens => gameService.gameTokens;
  RxList<LudoPlayer> players = <LudoPlayer>[].obs;
  final RxBool wasLastToken = false.obs;
  final RxBool boardBuild = false.obs;
  final RxBool isTeamPlay = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isRobotOn = false.obs;
  final RxInt numberOfHumanPlayers = 4.obs;

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;

    await initializeServices();
    await initializePlayers();

    // Add post frame callback to set boardBuild
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      boardBuild.value = true;
      await onBoardBuilt();
    });

    isLoading.value = false;
  }

  // Template method - subclasses can override
  Future<void> onBoardBuilt() async {}
  @override
  Future<void> initializeServices();


  // Common game logic methods
  List<Token> getTokensAtPosition(Position position) {
    return gameTokens.whereType<Token>().where((token) =>
    token.tokenPosition.row == position.row &&
        token.tokenPosition.column == position.column
    ).toList();
  }

  Offset getTokenOffsetAtPosition(Token token) {
    final tokensAtPosition = getTokensAtPosition(token.tokenPosition);

    if (tokensAtPosition.length <= 1) {
      return Offset.zero;
    }

    final indexInStack = tokensAtPosition.indexWhere((t) => t.id == token.id);
    if (indexInStack == -1) return Offset.zero;

    final baseOffset = 9.0;
    final angle = (indexInStack * (2 * math.pi / 8)) % (2 * math.pi);
    final distance = baseOffset * (1 + indexInStack * 0.3);

    return Offset(
        math.cos(angle) * distance,
        math.sin(angle) * distance
    );
  }

  List<double> getPosition(int row, int column, GlobalKey appBarKey) {
    final cellKey = keyReferences[row][column];
    if (cellKey.currentContext == null) {
      return [0, 0, 0, 0];
    }

    try {
      final RenderBox cellRenderBox = cellKey.currentContext!.findRenderObject() as RenderBox;
      final cellSize = cellRenderBox.size;

      RenderBox? boardBox;
      BuildContext? currentContext = cellKey.currentContext;
      int searchAttempts = 0;

      while (currentContext != null && boardBox == null && searchAttempts < 10) {
        searchAttempts++;

        final renderObject = currentContext.findRenderObject();
        if (renderObject is RenderBox) {
          final size = renderObject.size;
          if (size.width > cellSize.width * 10 && size.height > cellSize.height * 10) {
            boardBox = renderObject;
            break;
          }
        }

        final ancestorState = currentContext.findAncestorStateOfType<State>();
        currentContext = ancestorState?.context;
      }

      if (boardBox != null) {
        try {
          final localPosition = cellRenderBox.localToGlobal(
              Offset.zero,
              ancestor: boardBox
          );

          return [
            localPosition.dx,
            localPosition.dy,
            cellSize.width,
            cellSize.height
          ];
        } catch (e) {
          debugPrint('Error calculating local position: $e');
        }
      }

      final globalPosition = cellRenderBox.localToGlobal(Offset.zero);
      final double appBarHeight = appBarKey.currentContext != null
          ? (appBarKey.currentContext!.findRenderObject() as RenderBox).size.height
          : 0.0;

      return [
        globalPosition.dx,
        globalPosition.dy - appBarHeight,
        cellSize.width,
        cellSize.height
      ];
    } catch (e) {
      debugPrint('Error in getPosition: $e');
      return [0, 0, 0, 0];
    }
  }

  bool getMovableTokens(TokenType type, int diceValue) {
    return gameService.getMovableTokens(type, diceValue);
  }

  bool checkForInitialTokens(TokenType type) {
    return gameService.hasInitialToken(type);
  }

  bool hasEnoughSpaceToMove(Token token, int diceValue) {
    return token.positionInPath + diceValue <= 56;
  }

  Future<void> updateReachedHome(Token token) async {
    final index = players.indexWhere((e) => e.tokenType == token.type);
    if (index != -1) {
      final player = players[index];
      final newReachedHome = player.reachedHome + 1;
      final hasFinished = newReachedHome >= 4;

      players[index] = player.copyWith(
        reachedHome: newReachedHome,
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

  void showGameOverDialog() {
    Get.dialog(
      GameOverDialog(
        players: players,
        isTeamPlay: isTeamPlay.value,
        onPlayAgain: () {
          Get.back();
          // Reset game function here
        },
        onExit: () {
          Get.back();
          Get.back();
        },
      ),
      barrierDismissible: false,
    );
  }
}