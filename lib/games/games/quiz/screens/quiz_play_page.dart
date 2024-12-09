import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playbazaar/controller/sound_controller/sound_controller.dart';
import 'package:playbazaar/games/games/quiz/widgets/quiz_end_message_dialog.dart';
import '../../../../admob/adaptive_banner_ad.dart';
import '../../../../api/firestore/firestore_quiz.dart';
import '../../../../global_widgets/show_custom_snackbar.dart';
import '../../models/question_models.dart';
import '../widgets/quiz_result_dialog.dart';


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
  final SoundController soundController = Get.put(SoundController());
  late List<QuizQuestionModel> questionData = [];
  List<QuizAttempt> quizAttempts = [];
  bool showQuestionsDetailResult = false;
  List<String> currentAnswer = [];
  late String currentQuestion = "";
  late int selectedAnswer = 0;
  int? selectedAnswerIndex;
  bool? isCorrect;
  late bool showAnswer = false;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    getQuestionsFromFirestore();
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
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
                                  soundController.playSound('assets/sounds/button/ui_clicked.wav');
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
      widget.withOption? showResult() : showQuizzEnd();
    }
  }


  Future<void> getQuestionsFromFirestore() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final questionResult = await FirestoreQuiz().getRandomQuizQuestions(
          quizId: widget.selectedQuiz
      );

      if (questionResult.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      // Optimize duplicate removal using toSet() and a custom comparator
      final uniqueQuestionsList = questionResult.toSet().toList();

      setState(() {
        questionData = uniqueQuestionsList;
        isLoading = false;
        selectedAnswer = 0;

        final firstQuestion = questionData[selectedAnswer];
        currentQuestion = firstQuestion.question;
        currentAnswer = _prepareUniqueAnswers(firstQuestion);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => isLoading = false);
      showCustomSnackbar('error*loading_quiz'.tr, false);
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


  Color getButtonColor(int index) {
    if (selectedAnswerIndex != null && selectedAnswer < questionData.length && index < currentAnswer.length) {
      final isThisAnswerCorrect = currentAnswer[index] == questionData[selectedAnswer].correctAnswer;

      final result = isThisAnswerCorrect ? Colors.green : Colors.red;
      return result;
    } else {
      return Colors.white70;
    }
  }

  void showQuizzEnd() async {
      if (quizAttempts.isEmpty) {
        return;
      }
      endQuiz();
      showDialog(
          context: context,
          builder: (context) => QuizEndMessageDialog(
          quizAttempts: quizAttempts
      ));
  }

  void showResult() async {
    if (quizAttempts.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => QuizResultDialog(
        quizAttempts: quizAttempts,
        onContinue: () {
          endQuiz();
          Navigator.of(context).pop();
          Get.offNamed('/mainQuiz');
        },
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

}
