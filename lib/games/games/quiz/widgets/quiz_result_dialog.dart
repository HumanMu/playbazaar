import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/question_models.dart';

class QuizResultDialog extends StatelessWidget {
  final List<QuizAttempt> quizAttempts;
  final VoidCallback onContinue;

  const QuizResultDialog({
    super.key,
    required this.quizAttempts,
    required this.onContinue
  });

  @override
  Widget build(BuildContext context) {
    int numberOfCorrectAnswers = quizAttempts.where((attempt) => attempt.isCorrect).length;
    int numberOfWrongAnswers = quizAttempts.length - numberOfCorrectAnswers;
    int points = numberOfCorrectAnswers * 3 - quizAttempts.where((attempt) => !attempt.isCorrect).length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${"points_earned".tr}:   $points"),
                      _motivationResult(numberOfCorrectAnswers),
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

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: onContinue,
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
    );
  }

  Widget _motivationResult(int correctAnswer) {
    if (correctAnswer <= 3) {
      return _buildMotivationText("you_can_do_better", Icons.thumb_down_alt, Colors.red, 14);
    } else if (correctAnswer <= 5) {
      return _buildMotivationText("not_bad", Icons.thumbs_up_down, Colors.orange, 18);
    } else if (correctAnswer <= 8) {
      return _buildMotivationText("well_done", Icons.thumb_up_alt, Colors.amber, 22);
    } else if (correctAnswer <= 10) {
      return _buildMotivationText("excellent", Icons.star, Colors.green, 26);
    } else {
      return const SizedBox();
    }
  }

  Widget _buildMotivationText(String text, IconData icon, Color color, double fontSize) {
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