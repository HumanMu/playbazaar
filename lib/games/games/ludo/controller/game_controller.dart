import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:playbazaar/games/games/ludo/helper/functions.dart';
import 'package:playbazaar/games/games/ludo/models/dice_model.dart';
import 'package:playbazaar/games/games/ludo/models/ludo_player.dart';
import '../helper/enums.dart';
import '../models/position.dart';
import '../services/game_service.dart';
import '../models/token.dart';
import 'dice_controller.dart';

class GameController extends GetxController {
  final DiceModel diceModel = DiceModel();
  final List<List<GlobalKey>> keyReferences = LudoHelper.getGlobalKeys();
  final GameService gameService = Get.find<GameService>();
  List<Token?> get gameTokens => gameService.gameTokens;
  RxList<LudoPlayer> players = <LudoPlayer>[].obs;
  final RxBool wasLastToken = RxBool(false);
  final RxBool boardBuild = RxBool(false);
  final RxBool isTeamPlay = RxBool(false);
  final RxBool isLoading = RxBool(false);
  final RxBool isRobotOn = RxBool(false);
  final RxInt numberOfHumanPlayers = RxInt(4);



  @override
  void onInit() async{
    isLoading.value = true;
    super.onInit();

    await _initializeServices();
    await _initializePlayers();

    // Add post frame callback to set boardBuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      boardBuild.value = true;
      initializeGameState(); // to update after DiceController is created
    });

    isLoading.value = false;
  }

  void initializeGameState() {
    final diceController = Get.find<DiceController>();
    diceController.initializeFirstPlayer(players);
  }


  Future<void> _initializeServices() async {
    if (Get.arguments != null) {
      numberOfHumanPlayers.value = Get.arguments['numberOfPlayer'] ?? 4;
      isRobotOn.value = Get.arguments['enabledRobots'] ?? false;
      isTeamPlay.value = Get.arguments['teamPlay'] ?? false;
    }

    final numberOfPlayer = (isTeamPlay.value || isRobotOn.value)? 4 : numberOfHumanPlayers.value;

    gameService.init(numberOfPlayer, teamPlay: isTeamPlay.value);
  }


  List<Token> getTokensAtPosition(Position position) {
    return gameTokens.whereType<Token>().where((token) =>
    token.tokenPosition.row == position.row &&
        token.tokenPosition.column == position.column
    ).toList();
  }



  Future<void> handleTokenTap(Token token) async {
    final diceController = Get.find<DiceController>();

    if (token.tokenState == TokenState.home
        || (token.tokenState == TokenState.initial && diceController.diceValue != 6)
        || !diceController.moveState
        || token.type != diceController.diceColor) {
      return;
    }

    if (!_hasEnoughSpaceToMove(token, diceController.diceValue)) {
      return;
    }

    diceController.setMoveState(false);
    diceController.setDiceState(false);

    await moveToken(token, diceController);
    bool giveAnotherTurn = diceController.giveAnotherTurn;

    if ( !giveAnotherTurn || wasLastToken.value ) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        diceController.nextPlayer();
      });

    } else if (giveAnotherTurn) {
      diceController.dice.giveAnotherTurn = false;
      final currentPlayerIndex = players.indexWhere((p) => p.tokenType == diceController.diceColor);

      if (currentPlayerIndex >= 0 && players[currentPlayerIndex].isRobot == true && isRobotOn.value) {
        await Future.delayed(const Duration(milliseconds: 800), () {
          diceController.playRobotTurn();
        });
      }
      else{
        diceController.setDiceState(true);
      }
    }
  }


  Future<void> moveToken(Token token, DiceController controller) async { // int diceValue
    final didKill = await gameService.moveToken(token, controller.diceValue);

    bool hasReached = token.positionInPath + controller.diceValue == 56;
    if(hasReached){
      updateReachedHome(token);
      final isOver = checkForGameOver();
      if(isOver){

      }
    }
    controller.dice.giveAnotherTurn = didKill || hasReached || (controller.diceValue == 6);
  }


  void updateReachedHome(Token token) {
    final index = players.indexWhere((e) => e.tokenType == token.type);
    if (index != -1) {
      final player = players[index];
      final newReachedHome = player.reachedHome + 1;
      final hasFinished = newReachedHome >= 4;

      // Update player with copyWith for immutability
      players[index] = player.copyWith(
        reachedHome: newReachedHome,
        hasFinished: hasFinished,
      );

      wasLastToken.value = players[index].hasFinished;

      // Update team progress if in team play mode
      if (isTeamPlay.value && player.teamId != null) {
        updateTeamProgress(player.teamId!);
      }

      // Check game over condition
      final isGameOver = checkForGameOver();
      if (isGameOver) {
        debugPrint('Game over! ${isTeamPlay.value ? "Team ${player.teamId}" : player.name} wins!');
        // Trigger game over UI or logic
      }
    }
  }


  Future<void> _initializePlayers() async{
    players.clear();

    // Create a map to store which colors should be robots
    Map<TokenType, bool> isRobot = {
      TokenType.red: false,
      TokenType.green: false,
      TokenType.yellow: false,
      TokenType.blue: false,
    };

    List<TokenType> tokensToUse = [];

    if (isRobotOn.value) {
      tokensToUse = [TokenType.red, TokenType.green, TokenType.yellow, TokenType.blue];

      switch (numberOfHumanPlayers.value) {
        case 1:
        // Red is human, rest are robots
          isRobot[TokenType.green] = true;
          isRobot[TokenType.yellow] = true;
          isRobot[TokenType.blue] = true;
          break;
        case 2:
          isRobot[TokenType.green] = true;
          isRobot[TokenType.blue] = true;
          break;
        case 3:
          isRobot[TokenType.yellow] = true;
          break;
      // All human for case 4
      }
    } else {
      switch (numberOfHumanPlayers.value) {
        case 1: tokensToUse = [TokenType.red]; break;
        case 2: tokensToUse = [TokenType.red, TokenType.yellow]; break;
        case 3: tokensToUse = [TokenType.red, TokenType.green, TokenType.blue]; break;
        case 4: tokensToUse = [TokenType.red, TokenType.green, TokenType.yellow, TokenType.blue]; break;
      }
    }

    // Assign team IDs if team play is enabled
    Map<TokenType, int> teamAssignments = {};
    if (isTeamPlay.value) {
      teamAssignments = {
        TokenType.red: 1,
        TokenType.yellow: 1,
        TokenType.green: 2,
        TokenType.blue: 2,
      };
    }

    // Create all necessary players
    for (var tokenType in tokensToUse) {
      String colorName = tokenType.toString().split('.').last;
      String name = "${colorName[0].toUpperCase()}${colorName.substring(1).toLowerCase()} Player";

      // Add team name if team play is enabled
      if (isTeamPlay.value && teamAssignments.containsKey(tokenType)) {
        int teamId = teamAssignments[tokenType]!;

        players.add(LudoPlayer(
          tokenType: tokenType,
          name: name,
          isRobot: isRobot[tokenType] ?? false,
          teamId: teamId,
        ));
      } else {
        players.add(LudoPlayer(
          tokenType: tokenType,
          name: name,
          isRobot: isRobot[tokenType] ?? false,
        ));
      }
    }


    // Set team assignments in game service
    if (isTeamPlay.value) {
      Map<TokenType, int?> teamAssignments = {};
      for (var player in players) {
        teamAssignments[player.tokenType] = player.teamId;
      }
      gameService.setTeamAssignments(teamAssignments);
    }
  }




  Offset getTokenOffsetAtPosition(Token token) {
    final tokensAtSamePosition = getTokensAtPosition(token.tokenPosition);

    // If only one token at this position
    if (tokensAtSamePosition.length <= 1) {
      return Offset.zero;
    }

    // Find other tokens in this x position
    final indexInStack = tokensAtSamePosition.indexWhere((t) => t.id == token.id);
    if (indexInStack == -1) return Offset.zero; // Safety check

    // This creates a diagonal pattern where tokens are slightly shifted
    final offsetX = indexInStack * 6.5;
    final offsetY = indexInStack * 6.5;

    return Offset(offsetX, offsetY);
  }

  List<double> getPosition(int row, int column, GlobalKey keyBar) {
    final cellBoxKey = keyReferences[row][column];
    if (cellBoxKey.currentContext == null) {
      return [0, 0, 0, 0];
    }

    final RenderBox renderBoxBar = keyBar.currentContext!.findRenderObject() as RenderBox;
    final sizeBar = renderBoxBar.size;
    final RenderBox renderBoxCell = cellBoxKey.currentContext!.findRenderObject() as RenderBox;
    final positionCell = renderBoxCell.localToGlobal(Offset.zero);

    final double x = positionCell.dx + 1;
    final double y = positionCell.dy - sizeBar.height + 1;
    final double w = renderBoxCell.size.width - 1;
    final double h = renderBoxCell.size.height - 1;

    return [x, y, w, h];
  }


  bool checkForGameOver() {
    if (!isTeamPlay.value) {
      return players.where((player) => player.hasFinished == true).length == 1;
    } else {
      // Team play logic - check if any team has all their tokens home
      Map<int, int> teamMemberCount = {};
      Map<int, int> teamFinishedCount = {};

      // Count total members and finished members for each team
      for (var player in players) {
        if (player.teamId != null) {
          teamMemberCount[player.teamId!] = (teamMemberCount[player.teamId!] ?? 0) + 1;
          if (player.hasFinished) {
            teamFinishedCount[player.teamId!] = (teamFinishedCount[player.teamId!] ?? 0) + 1;
          }
        }
      }

      // Check if any team has all members finished
      for (var teamId in teamMemberCount.keys) {
        if (teamFinishedCount[teamId] == teamMemberCount[teamId]) {
          return true;
        }
      }

      return false;
    }
  }

  bool getMovableTokens(TokenType type, int diceValue) {
    return gameService.getMovableTokens(type, diceValue);
  }

  bool checkForInitialTokens(TokenType type) {
    return gameService.hasInitialToken(type);
  }

  bool _hasEnoughSpaceToMove (Token token, int diceValue) {
    return token.positionInPath + diceValue <= 56;
  }

  void updateTeamProgress(int teamId) {
    // Get completed tokens count for this team
    int totalHomeTokens = 0;
    int totalTeamTokens = 0;

    for (var player in players.where((p) => p.teamId == teamId)) {
      totalHomeTokens += player.reachedHome;
      totalTeamTokens += 4; // Each player has 4 tokens
    }

    // Calculate percentage complete
    double progressPercentage = totalTeamTokens > 0
        ? (totalHomeTokens / totalTeamTokens) * 100
        : 0;

    debugPrint('Team $teamId progress: $totalHomeTokens/$totalTeamTokens tokens (${progressPercentage.toStringAsFixed(1)}%)');

    // You could update UI with team progress here
  }

}