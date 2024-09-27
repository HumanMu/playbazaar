import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:playbazaar/controller/settings_controller/settings_controller.dart';
import '../../../../api/firestore/firestore_quiz.dart';
import '../../../../utils/show_custom_snackbar.dart';
import '../../models/question_models.dart';


class QuizPlayScreen extends StatefulWidget {
  final String selectedQuiz;
  final String quizTitle;
  const QuizPlayScreen({super.key, required this.selectedQuiz, required this.quizTitle});

  @override
  State<QuizPlayScreen> createState()  => _QuizPlayScreen();

}

class _QuizPlayScreen extends State<QuizPlayScreen>{
  final SettingsController settingsController = Get.find<SettingsController>();
  //late GameController gameController;
  late AudioPlayer _player;
  bool isLoading = true;
  int answeredQuetions = 0;
  late List<QuizQuestionModel> questionData = [];
  List<QuizAttempt> quizAttempts = [];
  bool showQuestionsDetailResult = false;


  List<String> currentAnswer = [];
  late String currentQuestion = "";
  late int selectedAnswer = 0;
  int? selectedAnswerIndex;
  bool? isCorrect;
  String? errorMessage;


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
        title: Text(widget.quizTitle,
          style: const TextStyle(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
            padding: const EdgeInsets.all(16.0),
            child: questionData.isEmpty? Center(
              child: Text('empty_quizz_message'.tr,style: const TextStyle(fontSize: 16)),
            )
                : Column(
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
                        itemCount: currentAnswer.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                              onPressed: (){
                                _playSound();
                                checkAnswer(index);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: getButtonColor(index),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(currentAnswer[index],
                                    style: GoogleFonts.actor(
                                        textStyle: const TextStyle(fontSize: 17)
                                    ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(onPressed: nextQuestion,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: selectedAnswerIndex != null
                              ? Colors.green
                              : Colors.white70
                      ),
                      child: Text("btn_next".tr),
                    ),

                ],
              ),
          ),
    );
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


  void nextQuestion() {
    if ( mounted && selectedAnswerIndex != null) {
      if (selectedAnswer < questionData.length - 1) {
        setState(() {
          selectedAnswer = selectedAnswer + 1;
          final QuizQuestionModel nextQuestion = questionData[selectedAnswer];
          currentQuestion = nextQuestion.question;
          currentAnswer = nextQuestion.wrongAnswers.split(',');
          currentAnswer.add(nextQuestion.correctAnswer);
          currentAnswer.shuffle(Random());
          selectedAnswerIndex = null;
          isCorrect = null;
          answeredQuetions++;
        });
      } else {
        showResult();
      }
    } else {
      showCustomSnackbar('pick_an_answer'.tr, false);
    }
  }


  void showResult() async {
    if (quizAttempts.isEmpty) {
      return;
    }
    //loadQuizAttempts();
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
                        Text("${"correct_answers".tr}:    $numberOfCorrectAnswers"),
                        Text("${"wrong_answers".tr}:    $numberOfWrongAnswers"),
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
                  onPressed: () => Navigator.of(context).pop(),
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




  Future<void> getQuestionsFromFirestore() async {
    try {
      final questionResult = await FirestoreQuiz().getRandomQuizQuestions(
          quizId: widget.selectedQuiz);
      if(mounted) {
        setState(() {
          questionData = questionResult;
          isLoading = false;
          if (questionData.isNotEmpty) {
            currentQuestion = questionData[selectedAnswer].question;
            currentAnswer = questionData[selectedAnswer].wrongAnswers.split(',');
            currentAnswer.add(questionData[selectedAnswer].correctAnswer);
            currentAnswer.shuffle(Random());
          }
        });
        isLoading = false;
      }
      else {
        return;
      }
    } catch (error) {
      setState(() {
        isLoading= false;
      });
    }
  }

  Widget motivationResult(int correctAnswer) {
    if (correctAnswer <= 3) {
      return buildMotivationText("you_can_do_better", Icons.thumb_down_alt, Colors.red, 18);
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




  Widget motivationResult1(int correctAnswer) {
    if(correctAnswer <= 3) {
      return Text("you_can_do_better".tr,
        style: TextStyle(color: Colors.red),
      );
    }
    else if(correctAnswer <= 5) {
      return Text("not_bad".tr);
    }
    else if(correctAnswer <= 8) {
      return Text("well_done".tr,
        style: TextStyle(color: Colors.green, fontSize: 18),
      );
    }
    else if(correctAnswer <= 10){
      return Text("excellent".tr,
        style: TextStyle(color: Colors.green, fontSize: 30),);
    }
    else{
      return Text("");
    }
  }



  void checkAnswer(int index) {
    setState(() {
      selectedAnswerIndex = index;
      isCorrect = currentAnswer[index] == questionData[selectedAnswer].correctAnswer;
    });

    bool alreadyAnswered = quizAttempts.any(
            (attempt) => attempt.question == questionData[selectedAnswer].question
    );

    if (mounted && !alreadyAnswered) {
      QuizAttempt attempt = QuizAttempt(
        question: questionData[selectedAnswer].question,
        userAnswer: currentAnswer[selectedAnswerIndex!],
        correctAnswer: questionData[selectedAnswer].correctAnswer,
        isCorrect: isCorrect ?? false,
      );
      quizAttempts.add(attempt);
      //SharedPreferencesService().saveQuizAttempts(quizAttempts);
    }
    else {
      return showCustomSnackbar("question_is_answered".tr, false);
    }
  }


  Color getButtonColor(int index) {
    if (selectedAnswerIndex != null) {
      final isThisAnswerCorrect = currentAnswer[index] == questionData[selectedAnswer].correctAnswer;

      final result = isThisAnswerCorrect ? Colors.green : Colors.red;
      return result;
    } else {
      return Colors.white70;
    }
  }

  /*Future<void> loadQuizAttempts() async {
    final quizAttemptsData = await SharedPreferencesService().loadQuizAttempts();
    if (mounted && quizAttemptsData != null) {
      setState(() {
        quizAttempts = quizAttemptsData;
      });
    }
  }*/

}
