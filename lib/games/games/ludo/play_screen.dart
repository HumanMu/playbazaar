import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../functions/dialog_manager.dart';
import '../../../global_widgets/dialog/show_error_dialog_utils.dart';
import 'helper/enums.dart';
import 'locator/service_locator.dart';
import 'models/ludo_creattion_params.dart';
import 'widgets/game_play.dart';

class LudoPlayScreen extends ConsumerStatefulWidget {
  final GameMode gameMode;
  final int numberOfPlayer;
  final bool enabledRobots;
  final bool teamPlay;
  final bool isHost;
  final String? gameCode;

  const LudoPlayScreen({
    super.key,
    required this.gameMode,
    required this.numberOfPlayer,
    required this.enabledRobots,
    required this.teamPlay,
    required this.isHost,
    this.gameCode
  });

  @override
  ConsumerState<LudoPlayScreen> createState() => _LudoPlayScreenState();
}

class _LudoPlayScreenState extends ConsumerState<LudoPlayScreen> {
  final GlobalKey keyBar = GlobalKey();
  bool isLoading = false;

  @override
  void initState(){
    super.initState();
    setState(() {
      isLoading = true;
    });
    initializeServices();
  }

  Future<void> initializeServices() async {
    try {
      LudoCreationParamsModel params = LudoCreationParamsModel(
          numberOfPlayers: widget.numberOfPlayer,
          teamPlay: widget.teamPlay,
          enableRobots: widget.enabledRobots,
          gameCode: widget.gameCode,
          isHost: widget.isHost
      );

      final dialogManager = ref.read(dialogManagerProvider.notifier);
      await LudoServiceLocator.cleanup();
      await LudoServiceLocator.initialize(
          widget.gameMode,
          params,
          dialogManager: dialogManager
      );

      await LudoServiceLocator.initializeGame(params);

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Game initialization failed: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        DialogUtils.showErrorDialog(context, 'Failed to initialize game: $e');
      }
    }
  }

  @override
  void dispose() {
    LudoServiceLocator.cleanup();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        key: keyBar,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              context.go('/ludoHome');
            },
            icon: const Icon(
                Icons.arrow_back,
                color: Colors.white
            ),
        ),
        title: Text(
          "ludo_missions".tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Center(
          child: isLoading
            ? CircularProgressIndicator()
            : GamePlay(keyBar),

      ),
    );
  }

}
