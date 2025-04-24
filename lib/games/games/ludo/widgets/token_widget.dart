import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/ludo/helper/functions.dart';
import 'package:playbazaar/games/games/ludo/widgets/animated_token.dart';
import '../controller/game_controller.dart';
import '../models/token.dart';



class TokenWidget extends StatelessWidget {
  final Token token;
  final List<double> dimensions;

  const TokenWidget({
    super.key,
    required this.token,
    required this.dimensions,
  });

  // In your TokenWidget's build method
  /*@override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();

    // Calculate offset based on token index at this position
    final offset = gameController.getTokenOffsetAtPosition(token);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      // Add offset to position tokens slightly apart from each other
      left: dimensions[0] + offset.dx,
      top: dimensions[1] + offset.dy,
      width: dimensions[2],
      height: dimensions[3],
      child: Container( // Add container with color to see positioning
        color: Colors.red.withValues(alpha: 0.3), // Semi-transparent to see the underlying board
        child: InkWell(
          onTap: () => gameController.handleTokenTap(token),
          borderRadius: BorderRadius.circular(dimensions[2] / 2),
          child: Card(
              elevation: 5,
              margin: EdgeInsets.all(2.5),
              child: AnimatedLudoToken(tokenColor: LudoHelper.getTokenColor(token.type))
          ),
        ),
      ),
    );
  }*/


  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();

    // Calculate offset based on token index at this position
    final offset = gameController.getTokenOffsetAtPosition(token);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      // Add offset to position tokens slightly apart from each other
      left: dimensions[0] + offset.dx,
      top: dimensions[1] + offset.dy,
      width: dimensions[2],
      height: dimensions[3],
      child: InkWell(
        onTap: () => gameController.handleTokenTap(token),
        borderRadius: BorderRadius.circular(dimensions[2] / 2),
        child: Card(
          elevation: 5,
          margin: EdgeInsets.all(2.5),
          child: AnimatedLudoToken(tokenColor: LudoHelper.getTokenColor(token.type))
        ),
      ),
    );
  }
}