import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/ludo/controller/base_ludo_controller.dart';
import 'package:playbazaar/games/games/ludo/controller/dice_controller.dart';
import 'package:playbazaar/games/games/ludo/helper/functions.dart';
import 'package:playbazaar/games/games/ludo/services/base_ludo_service.dart';
import 'package:playbazaar/games/games/ludo/widgets/animated_token.dart';
import '../../models/token.dart';

class TokenWidget extends StatelessWidget {
  final Token token;
  final List<double> dimensions;

  const TokenWidget({
    super.key,
    required this.token,
    required this.dimensions,
  });

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<BaseLudoController>();
    final gameSerivce = Get.find<BaseLudoService>();
    final offset = gameSerivce.getTokenOffsetAtPosition(token);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      left: dimensions[0] + offset.dx + (dimensions[2] * 0.1), // Add 10% padding for centering
      top: dimensions[1] + offset.dy + (dimensions[3] * 0.1),
      width: dimensions[2] * 0.9,  // Reduce size by 10% to account for centering
      height: dimensions[3] * 0.9,
      child: InkWell(
        onTap: () {
          if(gameController.diceController.color != token.type) {
            return;
          }
          gameController.printMessage("Tapped dice: ${gameController.diceController.color}");
          gameController.printMessage("Tapped token: ${token.type}");
          gameController.handleTokenTap(token);
        },
        borderRadius: BorderRadius.circular((dimensions[2] * 0.8) / 2),
        child: Card(
            elevation: 5,
            margin: EdgeInsets.all(2.5),
            child: AnimatedLudoToken(tokenColor: LudoHelper.getTokenColor(token.type))
        ),
      ),
    );

  }
}

class TokenWidget2 extends StatelessWidget {
  final Token token;
  final List<double> dimensions;

  const TokenWidget2({
    super.key,
    required this.token,
    required this.dimensions,
  });


  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<BaseLudoController>();
    final gameService = Get.find<BaseLudoService>();
    final offset = gameService.getTokenOffsetAtPosition(token);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
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
