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
      backgroundColor: Colors.grey.shade200,
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey.shade100,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
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
                  title: gameNames[index],
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
    required String title,
    required String gamePath,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.shade100.withValues(alpha: 0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Center(
          child: Text(
            gamePath.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade900,
            ),
          ),
        ),
        onTap: () => navigateToGamePage(gamePath),
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
      default:
        showCustomSnackbar('Please, pick a game first', false);
    }
  }
}

