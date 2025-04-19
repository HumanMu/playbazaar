import 'package:flutter/material.dart';
import 'ludo_row.dart';

class Board extends StatelessWidget {
  final List<List<GlobalKey>> keyReferences;

  const Board(this.keyReferences, {super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Card(
          elevation: 10,
          color: Colors.orange,
          child: Directionality(
            textDirection: TextDirection.ltr,  // Force LTR layout
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/games/ludo/ludo_board.png"),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(15, (i) =>
                        RepaintBoundary(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: i == 14 ? const BorderSide(color: Colors.grey) : BorderSide.none,
                              ),
                              color: Colors.transparent,
                            ),
                            child: LudoRow(i, keyReferences[i]),
                          ),
                        ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// Add this in the column
/*Positioned(
              height: 160,
              top: 0, // Adjust position as needed
              left: 0, // Adjust position as needed
              child: Image.asset("assets/images/persianEmpier/persianEmpier.jpeg"), // Replace with your image path
            ),
            Positioned(
              height: 160,
              top: 0, // Adjust position as needed
              right: 0, // Adjust position as needed
              child: Image.asset("assets/images/persianEmpier/persianEmpier.jpeg"), // Replace with your image path
            ),
            Positioned(
              height: 160,
              bottom: 0, // Adjust position as needed
              left: 0, // Adjust position as needed
              child: Image.asset("assets/images/persianEmpier/persianEmpier.jpeg"), // Replace with your image path
            ),
            Positioned(
              height: 160,
              bottom: 0, // Adjust position as needed
              right: 0, // Adjust position as needed
              child: Image.asset("assets/images/persianEmpier/persianEmpier.jpeg"), // Replace with your image path
            ),*/
// Add three more Positioned widgets for the remaining images
