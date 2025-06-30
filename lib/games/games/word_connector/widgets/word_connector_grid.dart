import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/word_connector/widgets/word_row.dart';
import '../controller/connector_play_controller.dart';

class WordConnectorGrid extends StatelessWidget {
  const WordConnectorGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final ConnectorPlayController controller = Get.find<ConnectorPlayController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.hasError.value) {
        return Center(
          child: Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Colors.black54),
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
