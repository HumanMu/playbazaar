import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../global_widgets/dialog/show_error_dialog_utils.dart';
import 'helper/enums.dart';
import 'locator/service_locator.dart';
import 'widgets/game_play.dart';

class LudoPlayScreen extends StatefulWidget {
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
  State<LudoPlayScreen> createState() => _LudoPlayScreenState();
}

class _LudoPlayScreenState extends State<LudoPlayScreen> {
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
      await LudoServiceLocator.initialize(widget.gameMode);

      await LudoServiceLocator.initializeGame(
        numberOfPlayers: widget.numberOfPlayer,
        teamPlay: widget.teamPlay,
        enableRobots: widget.enabledRobots,
        gameCode: widget.gameCode,
        isHost: widget.isHost
      );

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
      appBar: AppBar(                                     // You can maybe remove this to fix dice positioning
        backgroundColor: AppColors.primary,
        key: keyBar,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              if (Get.previousRoute == '/ludoHome') {
                Get.back();
              } else {
                Get.offNamed('/ludoHome');
              }
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
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
