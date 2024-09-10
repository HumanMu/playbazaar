import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizzWidget extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final int currentIndex;
  final Function(int) onNext;

  const QuizzWidget({super.key,
    required this.questions,
    required this.currentIndex,
    required this.onNext,
  });

  @override
  QuizzWidgetState createState() => QuizzWidgetState();
}

class QuizzWidgetState extends State<QuizzWidget> {
  @override
  Widget build(BuildContext context) {
    final question = widget.questions[widget.currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Question ${widget.currentIndex + 1}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              question['question'],
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ...question['wrong_answers'].map((answer) => ListTile(
              title: Text(answer),
              onTap: () {
                widget.onNext(widget.currentIndex + 1);
              },
            )),
            ListTile(
              title: Text(question['correct_answer']),
              onTap: () {
                widget.onNext(widget.currentIndex + 1);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onNext(widget.currentIndex + 1);
              },
              child: Text('btn_next'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
