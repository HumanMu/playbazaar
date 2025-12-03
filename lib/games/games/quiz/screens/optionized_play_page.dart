import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playbazaar/global_widgets/buttons/primary_button.dart';
import 'package:playbazaar/services/settings/sound_services.dart';
import '../../../../admob/banner/adaptive_banner_ad.dart';
import '../../../../core/dialog/dialog_listner.dart';
import '../controller/quiz_play_controller.dart';



class OptionizedPlayScreen extends ConsumerStatefulWidget {
  final String selectedQuiz;
  final String quizTitle;

  const OptionizedPlayScreen({
    super.key,
    required this.selectedQuiz,
    required this.quizTitle,
  });

  @override
  ConsumerState<OptionizedPlayScreen> createState()  => _QuizPlayScreen();

}

class _QuizPlayScreen extends ConsumerState<OptionizedPlayScreen>{
  final soundService = Get.find<SoundService>();
  late QuizPlayController playController;

  @override
  void initState() {
    super.initState();
    playController = Get.put(QuizPlayController(
      selectedQuiz: widget.selectedQuiz,
      quizTitle: widget.quizTitle)
    );
  }

  @override
  void dispose() {
    if(Get.isRegistered<QuizPlayController>()) {
      Get.delete<QuizPlayController>(force: true);
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final dialogManager = ref.read(dialogManagerProvider.notifier);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.red,
          title: Text(
            widget.quizTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              context.go("/mainQuiz");
            },
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.blue.shade50,
              ],
            ),
          ),
          child: Obx(() => playController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      color: Colors.blueGrey.shade50,
                      child: AdaptiveBannerAd(
                        onAdLoaded: (isLoaded) {
                          debugPrint(isLoaded
                              ? 'Ad loaded in Quiz Screen'
                              : 'Ad failed to load in Quiz Screen'
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 16, 20),
                      child: playController.questionData.isEmpty
                        ? Center(
                          child: Text(
                            'empty_quizz_message'.tr,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey.shade700
                            ),
                          ),
                        )
                        : SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Question Text
                              playController.showAnswer.value && playController.currentDescription.value != null
                                  ? Text(
                                playController.currentDescription.value ?? playController.currentQuestion.value,
                                style: GoogleFonts.actor(
                                  textStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.green.shade700
                                  ),
                                ),
                              )
                                  : Text(
                                playController.currentQuestion.value,
                                style: GoogleFonts.actor(
                                  textStyle: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.blueGrey.shade900
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Answer Buttons
                              Container(
                                constraints: const BoxConstraints(maxWidth: 700),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: playController.currentAnswer.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          playController.checkAnswer(index);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: playController.getButtonColor(index),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Text(
                                            playController.currentAnswer[index],
                                            style: GoogleFonts.actor(
                                              textStyle: TextStyle(
                                                fontSize: 17,
                                                color: playController.isCorrect.value != null
                                                    ? Colors.white
                                                    : Colors.blueGrey.shade900,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Feedback Text
                              playController.isCorrect.value != null
                              ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  playController.isCorrect.value!
                                      ? "correct_answer".tr
                                      : "${"wrong_answer".tr} ",
                                  style: TextStyle(
                                      color: playController.isCorrect.value!
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                      fontSize: 20
                                  ),
                                ),
                              )
                              : Container(),
                            ],
                          ),
                        ),
                    ),
                  ),

                  // Next Button
                  SafeArea(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: PrimaryButton(
                        onPressed: () => playController.nextQuestion(true, dialogManager),
                        text: "btn_next".tr,
                        backgroundColor: playController.selectedAnswerIndex.value != null
                            ? Colors.green.shade600
                            : Colors.blueGrey.shade300,
                        borderRadius: 12,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
}
