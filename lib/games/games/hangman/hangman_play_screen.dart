import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../constants/alphabets.dart';
import '../../../emojies/tear_drop_with_sound.dart';
import '../controller/hangman_controller.dart';
import 'animated_hangman_painter.dart';
import 'dart:math' as math;

class HangmanPlayScreen extends StatefulWidget {
  const HangmanPlayScreen({super.key});

  @override
  State<HangmanPlayScreen> createState() => _HangmanPlayScreenState();
}

class _HangmanPlayScreenState extends State<HangmanPlayScreen> with SingleTickerProviderStateMixin {
  final HangmanController controller = Get.put(HangmanController());
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
      textDirection: controller.isPersian.value ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text('hangman'.tr, style: TextStyle(color: Colors.white)),
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
                  final alphabet = controller.isPersian.value
                      ? Alphabets.persian
                      : Alphabets.english;
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
                              child: Text(
                                controller.buildHiddenWord(),
                                style: TextStyle(fontSize: 30,
                                  color: controller.gameWon.value? Colors.amber : Colors.black,
                                  fontWeight: controller.gameWon.value? FontWeight.bold : FontWeight.normal,
                                )
                              ),
                            ),
                        ) : Container(),

                      !controller.gameLost.value && !controller.gameWon.value
                        ? SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              ' ${"incorrect_guess".tr} ${controller.incorrectGuesses}/${controller.maxIncorrectGuesses}'
                            ),
                          ))
                        : Container(),

                      // Keyboard Buttons
                      SizedBox(
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
                    ? Center(
                      child:Column(
                        children: [
                          GameOverCryingEmoji(),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("The word was: ",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red
                                ),
                              ),
                              Text(controller.wordToGuess.value,
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red
                                ),
                              )
                            ],
                          ),
                        ],
                      ))
                    : Container()
                  ),

                  // New Game Button
                  Obx(() => controller.gameWon.value || controller.gameLost.value?
                    Center(
                      child: ElevatedButton(
                        onPressed: controller.startNewGame,
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