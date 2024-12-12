import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/puzzle/widgets/grid_widget.dart';

import '../controller/wall_blast_controller.dart';


class WallBlastPlayPage extends StatelessWidget {
  final WallBlastController controller = Get.put(WallBlastController());

  WallBlastPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Block Blast'),
        actions: [
          Obx(() => Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Score: ${controller.score.value} | High Score: ${controller.highScore.value}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          )),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridWidget(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => controller.initializeGame(),
              child: const Text('Reset Game'),
            ),
          ),
        ],
      ),
    );
  }
}