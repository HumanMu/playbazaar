import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:playbazaar/games/games/word_connector/controller/connector_play_controller.dart';
import 'package:playbazaar/games/games/word_connector/widgets/letter_circle.dart';
import 'package:playbazaar/games/games/word_connector/widgets/word_connector_grid.dart';

import '../../../admob/banner/adaptive_banner_ad.dart';


class WordConnectorPlayScreen extends StatelessWidget {
  const WordConnectorPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConnectorPlayController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => context.go('/wordConnectorSettingScreen'),
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            //color: Colors.blueGrey.shade100.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "wordconnector".tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                color: Colors.blueGrey.shade50,
                child: AdaptiveBannerAd(
                  onAdLoaded: (isLoaded) {
                    debugPrint(isLoaded
                        ? 'Ad loaded in Quiz Screen'
                        : 'Ad failed to load in Quiz Screen'
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blueGrey.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'level'.tr,
                          style: TextStyle(
                            color: Colors.blueGrey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(controller.gameState.value.level.toString(),
                          style: TextStyle(
                            color: Colors.blueGrey.shade900,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.blueGrey.shade200,
                    ),
                    Obx(() => Column(
                      children: [
                        Text(
                          'score'.tr,
                          style: TextStyle(
                            color: Colors.blueGrey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(controller.gameState.value.points.toString(),
                          style: TextStyle(
                            color: Colors.blueGrey.shade900,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )
                        ),
                      ],
                    )),
                  ],
                ),
              ),

              // Word Grid Section
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.shade100.withValues(alpha: 0.5),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: WordConnectorGrid(),
                  ),
                ),
              ),

              // Letter Circle Section
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.shade100.withValues(alpha: 0.5),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: LetterCircle(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
