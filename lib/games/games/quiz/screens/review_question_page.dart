import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../../api/firestore/firestore_quiz.dart';
import '../../../../helper/sharedpreferences.dart';
import '../../../../shared/show_custom_snackbar.dart';
import '../../../constants/constants.dart';
import '../../models/question_models.dart';

class ReviewQuestionsPage extends StatefulWidget {
  const ReviewQuestionsPage({super.key});

  @override
  ReviewQuestionsPageState createState() => ReviewQuestionsPageState();
}

class ReviewQuestionsPageState extends State<ReviewQuestionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _questionsStream;
  late List<DocumentSnapshot> questions;

  int? selectedQuizIndex;
  List<String>? language = [];
  List<String> quizPath = [];
  List<String> quizLabels = [];
  String? _userRole = "";

  List<TextEditingController> wrongAnswerControllers = [];

  @override
  void initState() {
    super.initState();
    getAppLanguage();
    getUserRole();

    _questionsStream = _firestore.collection('games').doc('quizz').collection('quetionRequest').snapshots();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (var controller in wrongAnswerControllers) {
      controller.dispose();
    }
    wrongAnswerControllers.clear();
  }

  Future<void> getUserRole() async {
    final value = await SharedPreferencesManager.getString(SharedPreferencesKeys.userRoleKey);
    if (value != null && value != "") {
      setState(() {
        _userRole = value;
      });
    }
  }

  Future<void> getAppLanguage() async {
    List<String>? value = await SharedPreferencesManager.getStringList(SharedPreferencesKeys.appLanguageKey);
    setState(() {
      if (value != null && value.isNotEmpty) {
        language = value;
        if (value[0] == 'fa') {
          quizPath = quizListConstantsAfRoutes;
          quizLabels = quizListConstantsFa;
        } else if (value[0] == 'en') {
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


  Future<void> _approveQuestion(
      QuizQuestionModel newQuestion,
      String pathId, String docId) async {

    final firestoreAPI = FirestoreQuiz();
    final result = await firestoreAPI.addQuestionToApprovedList(quizId: pathId, quizData: newQuestion);

    if ( result == true) {
      _removeCurrentQuestion(docId);
      showCustomSnackbar('question_added_to_quiz'.tr, true);
    } else {
      showCustomSnackbar('not_expected_result'.tr, false);
    }
  }

  Future<void> _rejectQuestion(DocumentSnapshot question, String docId) async {
    _removeCurrentQuestion(docId);
  }

  void _removeCurrentQuestion(String docId) async {

    final firestoreAPI = FirestoreQuiz();
    final removingResult = await firestoreAPI.deleteQuestionFromReviewList(documentId: docId);
    if(removingResult) {
      setState(() {
        _disposeControllers();
        if (questions.isNotEmpty) {
          questions.removeAt(0);
        }
      });
    }else{
      showCustomSnackbar('not_expected_result'.tr, false);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("btn_review_question".tr),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _questionsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("no_review_questions".tr));
          }

          questions = snapshot.data!.docs;

          if (questions.isEmpty) {
            return Center(child: Text("no_more_questions".tr));
          }

          final question = questions[0];
          //print("QuestionId: ${question.id}");

          TextEditingController pathController = TextEditingController(text: question['path']);
          TextEditingController questionController = TextEditingController(text: question['question']);
          TextEditingController correctAnswerController = TextEditingController(text: question['correctAnswer']);
          TextEditingController descriptionController = TextEditingController(text: question['description'] ?? '');

          // Initialize controllers for wrong answers
          wrongAnswerControllers = (question['wrongAnswers'] as String).split(',').map((answer) {
            return TextEditingController(text: answer.trim());
          }).toList();

          return SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      enabled: false,
                      controller: pathController,
                      decoration: InputDecoration(labelText: "path".tr),
                    ),
                    TextFormField(
                      controller: questionController,
                      decoration: InputDecoration(labelText: "question".tr),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      style: const TextStyle(fontSize: 20),
                      controller: correctAnswerController,
                      decoration: InputDecoration(labelText: "correct_answer".tr),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(wrongAnswerControllers.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: TextFormField(
                              controller: wrongAnswerControllers[index],
                              decoration: InputDecoration(
                                labelText: "wrong_answer".tr,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: "description".tr),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Create new question model with updated data
                            QuizQuestionModel newQuestion = QuizQuestionModel(
                              path: pathController.text,
                              question: questionController.text,
                              correctAnswer: correctAnswerController.text,
                              wrongAnswers: wrongAnswerControllers.map((c) => c.text).join(','),
                              description: descriptionController.text,
                            );

                            _approveQuestion(newQuestion, pathController.text, question.id);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: Text("btn_approve".tr),
                        ),
                        ElevatedButton(
                          onPressed: () => _rejectQuestion(question, question.id),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: Text("btn_reject".tr),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


