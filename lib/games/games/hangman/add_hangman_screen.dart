
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/functions/string_cases.dart';
import 'package:playbazaar/games/games/hangman/models/hangman_word_model.dart';
import '../../../global_widgets/show_custom_snackbar.dart';
import '../../functions/get_hangman_difficulty.dart';
import '../../services/hangman_services.dart';


class AddHangmanWords extends StatefulWidget {
  const AddHangmanWords({super.key});

  @override
  State<AddHangmanWords> createState() => AddQuestionState();
}

class AddQuestionState extends State<AddHangmanWords> {
  final HangmanService hangmanService = Get.put(HangmanService());
  List<String>? language = [];
  List<String> difficultyLabels = [];
  List<String> difficultyNiveau = [];
  late String firestorePath;
  int? selectedQuizIndex;

  final TextEditingController _hintController = TextEditingController();
  final TextEditingController _wordsController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _initializeLanguageSettings();
  }

  @override
  void dispose(){
    _hintController.dispose();
    _wordsController.dispose();
    _difficultyController.dispose();
    super.dispose();
  }


  Future<void> _initializeLanguageSettings() async {
    final result = await getHangmanDifficulty();
    setState(() {
      difficultyNiveau = result['difficultyNivea'];
      difficultyLabels = result['difficultyLabels'];
      firestorePath = result['firestorePath'];
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text("add_question_title".tr,
            style: TextStyle(
                color: Colors.white
            ),
          ),
          backgroundColor: Colors.red,
          iconTheme: IconThemeData(
              color: Colors.white
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              Text("pick_difficulty".tr, style: const TextStyle(fontSize: 16),),
              ...difficultyLabels.asMap().entries.map((entry) {
                int index = entry.key;
                String label = entry.value;
                return CheckboxListTile(
                  title: Text(label),
                  value: selectedQuizIndex == index,
                  onChanged: (bool? value) {
                    setState(() {
                      selectedQuizIndex = value == true ? index : null;
                      if (selectedQuizIndex != null) {
                        _difficultyController.text = difficultyNiveau[selectedQuizIndex!]; // Set the corresponding path
                      } else {
                        _difficultyController.clear();
                      }
                    });
                  },
                );
              }),
              _textFormWD("add_words_label".tr, _wordsController, true),
              _textFormWD("add_words_hint".tr, _hintController, false),

              Container(
                margin: const EdgeInsets.only(top: 15),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => _submit(),
                    child: Text("btn_send".tr)),
              )
            ],
          ),
        ),
    );
  }

  void _submit() async{
    if(_hintController.text.trim().isEmpty
        || _wordsController.text.trim().isEmpty
        || selectedQuizIndex == null
    ){
      showCustomSnackbar('fill_all_input'.tr, false);
      return;
    }

    final randomSeed = Random().nextDouble();
    final HangmanWordModel newWords = HangmanWordModel(
      hint: _hintController.text.trim(),
      difficulty: _difficultyController.text.trim(),
      words: splitByComma(_wordsController.text),
      random: randomSeed,
    );

    try{
      await hangmanService.addWordsToReviewList(
          collectionId: firestorePath,
          wordsData: newWords
      );

      showCustomSnackbar('question_added'.tr, true);
      _hintController.clear();
      _wordsController.clear();
      _difficultyController.clear();


    }catch(e){
      if (kDebugMode) {
        print("Failed to add quetions: $e");
      }
    }
  }


  Widget _textFormWD(String labelText, TextEditingController controller, bool isMultiLine) {
    return Container(
        margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labelText,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8), // Add some space between the text and the TextFormField
            TextFormField(
              controller: controller,
              maxLines: isMultiLine ? null : 1,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
              ),
            ),
          ],
        )
    );
  }

}