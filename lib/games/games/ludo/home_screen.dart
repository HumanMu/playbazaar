import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:playbazaar/constants/app_colors.dart';
import 'package:playbazaar/constants/app_dialog_ids.dart';
import '../../../core/dialog/dialog_listner.dart';
import '../../../functions/generate_strings.dart';
import '../../../global_widgets/dialog/accept_dialog.dart';
import 'helper/enums.dart';
import 'helper/utility_color.dart';
import 'widgets/online_game_creation_dialog.dart';

class LudoHomeScreen extends ConsumerStatefulWidget {
  const LudoHomeScreen({super.key});
  @override
  ConsumerState<LudoHomeScreen> createState() => _LudoHomeScreenState();
}

class _LudoHomeScreenState extends ConsumerState<LudoHomeScreen> {
  GlobalKey keyBar = GlobalKey();
  bool enabledRobots = false;
  bool teamPlay = false;

  // Game configuration constants
  static const int computerMode = 1;
  static const int fourPlayerMode = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LudoColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        key: keyBar,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.go('/mainGames');
          },
          icon: const Icon(
              Icons.arrow_back,
              color: Colors.white
          ),
        ),
        title: Text(
          'ludo_missions'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _buildBody(),
      )
    );
  }

  Widget _buildBody() {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 700),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          _buildLudoLogo(),
          const SizedBox(height: 30),
          Text(
            'choose_player_numbers'.tr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: LudoColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingsToggleRow(),
          _buildGameOptionsGrid(),
        ],
      ),
    );
  }

  Widget _buildLudoLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 10,
          )
        ],
      ),
      child: ClipOval(
        child: Stack(
          children: [
            _buildQuadrant(Alignment.topLeft, LudoColors.red),
            _buildQuadrant(Alignment.topRight, LudoColors.green),
            _buildQuadrant(Alignment.bottomLeft, LudoColors.yellow),
            _buildQuadrant(Alignment.bottomRight, LudoColors.blue),
            _buildGuideButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideButton() {
    return Center(
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 4),
              blurRadius: 10,
              spreadRadius: 7
            ),
          ]
        ),
        child: Center(
          child: GestureDetector(
            onTap: () => acceptDialog(
                context,
                'ludo_home_screen_guide_title'.tr,
                'ludo_home_screen_guide'.tr
            ),
            child: Text(
              'guide'.tr,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsToggleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSettingsToggle(
          value: enabledRobots,
          label: "enable_robots".tr,
          onChanged: (val) => setState(() => enabledRobots = val!),
        ),
        _buildSettingsToggle(
          value: teamPlay,
          label: "play_in_team".tr,
          onChanged: (val) => setState(() => teamPlay = val!),
        ),
      ],
    );
  }

  Widget _buildSettingsToggle({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return Expanded(
      child: Row(
        children: [
          Transform.scale(
            scale: 1.5,
            child: CupertinoCheckbox(
              value: value,
              onChanged: onChanged,
            ),
          ),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOptionsGrid() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _buildGameTypeContainer(10, Colors.orangeAccent, GameMode.online),
          _buildGameTypeContainer(1, LudoColors.yellow, GameMode.offline),
          _buildGameTypeContainer(2, LudoColors.red, GameMode.offline),
          _buildGameTypeContainer(3, LudoColors.green, GameMode.offline),
          _buildGameTypeContainer(4, LudoColors.blue, GameMode.offline),
          /*ElevatedButton(onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TestTokens()));
            },
              child: Text("Test tokens")
            ),
           */
        ],
      ),
    );
  }

  // Reusable quadrant widget
  Widget _buildQuadrant(Alignment alignment, Color color) {
    double? top = alignment.y < 0 ? 0 : null;
    double? bottom = alignment.y > 0 ? 0 : null;
    double? left = alignment.x < 0 ? 0 : null;
    double? right = alignment.x > 0 ? 0 : null;

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 60,
        height: 60,
        color: color,
      ),
    );
  }

  void _handleGameSelection(int playerCount, GameMode mode) {
    if(mode == GameMode.online){
      final dialogManager = ref.read(dialogManagerProvider.notifier);
      final String gameCode = generateStrings(6);

      dialogManager.showDialog(
          dialog: OnlineGameOptionsDialog(
            title: 'compete_online'.tr,
            joinButtonText: 'join_with_code'.tr,
            createButtonText: 'btn_start'.tr,
            codeHint: 'game_code'.tr,
            gameCode: gameCode,
            onJoinGame: (String code){
              dialogManager.closeDialog(AppDialogIds.ludoOnlineGameCreation);
              _navigateToPlayScreen(4, mode, false, code);
            },
            onCreateGame: (){
              dialogManager.closeDialog(AppDialogIds.ludoOnlineGameCreation);
              _navigateToPlayScreen(4, mode, true, gameCode);
            },
            onCancel: () {
              dialogManager.closeDialog(AppDialogIds.ludoOnlineGameCreation);
            },
          ),
        barrierDismissible: false,
        routeSettings: RouteSettings(
            name: AppDialogIds.ludoOnlineGameCreation
        ),
      );

      return;
    }

    if ((playerCount == 2 || playerCount == 3) && teamPlay && !enabledRobots) {
      debugPrint("Game start: mumber player: $playerCount - robot: $enabledRobots");
      acceptDialog(
        context,
          'ludo_home_screen_guide_title'.tr,
          'ludo_game_start_guide'.tr
      );
      return;
    }

    bool updatedRobots = enabledRobots;

    // Computer mode (1 player) -> enable robots
    if (playerCount == computerMode && !enabledRobots) {
      updatedRobots = true;
    }

    // 4-player mode -> disable robots
    else if (playerCount == fourPlayerMode && enabledRobots) {
      updatedRobots = false;
    }

    // Apply robot setting changes if needed
    if (updatedRobots != enabledRobots) {
      setState(() {
        enabledRobots = updatedRobots;
      });
    }

    // Navigate to game screen
    _navigateToPlayScreen(playerCount, mode, false, "");
  }

  void _navigateToPlayScreen(
      int playerCount,
      GameMode gameMode,
      bool isHost,
      String? gameCode
    ){
    final queryData = Uri(queryParameters: {
      'gameMode': gameMode.name,
      'isHost': isHost.toString(),
      'gameCode': gameCode,
      'numberOfPlayer': playerCount.toString(),
      'teamPlay': teamPlay.toString(),
      'enabledRobots': enabledRobots.toString(),
    }).query;

    context.push('/ludoPlayScreen?$queryData');
  }


  Widget _buildGameTypeContainer(int playerCount, Color color, GameMode mode) {
    return GestureDetector(
      onTap: () => _handleGameSelection(playerCount, mode),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                playerCount == computerMode
                    ? Icons.computer
                    : playerCount ==10
                      ? Icons.online_prediction
                      : Icons.people,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              playerCount != computerMode && playerCount != 10
                  ? "$playerCount ${'players'.tr}"
                  : mode == GameMode.online
                    ? "compete_online".tr
                    : "computer".tr,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
