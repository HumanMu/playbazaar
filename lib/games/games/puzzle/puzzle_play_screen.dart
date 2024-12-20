import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/wall_puzzle_controller.dart';
import 'models/puzzle_shapes.dart';

class WallPuzzelScreen extends StatelessWidget {
  final WallPuzzleController controller = Get.put(WallPuzzleController());
  WallPuzzelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Score: ${controller.score}')),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: buildBoard(),
          ),
          Expanded(
            flex: 1,
            child: buildPieceSelector(),
          ),
        ],
      ),
    );
  }

  Widget buildBoard() {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: WallPuzzleController.boardWidth,
      ),
      itemCount: WallPuzzleController.boardWidth * WallPuzzleController.boardHeight,
      itemBuilder: (context, index) {
        int row = index ~/ WallPuzzleController.boardWidth;
        int col = index % WallPuzzleController.boardWidth;

        return Obx(() {
          Color? cellColor = controller.board[row][col];
          return DragTarget<PuzzleShapes>(
            onWillAcceptWithDetails: (details) =>
                controller.canPlacePiece(details.data, row, col),
            onAcceptWithDetails: (details) {
              controller.placePiece(details.data, row, col);
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                decoration: BoxDecoration(
                  color: cellColor ?? Colors.grey[300],
                  border: Border.all(color: Colors.grey[700]!),
                ),
              );
            },
          );
        });
      },
    );
  }

  Widget buildPieceSelector() {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: controller.currentPieces.map((piece) {
        return Draggable<PuzzleShapes>(
          data: piece,
          childWhenDragging: Container(),
          feedback: buildPiecePreview(piece),
          child: buildPiecePreview(piece),
        );
      }).toList(),
    ));
  }

  Widget buildPiecePreview(PuzzleShapes piece) {
    return SizedBox(
      width: 60,
      height: 60,
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: piece.width,
        ),
        itemCount: piece.width * piece.height,
        itemBuilder: (context, index) {
          int row = index ~/ piece.width;
          int col = index % piece.width;
          return Container(
            decoration: BoxDecoration(
              color: piece.matrix[row][col] ? piece.color : Colors.transparent,
              border: piece.matrix[row][col]
                  ? Border.all(color: Colors.black)
                  : null,
            ),
          );
        },
      ),
    );
  }
}