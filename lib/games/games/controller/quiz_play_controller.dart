import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/api/firestore/firestore_quiz.dart';
import 'package:playbazaar/global_widgets/show_custom_snackbar.dart';
import '../models/question_models.dart';
import '../quiz/widgets/quiz_end_message_dialog.dart';
import '../quiz/widgets/quiz_result_dialog.dart';

class QuizPlayController extends GetxController {
  //final SoundController _soundController = Get.put(SoundController());

  final RxList<QuizQuestionModel> questionData = <QuizQuestionModel>[].obs;
  final RxList<QuizAttempt> quizAttempts = <QuizAttempt>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool showAnswer = false.obs;
  final RxInt selectedAnswer = 0.obs;
  final RxString currentQuestion = ''.obs;
  final RxList<String> currentAnswer = <String>[].obs;
  final RxnInt selectedAnswerIndex = RxnInt(null);

  // Only optionized
  final RxnBool isCorrect = RxnBool(null);

  final String selectedQuiz;
  final String quizTitle;


  QuizPlayController({
    required this.selectedQuiz,
    required this.quizTitle,
  });

  @override
  void onInit() async {
    super.onInit();
    await getQuestionsFromFirestore();
  }

  @override
  void onClose() {
    //_soundController.dispose();
    super.onClose();
  }

  Future<void> getQuestionsFromFirestore() async {
    isLoading.value = true;

    try {
      final questionResult = await FirestoreQuiz().getRandomQuizQuestions(
          quizId: selectedQuiz
      );

      if (questionResult.isEmpty) {
        return;
      }

      // Optimize duplicate removal using toSet() and a custom comparator
      final uniqueQuestionsList = questionResult.toSet().toList();

      questionData.value = uniqueQuestionsList;
      selectedAnswer.value = 0;

      final firstQuestion = questionData[selectedAnswer.value];
      currentQuestion.value = firstQuestion.question;
      currentAnswer.value = prepareUniqueAnswers(firstQuestion);

    } catch (error) {
      showCustomSnackbar('error_loading_quiz'.tr, false);
    }finally{
      isLoading.value = false;
    }
  }

  List<String> prepareUniqueAnswers(QuizQuestionModel question) {
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

  void nextQuestion(bool isOptionized, BuildContext context) {
    if (selectedAnswerIndex.value == null) {
      showCustomSnackbar('see_result_first'.tr, false);
      return;
    }

    if (selectedAnswer.value == (questionData.length - 1)) {
      if (isOptionized) {
        showResult(context);
      } else {
        showQuizzEnd();
      }
    } else {
      selectedAnswer.value++;
      final QuizQuestionModel nextQuestion = questionData[selectedAnswer.value];
      currentQuestion.value = nextQuestion.question;
      currentAnswer.value = prepareUniqueAnswers(nextQuestion);
      selectedAnswerIndex.value = null;
      showAnswer.value = false;
    }
  }

  Color getButtonColor(int index) {
    if (selectedAnswerIndex.value != null &&
        selectedAnswer.value < questionData.length &&
        index < currentAnswer.length) {
      final isThisAnswerCorrect = currentAnswer[index] ==
          questionData[selectedAnswer.value].correctAnswer;

      return isThisAnswerCorrect ? Colors.green : Colors.red;
    } else {
      return Colors.white70;
    }
  }


  void checkAnswer(int index) {
    if (questionData.isEmpty || index < 0 || index >= currentAnswer.length) {
      return;
    }

    selectedAnswerIndex.value = index;
    isCorrect.value = currentAnswer[index] == questionData[selectedAnswer.value].correctAnswer;

    bool alreadyAnswered = quizAttempts.any(
            (attempt) => attempt.question == questionData[selectedAnswer.value].question
    );

    if (!alreadyAnswered) {
      QuizAttempt attempt = QuizAttempt(
        question: questionData[selectedAnswer.value].question,
        userAnswer: currentAnswer[index],
        correctAnswer: questionData[selectedAnswer.value].correctAnswer,
        isCorrect: isCorrect.value ?? false,
      );
      quizAttempts.add(attempt);
    }
    else {
      return showCustomSnackbar("question_is_answered".tr, false);
    }
  }

  void displayAnswer(int index) {
    showAnswer.value = true;
    selectedAnswerIndex.value = index;
  }

  void showQuizzEnd() {
    if (questionData.isEmpty) return;
    endQuiz();

    Get.dialog(
        QuizEndMessageDialog(
            quizAttempts: quizAttempts)
    );
  }


  void showResult(BuildContext context) async {
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
    questionData.clear();
    quizAttempts.clear();
    currentAnswer.clear();
    currentQuestion.value = "";
    selectedAnswer.value = 0;
  }
}