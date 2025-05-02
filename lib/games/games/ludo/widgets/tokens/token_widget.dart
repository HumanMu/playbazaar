import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/ludo/helper/functions.dart';
import 'package:playbazaar/games/games/ludo/widgets/animated_token.dart';
import '../../controller/game_controller.dart';
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
    final gameController = Get.find<GameController>();
    final offset = gameController.getTokenOffsetAtPosition(token);

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