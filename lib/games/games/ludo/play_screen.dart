import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/orientation_manager.dart';
import '../../../constants/app_colors.dart';
import 'controller/base_play_controller.dart';
import 'controller/dice_controller.dart';
import 'controller/offline_ludo_controller.dart';
import 'services/game_service.dart';
import 'widgets/game_play.dart';

class LudoPlayScreen extends StatefulWidget {
  final int numberOfPlayer;
  final bool enabledRobots;
  final bool teamPlay;

  const LudoPlayScreen({
    super.key,
    required this.numberOfPlayer,
    required this.enabledRobots,
    required this.teamPlay
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
    Get.lazyPut(() => GameService());
    final controller = OfflineLudoController();
    Get.lazyPut<BaseLudoController>(() => controller);
    Get.lazyPut<OfflineLudoController>(() => controller);
    Get.lazyPut(() => DiceController());

    // Now we can set loading to false
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    Get.delete<OfflineLudoController>(force: true);
    Get.delete<DiceController>(force: true);
    Get.delete<GameService>(force: true);
    OrientationManager.resetOrientations();

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
