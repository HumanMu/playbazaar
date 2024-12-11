import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/widgets/game_list_box.dart';
import '../api/Authentication/auth_service.dart';
import '../screens/widgets/sidebar_drawer.dart';
import '../screens/widgets/text_boxes/text_widgets.dart';
import 'constants/constants.dart';
import 'games/ludo/play_page.dart';
import 'games/quiz/main_quiz_page.dart';
import 'games/quiz/screens/add_question.dart';

class MainScreenGames extends StatefulWidget {
  const MainScreenGames({super.key});

  @override
  State<MainScreenGames> createState() => _MainScreenGames();
}

class _MainScreenGames extends State<MainScreenGames> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text("games_list".tr,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      drawer: SidebarDrawer(
        authService: authService,
        parentContext: context,
      ),
      body: Center(
        child: _gameList(),
      ),
    );
  }

  Widget _gameList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: ListView.builder(
                itemCount: gameListConstantsFa.length,
                itemBuilder: (context, index){
                  return GameListBox(
                    title: gameListConstantsFa[index],
                    quizPath: gameListConstants[index],
                    //onTap: _handleNavigation,
                  );
                }
            ),
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
              child: Text("btn_send_question".tr,),
            )
          ],
        )
      ],
    );
  }

  void _handleNavigation(String? selectedPath, String title, String pagePath) {
   switch(selectedPath){
     case "Quiz":
       navigateToAnotherScreen(context, const QuizMainPage());
       break;
     case "Ludo":
       navigateToAnotherScreen(context, const LudoWorldWar());
       break;

     default: return;
   }
  }
}

