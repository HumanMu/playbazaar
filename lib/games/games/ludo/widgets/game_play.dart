import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/ludo/widgets/token_widget.dart';
import '../controller/game_controller.dart';
import '../models/token.dart';
import './board.dart';

class GamePlay extends StatefulWidget {
  final GlobalKey keyBar;

  const GamePlay(this.keyBar, {super.key});

  @override
  State<GamePlay> createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  bool boardBuilt = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        boardBuilt = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<GameController>();

    return Obx(() {
      final tokens = gameController.gameTokens.whereType<Token>().toList();

      return Directionality(
        textDirection: TextDirection.ltr,  // Force LTR layout
        child: Stack(
          children: [
            Board(gameController.keyReferences),
            if (boardBuilt) // Only show tokens after board is built
              ...tokens.map((token) =>
                  TokenWidget(
                    token: token,
                    dimensions: gameController.getPosition(
                      token.tokenPosition.row,
                      token.tokenPosition.column,
                      widget.keyBar,
                    ),
                  )),
          ],
        ),
      );
    });
  }
}