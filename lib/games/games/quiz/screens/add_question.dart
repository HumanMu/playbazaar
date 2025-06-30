
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/firestore_quiz.dart';
import '../../../../global_widgets/show_custom_snackbar.dart';
import '../../../functions/get_quiz_language.dart';
import '../models/question_models.dart';


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
  bool addingQuiz = false;

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
    _initializeLanguageSettings();
  }

  @override
  void dispose(){
    _quizC.dispose();
    _questionC.dispose();
    _correctAnswerC.dispose();
    _wrongAnswer1C.dispose();
    _wrongAnswer2C.dispose();
    _wrongAnswer3C.dispose();
    _quetionDescriptionC.dispose();
    super.dispose();
  }


  Future<void> _initializeLanguageSettings() async {
    final result = await getQuizLanguage();
    setState(() {
      quizPath = result['quizPath'];
      quizLabels = result['quizNames'];
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
                  child: Text("btn_send".tr,
                    style: TextStyle(color: Colors.white),
                  )),
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
        || selectedQuizIndex == null
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
    debugPrint("Failed to add quetions: ${newQuestion.wrongAnswers}");

    firestoreAPI.addQuestionsToReviewList(
      quizId: 'quetionRequest',
      quizData: newQuestion,
    ).then((_) {

      showCustomSnackbar('question_added'.tr, true);
      //_questionC.clear();
      _correctAnswerC.clear();
      _wrongAnswer1C.clear();
      _wrongAnswer2C.clear();
      _wrongAnswer3C.clear();
      _quetionDescriptionC.clear();
      _questionC.clear();
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
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              maxLines: isMultiLine ? null : 1,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "enter_your_answer_here".tr,
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
