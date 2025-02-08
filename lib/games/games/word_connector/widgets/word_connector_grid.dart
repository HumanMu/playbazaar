import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/word_connector/widgets/word_row.dart';
import '../../controller/connector_controller.dart';

class WordConnectorGrid extends StatelessWidget {
  const WordConnectorGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final WordConnectorController controller = Get.find<WordConnectorController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.hasError.value) {
        return Center(
          child: Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Colors.red),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.words.length,
        itemBuilder: (context, wordIndex) {
          final word = controller.words[wordIndex];
          return WordRow(word: word);
        },
      );
    });
  }
}

/*class WordConnectorGrid extends StatelessWidget {
  const WordConnectorGrid({super.key});


  @override
  Widget build(BuildContext context) {
    final WordConnectorController controller = Get.find();

    return Obx(() {
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: controller.words.length,
        itemBuilder: (context, wordIndex) {
          final word = controller.words[wordIndex];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                word.text.length,
                    (letterIndex) => _buildLetterBox(word, letterIndex),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildLetterBox(WordConnectorModel word, int index) {
    return Container(
      width: 35,
      height: 33,
      margin: EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        border: Border.all(
          color: word.isFound ? Colors.green : Colors.red.withValues(alpha: 0.4),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          word.isFound ? word.text[index] : '_',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: word.isFound ? Colors.green : Colors.black,
          ),
        ),
      ),
    );
  }
}*/