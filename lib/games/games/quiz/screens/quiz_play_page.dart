import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:playbazaar/controller/settings_controller/notification_settings_controller.dart';
import '../../../../admob/adaptive_banner_ad.dart';
import '../../../../api/firestore/firestore_quiz.dart';
import '../../../../global_widgets/show_custom_snackbar.dart';
import '../../models/question_models.dart';


class QuizPlayScreen extends StatefulWidget {
  final String selectedQuiz;
  final String quizTitle;
  final bool withOption;

  const QuizPlayScreen({
    super.key,
    required this.selectedQuiz,
    required this.quizTitle,
    this.withOption = false,
  });

  @override
  State<QuizPlayScreen> createState()  => _QuizPlayScreen();

}

class _QuizPlayScreen extends State<QuizPlayScreen>{
  final NotificationSettingsController settingsController = Get.find<NotificationSettingsController>();
  late AudioPlayer _player;
  bool isLoading = true;
  late List<QuizQuestionModel> questionData = [];
  List<QuizAttempt> quizAttempts = [];
  bool showQuestionsDetailResult = false;
  List<String> currentAnswer = [];
  late String currentQuestion = "";
  late int selectedAnswer = 0;
  int? selectedAnswerIndex;
  bool? isCorrect;
  late bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _playSound();
    getQuestionsFromFirestore();
  }

  @override
  void dispose() {
    _player.dispose();
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
          style: const TextStyle(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: isLoading
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
              ),  // The BannerAd widget
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20), // This padding is only for the quiz content
                child: questionData.isEmpty
                  ? Center(
                    child: Text(
                      'empty_quizz_message'.tr,
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                  : widget.withOption? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        currentQuestion,
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
                          itemCount: currentAnswer.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  _playSound();
                                  checkAnswer(index);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: getButtonColor(index),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    currentAnswer[index],
                                    style: GoogleFonts.actor(
                                      textStyle: const TextStyle(fontSize: 17),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      isCorrect != null && isCorrect!
                        ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "correct_answer".tr,
                            style: const TextStyle(color: Colors.green, fontSize: 20),
                          ),
                        )
                        : Container(),
                          isCorrect != null && !isCorrect!
                          ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                            "${"wrong_answer".tr} ",
                            style: const TextStyle(color: Colors.red, fontSize: 20),
                          ),
                         )
                          : Container(),
                    ],
                  ) : Column(
                    children: [
                      Text(
                        currentQuestion,
                        style: GoogleFonts.actor(
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      showAnswer ? Text(
                        questionData[selectedAnswer].correctAnswer,
                        style: const TextStyle(color: Colors.green, fontSize: 40),
                      ) : ElevatedButton(
                        onPressed: () => checkAnswer(selectedAnswer),
                        child: Text("show_result".tr),
                      ),
                    ],
                  ),
              ),
            ) ,
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedAnswerIndex != null ? Colors.green : Colors.white70,
                ),
                child: Text("btn_next".tr),
              ),
            )
          ],
      ),
    );
  }


  void nextQuestion() {
    if (!mounted) return;

    if (selectedAnswerIndex == null) {
      showCustomSnackbar('pick_an_answer'.tr, false);
      return;
    }

    if (selectedAnswer < questionData.length - 1) {
      setState(() {
        selectedAnswer++;
        final QuizQuestionModel nextQuestion = questionData[selectedAnswer];
        currentQuestion = nextQuestion.question;
        currentAnswer = _prepareUniqueAnswers(nextQuestion);
        selectedAnswerIndex = null;
        isCorrect = null;
        showAnswer = false;
      });
    } else {
      widget.withOption? showResult() : endOfQuestions();
    }
  }

  void endOfQuestions() {
    if (quizAttempts.isEmpty) {
      return;
    }
    showDialog(
      context: context,
      builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0)),
          child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.8, // 80% of screen width
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("end_of_family_game".tr),
                  SizedBox(height: 40),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        endQuiz();
                        Navigator.of(context).pop();
                        Get.offNamed('/mainQuiz');
                      },
                      child: Text(
                        "btn_continue".tr,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              )
          ),
        ),
    );
  }


  Future<void> getQuestionsFromFirestore() async {
    setState(() {
      isLoading = true;
    });

    try {
      final questionResult = await FirestoreQuiz().getRandomQuizQuestions(
          quizId: widget.selectedQuiz
      );

      if (!mounted) return;

      if (questionResult.isNotEmpty) {
        // Use a set with a custom equality check to remove duplicates
        final uniqueQuestions = <QuizQuestionModel>{};
        for (var question in questionResult) {
          // Add only if a similar question doesn't already exist
          if (!uniqueQuestions.any((q) => q.question == question.question)) {
            uniqueQuestions.add(question);
          }
        }

        // Convert back to a list
        final uniqueQuestionsList = uniqueQuestions.toList();

        setState(() {
          questionData = uniqueQuestionsList;
          isLoading = false;
          selectedAnswer = 0;

          final firstQuestion = questionData[selectedAnswer];
          currentQuestion = firstQuestion.question;

          // Prepare unique answers
          currentAnswer = _prepareUniqueAnswers(firstQuestion);
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
      showCustomSnackbar('error_loading_quiz'.tr, false);
    }
  }


  List<String> _prepareUniqueAnswers(QuizQuestionModel question) {
    // Split the answers and remove duplicates
    Set<String> allAnswers = question.wrongAnswers.split(',').toSet();

    // Add correct answer
    allAnswers.add(question.correctAnswer);

    // Convert to list to allow further manipulation
    List<String> uniqueAnswers = allAnswers.toList();

    if (uniqueAnswers.length > 10) {
      uniqueAnswers = uniqueAnswers.take(10).toList();
    }

    uniqueAnswers.shuffle(Random());
    return uniqueAnswers;
  }



  void checkAnswer(int index) {
    if (questionData.isEmpty || index < 0 || index >= currentAnswer.length) {
      return;
    }

    if(!widget.withOption){
      setState(() {
        showAnswer = true;
        selectedAnswerIndex = index;
        isCorrect = true;
      });
    }

    setState(() {
      selectedAnswerIndex = index;
      isCorrect = currentAnswer[index] == questionData[selectedAnswer].correctAnswer;
    });

    bool alreadyAnswered = quizAttempts.any(
            (attempt) => attempt.question == questionData[selectedAnswer].question
    );

    if (!alreadyAnswered) {
      QuizAttempt attempt = QuizAttempt(
        question: questionData[selectedAnswer].question,
        userAnswer: currentAnswer[index],
        correctAnswer: questionData[selectedAnswer].correctAnswer,
        isCorrect: isCorrect ?? false,
      );
      quizAttempts.add(attempt);
    }
    else {
      return showCustomSnackbar("question_is_answered".tr, false);
    }
  }


  void _playSound() async {
    if(!settingsController.isButtonSoundsEnabled.value){
      return;
    }

    try {
      await _player.setAsset('assets/sounds/button/ui_clicked.wav');
      _player.play();
    } catch (e) {
      if (kDebugMode) {
        print("Error playing sound: $e");
      }
    }
  }



  void showResult() async {
    if (quizAttempts.isEmpty) {
      return;
    }
    int numberOfCorrectAnswers = quizAttempts.where((attempt) => attempt.isCorrect).length;
    int numberOfWrongAnswers = quizAttempts.length - numberOfCorrectAnswers;
    int points = numberOfCorrectAnswers * 3 - quizAttempts.where((attempt) => !attempt.isCorrect).length;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.all(0),
                alignment: Alignment.center,
                child: Text("game_result".tr,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${"correct_answers".tr}:  $numberOfCorrectAnswers"),
                        Text("${"wrong_answers".tr}:  $numberOfWrongAnswers"),
                      ],
                    ),
                  ),

                  Expanded( // Use Expanded to make Columns take up available space
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${"points_earned".tr}:   $points"),
                        motivationResult(numberOfCorrectAnswers),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 12, color: Colors.blueGrey),
              const SizedBox(height: 10),
              Container(
                margin: EdgeInsets.all(0),
                alignment: Alignment.center,
                child: Text("details".tr,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: quizAttempts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final attempt = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${"question_hint".tr} ${index + 1}: ${attempt.question}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${"your_answer".tr}: "),
                                Expanded(
                                  child: Text(
                                    attempt.userAnswer,
                                    style: TextStyle(
                                      color: attempt.isCorrect ? Colors.green : Colors.red,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            attempt.isCorrect == false
                                ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${"correct_answer".tr}: "),
                                    Expanded(
                                      child: Text(
                                        attempt.correctAnswer,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )
                                : const Text(""),
                            const Divider(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Button should stay fixed at the bottom
              const SizedBox(height: 10), // Add space between content and button
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    endQuiz();
                    Navigator.of(context).pop();
                    Get.offNamed('/mainQuiz');
                  },
                  child: Text(
                    "btn_continue".tr,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void endQuiz() {
    setState(() {
      questionData = [];
      quizAttempts = [];
      currentAnswer = [];
      currentQuestion = "";
      selectedAnswer = 0;
    });
  }


  Color getButtonColor(int index) {
    if (selectedAnswerIndex != null && selectedAnswer < questionData.length && index < currentAnswer.length) {
      final isThisAnswerCorrect = currentAnswer[index] == questionData[selectedAnswer].correctAnswer;

      final result = isThisAnswerCorrect ? Colors.green : Colors.red;
      return result;
    } else {
      return Colors.white70;
    }
  }


  Widget motivationResult(int correctAnswer) {
    if (correctAnswer <= 3) {
      return buildMotivationText("you_can_do_better", Icons.thumb_down_alt, Colors.red, 14);
    } else if (correctAnswer <= 5) {
      return buildMotivationText("not_bad", Icons.thumbs_up_down, Colors.orange, 18);
    } else if (correctAnswer <= 8) {
      return buildMotivationText("well_done", Icons.thumb_up_alt, Colors.amber, 22);
    } else if (correctAnswer <= 10) {
      return buildMotivationText("excellent", Icons.star, Colors.green, 26);
    } else {
      return const SizedBox();
    }
  }


  Widget buildMotivationText(String text, IconData icon, Color color, double fontSize) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text.tr,
            style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(icon, color: color, size: fontSize + 6),
          ),
        ],
      ),
    );
  }




}
