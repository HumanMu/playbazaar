import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/quiz/screens/quiz_play_page.dart';
import 'package:playbazaar/helper/sharedpreferences/sharedpreferences.dart';
import '../../../api/Authentication/auth_service.dart';
import '../../../screens/widgets/sidebar_drawer.dart';
import '../../widgets/game_list_box.dart';
import 'functions/quiz_language.dart';

class QuizMainPage extends StatefulWidget {
  const QuizMainPage({super.key});

  @override
  State<QuizMainPage> createState() => _QuizMainPage();
}

class _QuizMainPage extends State<QuizMainPage> {
  AuthService authService = AuthService();

  List<String>? language = [];
  List<String> quizPath = [];
  List<String> quizNames = [];
  String userRole = "";

  int quizLength = 0;

  @override
  void initState() {
    super.initState();
    _initializeLanguageSettings();
    _initializeUserRole();
  }


  Future<void> _initializeLanguageSettings() async {
    final result = await getQuizLanguage();
    setState(() {
      quizPath = result['quizPath'];
      quizLength = result['quizLength'];
      quizNames = result['quizNames'];
    });
  }
  
  Future<void> _initializeUserRole() async {
    final role = await SharedPreferencesManager.getString(SharedPreferencesKeys.userRoleKey) ?? "normal";
    setState(() {
      userRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text("quiz_list".tr,
          style: const TextStyle(
              color: Colors.white,
              fontWeight:
              FontWeight.bold,
              fontSize: 25
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white
        ),
      ),

      drawer: SidebarDrawer(
          authService: authService,
          parentContext: context
      ),
      body: quizPath.isEmpty && quizLength == 0
          ? const Center(child: CircularProgressIndicator())
          : _quizList(),
    );
  }

  Widget _quizList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: quizLength,
            itemBuilder: (context, index) {
              return GameListBox(
                title: quizNames[index],
                navigationParameter: quizPath[index],
                onTap: _handleNavigation,
              );
            },
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
              child: Text("add_question_hint".tr),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/addQuestion');
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          )
                      ),
                      child: Text("btn_send_question".tr),
                    ),
                  ),
                  const SizedBox(width: 4),
                  userRole != "normal" && userRole != ""? Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/questionReviewPage');
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          )
                      ),
                      child: Text("btn_review_question".tr),
                    ),
                  ) : const Text(""),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  void _handleNavigation(String selectedPath, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizPlayScreen(selectedQuiz: selectedPath, quizTitle: title)),
    );
  }

}
