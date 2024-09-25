import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../api/firestore/firestore_quiz.dart';
import '../../games/games/models/question_models.dart';
import '../../games/games/quiz/sharedpreferences/quiz.dart';
import '../../utils/show_custom_snackbar.dart';

class GameController extends GetxController {
  final AudioPlayer _player = AudioPlayer();

  var isLoading = true.obs;
  var questionData = <QuizQuestionModel>[].obs;
  var currentQuestion = "".obs;
  var currentAnswer = <String>[].obs;
  var selectedAnswer = 0.obs;
  var selectedAnswerIndex = Rxn<int>();
  var isCorrect = Rxn<bool>();
  var quizAttempts = <QuizAttempt>[].obs;

  final String quizId;
  GameController(this.quizId);

  @override
  void onInit() async {
    super.onInit();
    await playSound();
    //playSound("button/ui_clicked.wav");
    getQuestionsFromFirestore(quizId);
    isLoading.value = false;
  }
  Future<void> preloadSound(String soundPath) async {
    try {
      await _player.setAsset(soundPath);
    } catch (e) {
      showCustomSnackbar("Error preloading sound", false);
    }
  }


  Future<void> playSound() async {
    try {
      await _player.setAsset('assets/sounds/button/ui_clicked.wav');
      _player.play();
    } catch (e) {
      showCustomSnackbar("Error playing sound", false);
    }
  }

  Future<void> getQuestionsFromFirestore(String quizId) async {
    try {
      final questionResult = await FirestoreQuiz().getRandomQuizQuestions(quizId: quizId);
      questionData.value = questionResult;
      if (questionData.isNotEmpty) {
        updateCurrentQuestion();
      }
    } catch (error) {
      if (kDebugMode) {
        print("An error occured");
      }
    }
  }

  void updateCurrentQuestion() {
    currentQuestion.value = questionData[selectedAnswer.value].question;
    currentAnswer.value = questionData[selectedAnswer.value]
        .wrongAnswers.split(',')..add(questionData[selectedAnswer.value].correctAnswer);
    currentAnswer.shuffle(Random());
  }

  void nextQuestion() {
    if (selectedAnswerIndex.value != null) {
      if (selectedAnswer.value < questionData.length - 1) {
        selectedAnswer.value++;
        updateCurrentQuestion();
        selectedAnswerIndex.value = null;
      } else {
        return;
      }
    }
  }

  void checkAnswer(int index) {
    selectedAnswerIndex.value = index;
    isCorrect.value = currentAnswer[index] == questionData[selectedAnswer.value].correctAnswer;

    bool alreadyAnswered = quizAttempts.any(
          (attempt) => attempt.question == questionData[selectedAnswer.value].question,
    );

    if (!alreadyAnswered) {
      QuizAttempt attempt = QuizAttempt(
        question: questionData[selectedAnswer.value].question,
        userAnswer: currentAnswer[selectedAnswerIndex.value!],
        correctAnswer: questionData[selectedAnswer.value].correctAnswer,
        isCorrect: isCorrect.value ?? false,
      );
      quizAttempts.add(attempt);
      SharedPreferencesService().saveQuizAttempts(quizAttempts);
    } else {
      // Handle already answered case
    }
  }



// Other methods...
}
