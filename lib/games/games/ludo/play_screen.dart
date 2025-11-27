import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dialog/dialog_listner.dart';
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
        body: Container(
          width: double.infinity,
          height: double.infinity,

          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/games/ludo/ludo_play_screen_bg1.jpg'),
              fit: BoxFit.cover,
            ),
          ),

          child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : GamePlay(keyBar),
          ),
        ),
    );
  }

}
