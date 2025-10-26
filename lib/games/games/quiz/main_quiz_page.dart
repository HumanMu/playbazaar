import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:playbazaar/constants/enums.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import 'package:playbazaar/global_widgets/dialog/accept_dialog.dart';
import '../../../api/Authentication/auth_service.dart';
import '../../../screens/widgets/sidebar_drawer.dart';
import '../../widgets/game_list_box.dart';
import '../../functions/get_quiz_language.dart';

class QuizMainPage extends StatefulWidget {
  const QuizMainPage({super.key});

  @override
  State<QuizMainPage> createState() => _QuizMainPage();
}

class _QuizMainPage extends State<QuizMainPage> {
  AuthService authService = AuthService();
  final userController = Get.find<UserController>();

  List<String>? language = [];
  List<String> quizPath = [];
  List<String> quizNames = [];
  late UserRole userRole;

  int quizLength = 0;
  late bool expandedQuizIndex = false;

  @override
  void initState() {
    super.initState();
    _initializeLanguageSettings();
    _initializeUserRole();
  }

  Future<void> _initializeUserRole() async {
    setState(() {
      userRole = userController.userData.value!.role;
    });
  }


  Future<void> _initializeLanguageSettings() async {
    final result = await getQuizLanguage('language_shortcut'.tr);
    setState(() {
      quizPath = result['quizPath'];
      quizLength = result['quizLength'];
      quizNames = result['quizNames'];
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.red,
          title: Text(
            "quiz_list".tr,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        drawer: SidebarDrawer(
          authService: authService,
          parentContext: context,
        ),
        body: SafeArea(
          top: false,
          bottom: true,
          child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.blue.shade50,
              ],
            ),
          ),
          child: quizPath.isEmpty && quizLength == 0
              ? const Center(child: CircularProgressIndicator())
              : _quizList(),
        ),
      ),
    );
  }

  Widget _quizList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              margin: EdgeInsets.only(top: 15),
              child: ListView.builder(
                itemCount: quizNames.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      GameListBox(
                        title: quizNames[index],
                        gamePath: quizPath[index],

                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Text(
                "add_question_hint".tr,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: Colors.green,
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => acceptDialog(
                            context,
                            'guide'.tr,
                            'quiz_play_guide'.tr
                        ),
                        child: Text(
                          'guide'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.push('/addQuestion'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          side: BorderSide.none,
                          elevation: 0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            "btn_send_question".tr,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (userRole != UserRole.normal)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.push('/questionReviewPage'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            side: BorderSide.none,
                            elevation: 0,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              "btn_review".tr,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }


}
