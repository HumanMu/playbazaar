import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playbazaar/admob/adaptive_banner_ad.dart';

import '../controller/quiz_play_controller.dart';

class NoneOptionizedPlayScreen extends StatelessWidget {
  final String selectedQuiz;
  final String quizTitle;

  const NoneOptionizedPlayScreen({
    super.key,
    required this.selectedQuiz,
    required this.quizTitle,
  });

  @override
  Widget build(BuildContext context) {
    final QuizPlayController controller =
    Get.put(QuizPlayController(
        selectedQuiz: selectedQuiz,
        quizTitle: quizTitle
    ));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          quizTitle,
          style: const TextStyle(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              color: Colors.teal[900],
              child: AdaptiveBannerAd(
                onAdLoaded: (isLoaded) {
                  debugPrint(isLoaded
                      ? 'Ad loaded in Quiz Screen'
                      : 'Ad failed to load in Quiz Screen');
                },
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: controller.questionData.isEmpty
                ? Center(
                  child: Text(
                    'empty_quizz_message'.tr,
                    style: const TextStyle(fontSize: 16),
                  ),
                )
                : Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            controller.currentQuestion.value,
                            style: GoogleFonts.actor(
                              textStyle: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          controller.showAnswer.value
                          ? Text(
                            controller.questionData[controller.selectedAnswer.value].correctAnswer,
                            style: const TextStyle(color: Colors.green, fontSize: 40),
                          )
                          : ElevatedButton(
                            onPressed: () => controller.displayAnswer(controller.selectedAnswer.value),
                            child: _textButton("show_the_answer".tr, Colors.black),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: ElevatedButton(
                          onPressed: ()=> controller.nextQuestion(false, context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.selectedAnswerIndex.value != null
                                ? Colors.green
                                : Colors.white70,
                          ),
                          child: _textButton("btn_next".tr, null),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ]
      ),
      ),
    );
  }

  Widget _textButton(String text, Color? btnColor) {
    return Text(
      text,
      style: TextStyle(
        color: btnColor ?? Colors.white,
      ),
    );
  }
}