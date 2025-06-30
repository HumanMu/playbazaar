import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/connector_play_controller.dart';

import 'letter_circle_painter.dart';

class LetterCircle extends StatefulWidget {
  const LetterCircle({super.key});

  @override
  State<LetterCircle> createState() => LetterCircleState();
}

class LetterCircleState extends State<LetterCircle> {
  final ConnectorPlayController controller = Get.find();
  Offset? currentLineEnd;
  List<LetterCirclePosition> letterPositions = [];

  int? _getLetterIndexAtPosition(Offset position) {
    for (var letterPos in letterPositions) {
      final distance = (position - letterPos.position).distance;
      if (distance < 30) { // Adjust hit test radius as needed
        return letterPos.index;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (details) {
            final index = _getLetterIndexAtPosition(details.localPosition);
            if (index != null) {
              controller.startWordWithIndex(index);
              setState(() {
                currentLineEnd = details.localPosition;
              });
            }
          },
          onPanUpdate: (details) {
            final index = _getLetterIndexAtPosition(details.localPosition);
            if (index != null) {
              controller.addLetterIndex(index);
            }
            setState(() {
              currentLineEnd = details.localPosition;
            });
          },
          onPanEnd: (_) {
            controller.endWord();
            setState(() {
              currentLineEnd = null;
            });
          },
          child: CustomPaint(
            painter: LetterCirclePainter(
              letters: controller.letters,
              selectedIndices: controller.selectedIndices,
              letterPositions: letterPositions,
              currentLineEnd: currentLineEnd,
              //size: Size(constraints.maxWidth, constraints.maxHeight),
            ),
            child: Container(),
          ),
        );
      },
    );
  }
}
