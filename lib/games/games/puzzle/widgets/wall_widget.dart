import 'package:flutter/material.dart';
import '../../controller/wall_blast_controller.dart';
import '../models/wall_blast_model.dart';

class WallWidget extends StatelessWidget {
  final WallBlastModel block;
  final WallBlastController controller;

  const WallWidget({
    super.key,
    required this.block,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.selectBlock(block),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: block.isMatched ? Colors.grey.withAlpha((0.5 * 255).toInt()) : block.color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: controller.selectedBlock.value == block
                ? Colors.white
                : Colors.black12,
            width: controller.selectedBlock.value == block ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).toInt()),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}