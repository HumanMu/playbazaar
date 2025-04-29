/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/dice_controller.dart';
import '../constants/token_constants.dart';

 class DiceWidget extends StatelessWidget {
  const DiceWidget({super.key});

  String _splitByPoint(TokenType tokenType) {
    switch (tokenType) {
      case TokenType.green:
        return "green";
      case TokenType.yellow:
        return "yellow";
      case TokenType.blue:
        return "blue";
      case TokenType.red:
        return "red";
    }
  }

  Image _diceImagePathFinder(int diceNumber, TokenType diceColor) {
    String color = _splitByPoint(diceColor);
    String dicePath = "assets/games/ludo/dice/$color/$diceNumber.png";

    return Image.asset(
      dicePath,
      gaplessPlayback: true,
      fit: BoxFit.fill,
    );
  }

  @override
  Widget build(BuildContext context) {
    final diceController = Get.find<DiceController>();

    return Obx(() {
      final diceNumber = diceController.diceValue;
      final diceColor = diceController.diceColor;
      final img = _diceImagePathFinder(diceNumber, diceColor);

      return Card(
        elevation: 10,
        child: SizedBox(
          height: 40,
          width: 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => diceController.rollDice(),
                      child: img,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
*/
