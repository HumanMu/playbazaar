import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/global_widgets/show_custom_snackbar.dart';
import '../api/Authentication/auth_service.dart';
import '../screens/widgets/sidebar_drawer.dart';
import 'functions/get_game_language.dart';

class MainScreenGames extends StatefulWidget {
  const MainScreenGames({super.key});

  @override
  State<MainScreenGames> createState() => _MainScreenGamesState();
}

class _MainScreenGamesState extends State<MainScreenGames> {
  AuthService authService = AuthService();
  List<String> gamePath = [];
  List<String> gameNames = [];
  int gameLength = 0;

  @override
  void initState() {
    super.initState();
    _initializeLanguageSettings();
  }

  Future<void> _initializeLanguageSettings() async {
    final result = await getGameLanguage();
    setState(() {
      gamePath = result['gamePath'];
      gameNames = result['gameNames'];
      gameLength = gameNames.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text(
          "games_list".tr,
          style: TextStyle(
            color: Colors.grey.shade200,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.grey.shade200,
        ),
      ),
      drawer: SidebarDrawer(
        authService: authService,
        parentContext: context,
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(16),
          child: _gameList(),
        ),
      ),
    );
  }

  Widget _gameList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView.builder(
              itemCount: gameNames.length,
              itemBuilder: (context, index) {
                return _buildGameTile(
                  gamePath: gamePath[index],
                );
              },
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildGameTile({
    //required String title,
    required String gamePath,
  }) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: ListTile(
          title: Text(gamePath.tr,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () => navigateToGamePage(gamePath),
        ),
      ),
    );
  }

  void navigateToGamePage(String gamePath) {
    switch (gamePath) {
      case 'quiz':
        Get.toNamed('/mainQuiz');
        break;
      case 'hangman':
        Get.toNamed('/hangmanPlaySettings');
        break;
      case 'wordconnector':
        Get.toNamed('/wordConnectorSettingScreen');
        break;
      case 'ludo_missions':
        Get.toNamed('/ludoLobby');
        break;
      default:
        showCustomSnackbar('Please, pick a game first', false);
    }
  }



}

