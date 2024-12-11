import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/constants/enums.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import 'package:playbazaar/global_widgets/accept_dialog.dart';
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


  Future<void> _initializeLanguageSettings() async {
    final result = await getQuizLanguage();
    setState(() {
      quizPath = result['quizPath'];
      quizLength = result['quizLength'];
      quizNames = result['quizNames'];
    });
  }
  
  Future<void> _initializeUserRole() async {
    setState(() {
      userRole = userController.userData.value!.role;
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
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              child: ListView.builder(
                itemCount: quizNames.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      GameListBox(
                        title: quizNames[index],
                        quizPath: quizPath[index],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () => acceptDialog(
              context,
              'guide'.tr,
              'quiz_play_guide'.tr
          ),
          child: Text('guide'.tr,
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
              )
          ),
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 3
              ),
              child: Text("add_question_hint".tr),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              constraints: BoxConstraints(maxWidth: 600),
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
                      child: Text("btn_send_question".tr,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  userRole != UserRole.normal? Expanded(
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
                      child: Text("btn_review_question".tr,
                        style: TextStyle(color: Colors.white),
                      ),
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

}
