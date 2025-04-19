import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import 'controller/dice_controller.dart';
import 'controller/game_controller.dart';
import 'services/game_service.dart';
import 'widgets/dice_widget.dart';
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
    final numberPlayer2Build = widget.enabledRobots? 4 : widget.numberOfPlayer;
    await Get.putAsync(() => GameService().init(numberPlayer2Build));
    Get.put(GameController());
    Get.put(DiceController());

    // Now we can set loading to false
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    Get.delete<GameController>(force: true);
    Get.delete<DiceController>(force: true);
    Get.delete<GameService>(force: true);
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
              if (Get.previousRoute == '/ludoLobby') {
                Get.back();
              } else {
                Get.offNamed('/ludoLobby');
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
      body: Container(
        child: isLoading
          ? CircularProgressIndicator()
          : GamePlay(keyBar),
      ),
      bottomNavigationBar: isLoading
        ? null
        : BottomAppBar(
            color: AppColors.primary,
            shape: const CircularNotchedRectangle(),
            elevation: 8,
            notchMargin: 8,
            child: Container(height: 50.0),
          ),
      floatingActionButton: isLoading
        ? null
        : Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withValues(alpha: 0.5),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
            child: const ModernDiceWidget(),
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

}
