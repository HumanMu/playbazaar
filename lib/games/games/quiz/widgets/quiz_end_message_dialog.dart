import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/question_models.dart';

class QuizEndMessageDialog extends StatelessWidget {
  final List<QuizAttempt> quizAttempts;

  const QuizEndMessageDialog({
    super.key,
    required this.quizAttempts,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
    );

  }
}
