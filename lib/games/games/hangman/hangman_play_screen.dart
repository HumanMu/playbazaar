import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:playbazaar/global_widgets/accept_dialog.dart';
import '../../../emojies/tear_drop_with_sound.dart';
import 'controller/play_controller.dart';
import 'animated_hangman_painter.dart';
import 'dart:math' as math;

class HangmanPlayScreen extends StatefulWidget {
  const HangmanPlayScreen({super.key});

  @override
  State<HangmanPlayScreen> createState() => _HangmanPlayScreenState();
}

class _HangmanPlayScreenState extends State<HangmanPlayScreen> with SingleTickerProviderStateMixin {
  final PlayController controller = Get.put(PlayController());
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: controller.isAlphabetRTL.value ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text('hangman'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold
            )
          ),
          centerTitle: true,
          backgroundColor: Colors.red,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Obx(() {
                  final alphabet = controller.alphabet;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      // Hangman Drawing
                      SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                    begin: 0,
                                    end: controller.incorrectGuesses.value.toDouble()
                                ),
                                duration: const Duration(milliseconds: 500),
                                builder: (context, value, _) {
                                  return CustomPaint(
                                    size: const Size(200, 200),
                                    painter: AnimatedHangmanPainter(
                                      progress: value,
                                      incorrectGuesses: controller.incorrectGuesses.value,
                                      isGameOver: controller.gameLost.value,
                                      hasWon: controller.gameWon.value,
                                      swingAngle: _animationController.value * 2 * math.pi,
                                      breatheScale: 1 + (math.sin(_animationController.value * 2 * math.pi) * 0.05),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      // Hidden Word
                      !controller.gameLost.value
                        ? SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Directionality(
                              textDirection: controller.isAlphabetRTL.value ? TextDirection.rtl : TextDirection.ltr,
                              child: Text(
                                controller.buildHiddenWord(),
                                style: TextStyle(
                                  fontSize: 30,
                                  color: controller.gameWon.value ? Colors.amber : Colors.black,
                                  fontWeight: controller.gameWon.value ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ) : Container(),

                      !controller.gameLost.value && !controller.gameWon.value
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: Text(
                                      ' ${"incorrect_guess".tr} ${controller.incorrectGuesses}/${controller.maxIncorrectGuesses}'
                                  ),
                                )
                            ),
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  controller.wordHint.value != ""
                                    ? GestureDetector(
                                        child: Text("${'guide'.tr}: 1",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                        onTap: () => acceptDialog(this.context, "guide".tr, controller.wordHint.value),
                                      ) : Container(),
                                  SizedBox(width: 15),
                                  GestureDetector(
                                    child: Text("${'guide'.tr}: 2",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    onTap: () => acceptDialog(this.context, "guide".tr, controller.wordToGuess.value[0]),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                        : Container(),

                      // Keyboard Buttons
                      Container(
                        constraints: BoxConstraints(maxWidth: 600),
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4.0,
                          runSpacing: 3.0,
                          children: alphabet.map((letter) => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red
                            ),
                            onPressed: controller.gameWon.value ||
                                controller.gameLost.value ||
                                controller.guessedLetters.contains(letter)
                                ? null
                                : () => controller.checkGuess(letter),
                            child: Text(letter,
                                style: TextStyle(fontSize: 15, color: Colors.white)
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Lottie animation overlay
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(() => controller.gameWon.value
                    ? Center(
                      child: Lottie.asset(
                        'assets/games/hangman/winner_green.json',
                        width: 400,
                        height: 400,
                        fit: BoxFit.contain,
                      ),
                    ) : Container(),
                  ),
                  Obx(() => controller.gameLost.value
                    ? Column(
                      children: [
                        Center(
                          child: GameOverCryingEmoji(),
                        ),
                         Center(
                          child: Text(controller.wordToGuess.value,
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Colors.red
                            ),
                          )
                         ),
                      ],
                    ) : Container(),

                  ),

                  // New Game Button
                  Obx(() => controller.gameWon.value || controller.gameLost.value?
                    Center(
                      child: ElevatedButton(
                        onPressed: () => controller.startNextGame(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green
                        ),
                        child: Text(
                            'btn_new_game'.tr,
                            style: const TextStyle(fontSize: 20, color: Colors.white)
                        ),
                      )) : Container(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}