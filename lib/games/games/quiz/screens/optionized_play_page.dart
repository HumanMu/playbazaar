import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playbazaar/controller/sound_controller/sound_controller.dart';
import 'package:playbazaar/games/games/controller/quiz_play_controller.dart';
import '../../../../admob/adaptive_banner_ad.dart';
import '../widgets/quiz_result_dialog.dart';


class OptionizedPlayScreen extends StatefulWidget {
  final String selectedQuiz;
  final String quizTitle;

  const OptionizedPlayScreen({
    super.key,
    required this.selectedQuiz,
    required this.quizTitle,
  });

  @override
  State<OptionizedPlayScreen> createState()  => _QuizPlayScreen();

}

class _QuizPlayScreen extends State<OptionizedPlayScreen>{
  late SoundController soundController;
  late QuizPlayController playController;


  @override
  void initState() {
    super.initState();
    playController = Get.put(QuizPlayController(
      selectedQuiz: widget.selectedQuiz,
      quizTitle: widget.quizTitle)
    );
    soundController = Get.put(SoundController());
  }

  @override
  void dispose(){
    soundController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.quizTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30
          ),
        ),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body:Obx(() => playController.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
            const SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: playController.questionData.isEmpty
                  ? Center(
                    child: Text(
                      'empty_quizz_message'.tr,
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        playController.currentQuestion.value,
                        style: GoogleFonts.actor(
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: playController.currentAnswer.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  //soundController.playSound('assets/sounds/button/ui_clicked.wav');
                                  playController.checkAnswer(index);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: playController.getButtonColor(index),
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
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      playController.isCorrect.value != null && playController.isCorrect.value!
                        ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "correct_answer".tr,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 20
                            ),
                          ),
                        )
                        : Container(),
                          playController.isCorrect.value != null && !playController.isCorrect.value!
                          ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                            "${"wrong_answer".tr} ",
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 20
                            ),
                          ),
                         )
                          : Container(),
                    ],
                  ),
              ),
            ) ,
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: ()=> playController.nextQuestion(true, context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: playController.selectedAnswerIndex.value != null
                      ? Colors.green
                      : Colors.white70,
                ),
                child: Text("btn_next".tr,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  /*void showResult() async {
    if (playController.quizAttempts.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => QuizResultDialog(
        quizAttempts: playController.quizAttempts,
        onContinue: () {
          playController.endQuiz();
          Navigator.of(context).pop();
          Get.offNamed('/mainQuiz');
        },
      ),
    );
  }*/
}
