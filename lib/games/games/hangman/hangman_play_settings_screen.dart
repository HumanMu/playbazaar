import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playbazaar/global_widgets/show_custom_snackbar.dart';
import '../../../constants/enums.dart';
import '../../../controller/user_controller/user_controller.dart';
import '../../../global_widgets/dialog/accept_dialog.dart';
import '../../../global_widgets/tiles/custom_switch_tile.dart';
import 'package:playbazaar/games/games/hangman/controller/play_controller.dart';
import '../../widgets/custom_switch_textbox_tile.dart';


class HangmanPlaySettingsScreen extends StatefulWidget {

  const HangmanPlaySettingsScreen({super.key});

  @override
  State<HangmanPlaySettingsScreen> createState() => _HangmanPlaySettingsScreenState();
}

class _HangmanPlaySettingsScreenState extends State<HangmanPlaySettingsScreen> {
  final PlayController controller = Get.put(PlayController(), permanent: true);
  final TextEditingController playerNameController = TextEditingController();
  final TextEditingController gameCodeController = TextEditingController();

  final userController = Get.find<UserController>();
  //late UserRole userRole;

  @override
  void initState() {
    super.initState();
    //_initializeUserRole();
  }

  /*Future<void> _initializeUserRole() async {
    setState(() {
      userRole = userController.userData.value!.role;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {Get.offNamed('/mainGames');},
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "hangman_play_settings".tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildOnlinePlayCard(),
                        const SizedBox(height: 10),
                        _buildJoinGame(),
                        const SizedBox(height: 10),
                        _buildLocalPlayCard(),
                        const SizedBox(height: 10),
                        _buildSoloPlayCard(),
                        const SizedBox(height: 10),
                        _buildStartGameButton(context),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if(userController.userData.value!.role != UserRole.normal)
                      Obx(() => !controller.isOfflineMode.value && !controller.isJoiningMode.value
                        ? ElevatedButton(
                            onPressed: () => Get.toNamed('/hangmanAddWords'),
                            child: Text("btn_send_words".tr,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ) : Container()
                      ),

                    TextButton(
                      onPressed: () => acceptDialog(
                          context,
                          'hangman_settings_title'.tr,
                          "${'hangman_settings_description'.tr}"
                              "\n\n${"play_rules_title".tr}"
                              "\n${"play_rules_description".tr}"
                      ),
                      child: Text('guide'.tr,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlinePlayCard() {
    return Obx(() => CustomSwitchTile(
      title: 'compete_online'.tr,
      subtitle: 'this_generating_code'.tr,
      value: controller.isOnlineMode.value,
      onChanged: (value) {
        controller.setOnlineMode(value);
        controller.setOfflineMode(false);
      },
      showAdditionalInfo: controller.isOnlineMode.value,
      additionalInfoTitle: 'share_game_code'.tr,
      additionalInfo: controller.gameCode.value,
      additionalActionIcon: Icons.copy,
      onAdditionalActionPressed: () {
        Clipboard.setData(ClipboardData(text: controller.gameCode.value));
        showCustomSnackbar("copied_to_clipboard".tr, true);
      },
    ));
  }

  Widget _buildLocalPlayCard() {
    return Obx(() => CustomSwitchTextboxTile(
      title: 'compete_offline'.tr,
      subtitle: 'give_players_name'.tr,
      value: controller.isOfflineMode.value,
      onSwitchChanged: (value) {
        controller.setOfflineMode(value);
        controller.setOnlineMode(false);
      },
      textController: playerNameController,
      textFieldHeader: 'add_player'.tr,
      textFieldHint: 'players_name_here'.tr,
      onItemAdd: controller.addLocalPlayer,
      items: controller.localPlayers,
      onItemRemove: controller.removeLocalPlayer,
    ));
  }

  Widget _buildJoinGame() {
    return Obx(() => CustomSwitchTextboxTile(
      title: 'join_with_code'.tr,
      subtitle: 'join_with_code_description'.tr,
      value: controller.isJoiningMode.value,
      onSwitchChanged: (value) {
        controller.setOfflineMode(false);
        controller.setOnlineMode(false);
        controller.setJoinMode(value);
      },
      textController: gameCodeController,
      textFieldHeader: 'game_code'.tr,
      textFieldHint: 'game_code_hint'.tr,
      onItemAdd: controller.joinGameWithCode,
      items: controller.localPlayers,
    ));
  }

  Widget _buildSoloPlayCard() {
    return Card(
      child: Container(
        padding: EdgeInsets.all(5.0),
        child: ListTile(
          title: Text('play_solo'.tr,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
          subtitle: Text('play_solo_description'.tr),
          trailing: const Icon(Icons.arrow_forward),
          onTap: controller.startSoloGamePlay,
        ),
      ),
    );
  }

  Widget _buildStartGameButton(BuildContext context) {
    return Obx(() {
      if (controller.isOnlineMode.value ||
          controller.isOfflineMode.value) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: controller.isOnlineMode.value || controller.localPlayers.length >=2
                  ? Colors.green
                  : Colors.white54,
            ),
            onPressed: () => controller.startTeamPlayGame(context),
            child: Text('btn_start'.tr,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}