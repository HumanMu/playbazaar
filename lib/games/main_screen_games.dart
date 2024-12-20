import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/global_widgets/show_custom_snackbar.dart';
import '../api/Authentication/auth_service.dart';
import '../screens/widgets/sidebar_drawer.dart';
import 'functions/get_game_language.dart';

class MainScreenGames extends StatefulWidget {
  const MainScreenGames({super.key});

  @override
  State<MainScreenGames> createState() => _MainScreenGames();
}

class _MainScreenGames extends State<MainScreenGames> {
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
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text("games_list".tr,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white
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
            constraints: BoxConstraints(maxWidth: 600),
            child: ListView.builder(
              itemCount: gameNames.length,
              itemBuilder: (context, index){
                return _buildGameTile(
                  title: gameNames[index],
                  gamePath: gamePath[index],
                );
              }
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameTile({
    required String title,
    required String gamePath
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: ListTile(
        title: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          _navigateToGamePage(gamePath);
        },
      ),
    );
  }

  void _navigateToGamePage(String gamePath) {

    switch (gamePath) {
      case 'Quiz':
        Get.toNamed('/mainQuiz');
        break;
      case 'Hangman':
        Get.toNamed('/hangman');
        break;
      default: showCustomSnackbar('Please, pick a game first', false);
    }
  }
}

