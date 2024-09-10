import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../api/firestore/firestore_quiz.dart';
import '../../../../shared/show_custom_snackbar.dart';
import '../../models/question_models.dart';
import '../sharedpreferences/quiz.dart';



class QuizPlayScreen extends StatefulWidget {
  final String selectedQuiz;
  const QuizPlayScreen({super.key, required this.selectedQuiz});

  @override
  State<QuizPlayScreen> createState()  => _QuizPlayScreen();

}

class _QuizPlayScreen extends State<QuizPlayScreen> {

  bool isLoading = true;
  int answeredQuetions = 0;
  late List<QuizQuestionModel> questionData = [];
  List<QuizAttempt> quizAttempts = [];

  List<String> currentAnswer = [];
  late String currentQuestion = "";
  late int selectedAnswer = 0;
  int? selectedAnswerIndex;
  bool? isCorrect;
  String? errorMessage;


  @override
  void initState() {
    super.initState();
    getQuestionsFromFirestore();
  }




  Future<void> getQuestionsFromFirestore() async {
    try {
      final questionResult = await FirestoreQuiz().getRandomQuizQuestions(
          quizId: 'hazaragi');
      // Update the state with the fetched questions
      setState(() {
        questionData = questionResult;
        isLoading = false;
        if (questionData.isNotEmpty) { // Check if there are questions
          currentQuestion = questionData[selectedAnswer].question;
          currentAnswer = questionData[selectedAnswer].wrongAnswers.split(',');
          currentAnswer.add(questionData[selectedAnswer].correctAnswer);
          currentAnswer.shuffle(Random());
        }
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load questions: $error';
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.selectedQuiz),
        backgroundColor: Colors.red,
      ),
      body: isLoading? const Center(child: CircularProgressIndicator()) : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  currentQuestion,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
                          onPressed: () => checkAnswer(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: getButtonColor(index),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(currentAnswer[index],
                              style: const TextStyle(fontSize: 17 ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(onPressed: nextQuestion,
                  child: Text("btn_next".tr),
                )
              ],
            ),
          ),
    );
  }


  void showResult() async {
    if (quizAttempts.isEmpty) {
      return;
    }

    loadQuizAttempts();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max, // Adjust to content height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "game_result".tr,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7, // Max height for the dialog content
                ),
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
                              "${"question".tr} ${index + 1}: ${attempt.question}",
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
                            attempt.isCorrect == false? Row(
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
                            ) : const Text(""),
                            const Divider(), // Optional divider between questions
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("btn_continue".tr,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.green
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

  Future<void> loadQuizAttempts() async {
    final quizAttemptsData = await SharedPreferencesService().loadQuizAttempts();
    if (quizAttemptsData != null) {
      setState(() {
        quizAttempts = quizAttemptsData;
      });
    }
  }

  void nextQuestion() {
    if (selectedAnswerIndex != null) {
      // Check if there's a next question
      if (selectedAnswer < questionData.length - 1) {
        setState(() {
          selectedAnswer = selectedAnswer + 1;
          final QuizQuestionModel nextQuestion = questionData[selectedAnswer];
          currentQuestion = nextQuestion.question;
          currentAnswer = nextQuestion.wrongAnswers.split(',');
          currentAnswer.add(nextQuestion.correctAnswer);
          currentAnswer.shuffle(Random());
          selectedAnswerIndex = null; // Reset selected answer index for the new question
          isCorrect = null; // Reset the correct answer state
          answeredQuetions++;
        });
      } else {
        showResult();
      }
    } else {
      showCustomSnackbar('pick_an_answer'.tr, false);
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

    if (!alreadyAnswered) {
      QuizAttempt attempt = QuizAttempt(
        question: questionData[selectedAnswer].question,
        userAnswer: currentAnswer[selectedAnswerIndex!],
        correctAnswer: questionData[selectedAnswer].correctAnswer,
        isCorrect: isCorrect ?? false,
      );
      quizAttempts.add(attempt);
      SharedPreferencesService().saveQuizAttempts(quizAttempts);
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
      return Colors.blue; // Default color for unselected buttons
    }
  }

}
