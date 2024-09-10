
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../api/firestore/firestore_quiz.dart';
import '../../../../helper/sharedpreferences.dart';
import '../../../../shared/show_custom_snackbar.dart';
import '../../../constants/constants.dart';
import '../../models/question_models.dart';


class AddQuestion extends StatefulWidget {
  const AddQuestion({super.key});

  @override
  State<AddQuestion> createState() => AddQuestionState();
}

class AddQuestionState extends State<AddQuestion> {

  List<String> quizLabels = [];
  List<String>? language = [];
  List<String> quizPath = [];
  int? selectedQuizIndex;

  final TextEditingController _quizC = TextEditingController();
  final TextEditingController _questionC = TextEditingController();
  final TextEditingController _correctAnswerC = TextEditingController();
  final TextEditingController _wrongAnswer1C = TextEditingController();
  final TextEditingController _wrongAnswer2C = TextEditingController();
  final TextEditingController _wrongAnswer3C = TextEditingController();
  final TextEditingController _quetionDescriptionC = TextEditingController();



  @override
  void initState() {
    super.initState();
    getAppLanguage();
  }


  Future<void> getAppLanguage() async {
    List<String>? value = await SharedPreferencesManager.getStringList(SharedPreferencesKeys.userRoleKey);
    setState(() {
      if (value != null && value.isNotEmpty) {
        language = value;
        if(value[0] == 'fa'){
          quizPath = quizListConstantsAfRoutes;
          quizLabels = quizListConstantsFa;
        }
        else if(value[0] == 'en'){
          quizPath = quizListConstantsEnRoutes;
          quizLabels = quizListConstantsEnRoutes;
        }
      } else {
        language = ['fa', 'AF'];
        quizPath = quizListConstantsAfRoutes;
        quizLabels = quizListConstantsFa;
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text("add_question_title".tr),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            Text("pick_quiz_hint".tr, style: const TextStyle(fontSize: 16),),
            ...quizLabels.asMap().entries.map((entry) {
              int index = entry.key;
              String label = entry.value;
              return CheckboxListTile(
                title: Text(label),
                value: selectedQuizIndex == index,
                onChanged: (bool? value) {
                  setState(() {
                    selectedQuizIndex = value == true ? index : null;
                    if (selectedQuizIndex != null) {
                      _quizC.text = quizPath[selectedQuizIndex!]; // Set the corresponding path
                    } else {
                      _quizC.clear();
                    }
                  });
                },
              );
            }),
            _textFormWD("question_hint".tr, _questionC, false),
            _textFormWD("correct_answer".tr, _correctAnswerC, false),
            _textFormWD("${"wrong_answers".tr} 1", _wrongAnswer1C, false),
            _textFormWD("${"wrong_answers".tr} 2", _wrongAnswer2C, false),
            _textFormWD("${"wrong_answers".tr} 3", _wrongAnswer3C, false),
            _textFormWD("more_information_add_quiz".tr, _quetionDescriptionC, true),

            Container(
              margin: const EdgeInsets.only(top: 15),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => _submit(),
                  child: Text("btn_send".tr)),
            )
          ],
        ),
      )


    );
  }

  void _submit() {
    if(_questionC.text.trim().isEmpty
        || _correctAnswerC.text.trim().isEmpty
        || _wrongAnswer1C.text.trim().isEmpty
        || _wrongAnswer2C.text.trim().isEmpty
        || _wrongAnswer3C.text.trim().isEmpty
    ){
      showCustomSnackbar('fill_all_input'.tr, false);
      return;
    }

    final String wrongAnswers = [
      _wrongAnswer1C.text.trim(),
      _wrongAnswer2C.text.trim(),
      _wrongAnswer3C.text.trim(),
    ].join(',');

    final QuizQuestionModel newQuestion = QuizQuestionModel(
      path: _quizC.text.trim(),
      question: _questionC.text.trim(),
      correctAnswer: _correctAnswerC.text.trim(),
      wrongAnswers: wrongAnswers,
      description: _quetionDescriptionC.text.trim().isNotEmpty
          ? _quetionDescriptionC.text.trim()
          : null,
    );
    final firestoreAPI = FirestoreQuiz();
    if (kDebugMode) {
      print("Failed to add quetions: ${newQuestion.wrongAnswers}");
    }

    firestoreAPI.addQuestionsToReviewList(
      quizId: 'quetionRequest',
      quizData: newQuestion,
    ).then((_) {

      showCustomSnackbar('question_added'.tr, true);
      _quizC.clear();
      _questionC.clear();
      _correctAnswerC.clear();
      _wrongAnswer1C.clear();
      _wrongAnswer2C.clear();
      _wrongAnswer3C.clear();
      _quetionDescriptionC.clear();
    });
  }


  Widget _textFormWD(String hintText, TextEditingController controller, bool isMultiLine) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 15, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hintText,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8), // Add some space between the text and the TextFormField
            TextFormField(
              controller: controller,
              maxLines: isMultiLine ? null : 1,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "enter_your_answer_here".tr, // Add hintText here
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                ),
                border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
              ),
            ),
          ],
        )
    );
  }

}