import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_models.dart';

class SharedPreferencesService {
  static const String _quizAttemptsKey = 'quiz_attempts';

  Future<void> saveQuizAttempts(List<QuizAttempt> quizAttempts) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(quizAttempts);
    await prefs.setString(_quizAttemptsKey, encodedData);
  }

  Future<List<QuizAttempt>?> loadQuizAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = prefs.getString(_quizAttemptsKey);

    if (encodedData != null) {
      return List<QuizAttempt>.from(
        jsonDecode(encodedData).map((data) => QuizAttempt.fromJson(data)),
      );
    }

    return null;
  }
}
