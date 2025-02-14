import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../admob/adaptive_banner_ad.dart';
import 'widgets/animated_hangman_painter.dart';
import 'package:flutter/material.dart';
import 'controller/play_controller.dart';
import '../../../emojies/tear_drop_with_sound.dart';
import '../../../global_widgets/dialog/accept_dialog.dart';
import 'package:playbazaar/games/games/hangman/widgets/animated_keyboard.dart';


class HangmanPlayScreen extends StatefulWidget {
  const HangmanPlayScreen({super.key});

  @override
  State<HangmanPlayScreen> createState() => _HangmanPlayScreenState();
}

class _HangmanPlayScreenState extends State<HangmanPlayScreen> with SingleTickerProviderStateMixin {
  final PlayController _controller = Get.find<PlayController>();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimationController();
  }

  void _initializeAnimationController() {
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
      textDirection: _controller.isAlphabetRTL.value ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _buildAppBar(),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade200,
                Colors.purple.shade300,
              ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      _admobBanner(),
                      _buildHangmanDrawing(constraints),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Obx(() => Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildHiddenWord(),
                                _buildGameStatus(),
                                _buildHintButtons(),
                                _buildKeyboard(),
                              ],
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildGameOverOverlay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () => Get.offNamed('/hangmanPlaySettings'),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: Text(
        'hangman'.tr,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.red,
      elevation: 0,
    );
  }

  Widget _buildHangmanDrawing(BoxConstraints constraints) {
    return SizedBox(
      height: constraints.maxHeight * 0.28,
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: _controller.incorrectGuesses.value.toDouble(),
            ),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, _) => CustomPaint(
              size: const Size(200, 200),
              painter: AnimatedHangmanPainter(
                progress: value,
                incorrectGuesses: _controller.incorrectGuesses.value,
                isGameOver: _controller.gameLost.value,
                hasWon: _controller.gameWon.value,
                swingAngle: _animationController.value * 2 * math.pi,
                breatheScale: 1 + (math.sin(_animationController.value * 2 * math.pi) * 0.05),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameStatus() {
    if (_controller.gameLost.value || _controller.gameWon.value) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child:  Text(
        '${"incorrect_guess".tr} ${_controller.incorrectGuesses}/${_controller.maxIncorrectGuesses}',
        style: const TextStyle(color: Colors.black38),
      ),
    );
  }

  Widget _buildHintButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_controller.wordHint.value.isNotEmpty)
          _buildHintButton(
            title: "${'guide'.tr}: 1",
            onTap: () => acceptDialog(
              context,
              "guide".tr,
              "${"first_letter".tr}: ${_controller.wordToGuess.value[0]}",
            ),
          ),
        const SizedBox(width: 10),
        _buildHintButton(
          title: "${'guide'.tr}: 2",
          onTap: () => acceptDialog(
            context,
            "guide".tr,
            _controller.wordHint.value,
          ),
        ),
      ],
    );
  }

  Widget _buildHintButton({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Obx(() => Wrap(
          alignment: WrapAlignment.center,
          spacing: 4.0,
          runSpacing: 0,
          children: List.generate(
            _controller.alphabet.length,
                (index) {
              final letter = _controller.alphabet[index];
              final isCorrectGuess = _controller.wordToGuess.value.contains(letter);
              return KeyboardButton(
                letter: letter,
                isGameOver: _controller.gameWon.value || _controller.gameLost.value,
                isCorrectGuess: isCorrectGuess,
                //index: index,
                onPressed: _controller.gameWon.value ||
                    _controller.gameLost.value ||
                    _controller.guessedLetters.contains(letter)
                    ? null
                    : () => _controller.checkGuess(letter),
              );
            },
          ),
        )),
      ),
    );
  }

  Widget _buildHiddenWord() {
    if (_controller.gameLost.value) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          _controller.buildHiddenWord(),
          style: TextStyle(
            fontSize: 36,
            color: _controller.gameWon.value ? Colors.amber : Colors.black87,
            fontWeight: _controller.gameWon.value ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Positioned.fill(
      child: Obx(() {
        final isGameFinished = _controller.gameWon.value || _controller.gameLost.value;
        final isOnlineMode = _controller.isOnlineMode.value;

        return AnimatedOpacity(
          opacity: isGameFinished ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: isGameFinished && !isOnlineMode
              ? _buildGameEndContent()
              : const SizedBox.shrink(),
        );
      }),
    );
  }

  Widget _buildGameEndContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_controller.gameWon.value)
          Lottie.asset(
            'assets/games/hangman/winner_green.json',
            width: 450,
            height: 450,
            fit: BoxFit.contain,
          ),
        if (_controller.gameLost.value) ...[
          const GameOverCryingEmoji(),
          const SizedBox(height: 10),
          Text(
            _controller.wordToGuess.value,
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
        if (( _controller.gameWon.value
            || _controller.gameLost.value)
            && !_controller.isOnlineMode.value
        )
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton(
              onPressed: () => _controller.startNextGame(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'btn_new_game'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _admobBanner() {
    return Container(
      padding: EdgeInsets.all(4),
      color: Colors.teal[900],
      child: AdaptiveBannerAd(
        onAdLoaded: (isLoaded) {
          if (isLoaded) {
            debugPrint('Ad loaded in Quiz Screen');
          } else {
            debugPrint('Ad failed to load in Quiz Screen');
          }
        },
      ),
    );
  }


}



/*class HangmanPlayScreen extends StatefulWidget {
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
          leading: IconButton(
            onPressed: () {Get.offNamed('/hangmanPlaySettings');},
            icon: const Icon(Icons.arrow_back),
          ),
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
                  Column(
                    children: [
                      // Hangman drawing with fixed height
                      Container(
                        padding: EdgeInsets.all(4),
                        color: Colors.teal[900],
                        child: AdaptiveBannerAd(
                          onAdLoaded: (isLoaded) {
                            if (isLoaded) {
                              debugPrint('Ad loaded in Quiz Screen');
                            } else {
                              debugPrint('Ad failed to load in Quiz Screen');
                            }
                          },
                        ),
                      ),  // Banner
                      SizedBox(
                        height: constraints.maxHeight * 0.28,
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

                      // Scrollable area for remaining content
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Obx(() {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  // Hidden Word
                                  if (!controller.gameLost.value)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                                      child: Center(
                                        child: Directionality(
                                          textDirection: controller.isAlphabetRTL.value
                                              ? TextDirection.rtl
                                              : TextDirection.ltr,
                                          child: Text(
                                            controller.buildHiddenWord(),
                                            style: TextStyle(
                                              fontSize: 30,
                                              color: controller.gameWon.value
                                                  ? Colors.amber
                                                  : Colors.black,
                                              fontWeight: controller.gameWon.value
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Game status and hints
                                  if (!controller.gameLost.value && !controller.gameWon.value)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                                                  onTap: () => acceptDialog(
                                                      context,
                                                      "guide".tr,
                                                      "${"first_letter".tr}: ${controller.wordToGuess.value[0]}"
                                                  ),
                                                ),
                                              const SizedBox(width: 10),
                                              GestureDetector(
                                                child: Text(
                                                  "${'guide'.tr}: 2",
                                                  style: const TextStyle(color: Colors.green),
                                                ),
                                                onTap: () => acceptDialog(
                                                    context,
                                                    "guide".tr,
                                                    controller.wordHint.value
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Keyboard
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                                    child: Container(
                                      constraints: const BoxConstraints(maxWidth: 600),
                                      child: Obx(() => Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: 4.0,
                                        runSpacing: 2.0,
                                        children: List.generate(
                                          controller.alphabet.length,
                                              (index) {
                                            final letter = controller.alphabet[index];
                                            final isCorrectGuess = controller.wordToGuess.value.contains(letter);
                                            return AnimatedKeyboardButton(
                                              letter: letter,
                                              isGameOver: controller.gameWon.value || controller.gameLost.value,
                                              isCorrectGuess: isCorrectGuess,
                                              index: index,
                                              onPressed: controller.gameWon.value ||
                                                  controller.gameLost.value ||
                                                  controller.guessedLetters.contains(letter)
                                                  ? null
                                                  : () => controller.checkGuess(letter),
                                            );
                                          },
                                        ),
                                      )),
                                    ),
                                  ),
                                  //const SizedBox(height: 20),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),

                    Positioned.fill(
                      child: Obx(() => AnimatedOpacity(
                        opacity: (controller.gameWon.value || controller.gameLost.value) ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (controller.gameWon.value && !controller.isOnlineMode.value)
                              Lottie.asset(
                                'assets/games/hangman/winner_green.json',
                                width: 450,
                                height: 450,
                                fit: BoxFit.contain,
                              ),
                            if (controller.gameLost.value && !controller.isOnlineMode.value) ...[
                              const GameOverCryingEmoji(),
                              const SizedBox(height: 10),
                              Text(
                                controller.wordToGuess.value,
                                style: const TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red
                                ),
                              ),
                            ],
                            if (( controller.gameWon.value
                                || controller.gameLost.value)
                                && !controller.isOnlineMode.value
                            )
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
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
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}*/

