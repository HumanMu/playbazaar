import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import '../../../emojies/tear_drop_with_sound.dart';
import '../../../global_widgets/accept_dialog.dart';
import 'animated_hangman_painter.dart';
import 'controller/play_controller.dart';

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
          title: Text(
              'hangman'.tr,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold
              )
          ),
          centerTitle: true,
          backgroundColor: Colors.red,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Main game content
                  SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Obx(() {
                          final alphabet = controller.alphabet;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              // Hangman Drawing
                              SizedBox(
                                height: constraints.maxHeight * 0.3,
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
                              if (!controller.gameLost.value)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                                ),

                              // Game status and hints
                              if (!controller.gameLost.value && !controller.gameWon.value)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                          ' ${"incorrect_guess".tr} ${controller.incorrectGuesses}/${controller.maxIncorrectGuesses}'
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (controller.wordHint.value.isNotEmpty)
                                            GestureDetector(
                                              child: Text(
                                                "${'guide'.tr}: 1",
                                                style: const TextStyle(color: Colors.green),
                                              ),
                                              onTap: () => acceptDialog(context, "guide".tr, controller.wordHint.value),
                                            ),
                                          const SizedBox(width: 15),
                                          GestureDetector(
                                            child: Text(
                                              "${'guide'.tr}: 2",
                                              style: const TextStyle(color: Colors.green),
                                            ),
                                            onTap: () => acceptDialog(context, "guide".tr, controller.wordToGuess.value[0]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                              // Keyboard
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 600),
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
                                      child: Text(
                                          letter,
                                          style: const TextStyle(fontSize: 15, color: Colors.white)
                                      ),
                                    )).toList(),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),

                  // Overlay animations
                  Positioned.fill(
                    child: Obx(() => AnimatedOpacity(
                      opacity: (controller.gameWon.value || controller.gameLost.value) ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (controller.gameWon.value)
                            Lottie.asset(
                              'assets/games/hangman/winner_green.json',
                              width: 400,
                              height: 400,
                              fit: BoxFit.contain,
                            ),
                          if (controller.gameLost.value) ...[
                            const GameOverCryingEmoji(),
                            const SizedBox(height: 16),
                            Text(
                              controller.wordToGuess.value,
                              style: const TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red
                              ),
                            ),
                          ],
                          if (controller.gameWon.value || controller.gameLost.value)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: ElevatedButton(
                                onPressed: () => controller.startNextGame(context),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green
                                ),
                                child: Text(
                                    'btn_new_game'.tr,
                                    style: const TextStyle(fontSize: 20, color: Colors.white)
                                ),
                              ),
                            ),
                        ],
                      ),
                    )),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}