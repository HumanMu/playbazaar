import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../constants/enums.dart';
import 'controller/connector_play_controller.dart';
import '../../../global_widgets/dialog/accept_dialog.dart';
import '../../../controller/user_controller/user_controller.dart';
import 'package:playbazaar/helper/sharedpreferences/sharedpreferences.dart';

import 'widgets/language_directory.dart';

class WordConnectorSettingsScreen extends StatefulWidget {
  const WordConnectorSettingsScreen({super.key});

  @override
  State<WordConnectorSettingsScreen> createState() => _WordConnectorSettingsScreenState();
}

class _WordConnectorSettingsScreenState extends State<WordConnectorSettingsScreen> {
  final ConnectorPlayController controller = Get.isRegistered<ConnectorPlayController>()
      ? Get.find<ConnectorPlayController>()
      : Get.put(ConnectorPlayController(), permanent: true);

  final userController = Get.find<UserController>();
  late UserRole userRole = UserRole.normal;
  String selectedLanguage = "en";
  bool _isInitializing = true;

  @override
  void initState(){
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {

      List<String>? value = await SharedPreferencesManager.getStringList(
          SharedPreferencesKeys.appLanguageKey);

      setState(() {
        userRole = userController.userData.value!.role;
        controller.gameState.value.language = value?[0]??'en';
        selectedLanguage = value?[0] ?? "en";
        _isInitializing = false;
      });
    } catch (e) {
      debugPrint('Error initializing data: $e');
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.offNamed('/mainGames'),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          "word_connector_settings".tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
      ),
      body: _isInitializing? const Center(
        child: CircularProgressIndicator(),
      ): Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLevelCard(),
                  _buildPlayCard(),
                ],
              ),
              _buildFancyControlBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey.shade50, Colors.white],
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'your_level'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text( controller.gameState.value.level.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("choose_language".tr),
                  LanguagePicker(
                    initialLanguage: selectedLanguage,
                    onLanguageChanged: (String newLanguage) {
                      setState(() {
                        selectedLanguage = newLanguage;
                        controller.gameState.value.language = newLanguage;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "reset_your_level".tr,
                    style: TextStyle(color: Colors.blueGrey.shade700),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => controller.resetUserLevel(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade100,
                      foregroundColor: Colors.blueGrey.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("btn_reset".tr),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayCard() {
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
            color: Colors.blue.shade100.withValues(alpha: 0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          'btn_start'.tr,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade900,
          ),
        ),
        subtitle: Text(
          'remember_game_level'.tr,
          style: TextStyle(color: Colors.blueGrey.shade700),
        ),
        trailing: Icon(
          Icons.play_circle_outline,
          color: Colors.blue.shade700,
          size: 40,
        ),
        onTap: () {
          Get.toNamed('/wordConnectorPlayScreen');
          controller.loadGameData();
        },
      ),
    );
  }

  Widget _buildFancyControlBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (userRole != UserRole.normal)
            ElevatedButton(
              onPressed: () => Get.toNamed('/addWordConnectorScreen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade100,
                foregroundColor: Colors.blueGrey.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("btn_send_words".tr),
            ),
          TextButton(
            onPressed: () => acceptDialog(
              context,
              'play_rules_title'.tr,
              'word_connector_play_rules'.tr,
            ),
            child: Text(
              'guide'.tr,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }


}