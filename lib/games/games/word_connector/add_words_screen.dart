import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:playbazaar/games/games/word_connector/widgets/language_directory.dart';
import 'controller/add_word_controller.dart';

class AddWordConnectorScreen extends StatefulWidget {
  const AddWordConnectorScreen({super.key});

  @override
  State<AddWordConnectorScreen> createState() => _AddWordConnectorScreenState();
}

class _AddWordConnectorScreenState extends State<AddWordConnectorScreen> {
  late final AddWordController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AddWordController());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("add_words".tr,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _levelAndLanguage(),
                  SizedBox(height: 25),
                  _addWordCard(),
                  const SizedBox(height: 24),
                  _addedResultCard(),
                ],
              ),
              SizedBox(height: 30),
              _saveToFirestore(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _levelAndLanguage() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("level".tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 150,  // Match TextField width
                  child: Text(
                    "max_level_100".tr,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    maxLines: 2,  // Allow up to 2 lines
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 40,
                  child: TextField(
                    controller: controller.wordLevelController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
  
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        int? number = int.tryParse(value);
                        if (number == null || number >= 101) {
                          controller.wordLevelController.text = '';
                          controller.wordLevelController.selection = TextSelection.collapsed(offset: 0);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("choose_language".tr),
                LanguagePicker(
                  onLanguageChanged: (String newLanguage) {
                    controller.languageDirectory.value = newLanguage;
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _addWordCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("add_words".tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("add_words_label".tr,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.wordController,
              decoration: InputDecoration(
                labelText: "add_words".tr,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÆØÅæøåء-ي\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]')),
                UpperCaseTextFormatter(),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.addWord,
              child: Text("btn_add".tr,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _addedResultCard() {
    return Obx(() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("current_data".tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text("${"language1".tr}:  ${controller.languageDirectory.value}"),
            const SizedBox(height: 16),
            Text("${"level".tr}:  ${controller.wordLevelController.text}"),
            const SizedBox(height: 8),
            Text("${"words".tr}:  ${controller.currentWords.join(", ")} "),
            const SizedBox(height: 8),
            Text("${"letters".tr}:  ${controller.currentLetters.join(", ")} "),
          ],
        ),
      ),
    ));
  }

  Widget _saveToFirestore() {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading.value ? null : controller.saveWordsToFirestore,
      style: ElevatedButton.styleFrom(
        backgroundColor: controller.currentWords.length < 3
            ? Colors.grey
            : Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: controller.isLoading.value
          ? const CircularProgressIndicator()
          : Text("btn_save".tr,
          style: const TextStyle(color: Colors.white)),
    ));
  }
}



// Text formatter to convert input to uppercase (unchanged)
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
