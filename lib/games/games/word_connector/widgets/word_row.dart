import 'package:flutter/material.dart';
import '../models/word_model.dart';
import 'letter_box.dart';

class WordRow extends StatelessWidget {
  final WordConnectorModel word;

  const WordRow({
    super.key,
    required this.word,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          word.text.length,
              (letterIndex) => LetterBox(
            word: word,
            letterIndex: letterIndex,
          ),
        ),
      ),
    );
  }
}
