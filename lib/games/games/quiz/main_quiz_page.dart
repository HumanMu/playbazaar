import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/quiz/screens/add_question.dart';
import 'package:playbazaar/games/games/quiz/screens/quiz_play_page.dart';
import 'package:playbazaar/games/games/quiz/screens/review_question_page.dart';
import '../../../api/Authentication/auth_service.dart';
import '../../../helper/sharedpreferences.dart';
import '../../../screens/widgets/sidebar_drawer.dart';
import '../../constants/constants.dart';
import '../../widgets/game_list_box.dart';

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

  int quizLength = 0;

  @override
  void initState() {
    super.initState();
    getAppLanguage();
  }

  Future<void> getAppLanguage() async {
    List<String>? value = await SharedPreferencesManager.getStringList(SharedPreferencesKeys.appLanguageKey);
    setState(() {
      if (value != null && value.isNotEmpty) {
        language = value;
        if (value[0] == 'fa') {
          quizPath = quizListConstantsAfRoutes;
          quizLength = quizListConstantsAfRoutes.length;
          quizNames = quizListConstantsFa;
        } else if (value[0] == 'en') {
          quizPath = quizListConstantsEnRoutes;
          quizLength = quizListConstantsEnRoutes.length;
          quizNames = quizListConstantsEnRoutes;
        }
      } else {
        language = ['fa', 'AF'];
        quizPath = quizListConstantsAfRoutes;
        quizLength = quizListConstantsAfRoutes.length;
        quizNames = quizListConstantsFa;
      }
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
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
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
                onTap:  _handleNavigation,
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddQuestion()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("btn_send_question".tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReviewQuestionsPage()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("btn_review_question".tr),
            )
          ],
        )
      ],
    );
  }

  void _handleNavigation(String selectedPath) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizPlayScreen(selectedQuiz: selectedPath)),
    );
  }
}
