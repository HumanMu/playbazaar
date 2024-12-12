import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/puzzle/widgets/wall_widget.dart';

import '../../controller/wall_blast_controller.dart';

class GridWidget extends StatelessWidget {
  final WallBlastController controller = Get.find();

  GridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: WallBlastController.gridSize,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: controller.blocks.length,
      itemBuilder: (context, index) {
        final block = controller.blocks[index];
        return WallWidget(
          block: block,
          controller: controller,
        );
      },
    ));
  }
}