import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../global_widgets/tiles/custom_switch_tile.dart';
import 'package:playbazaar/games/games/hangman/controller/play_controller.dart';

class HangmanPlaySettingsScreen extends StatelessWidget {
  final PlayController controller = Get.put(PlayController());
  final TextEditingController playerNameController = TextEditingController();

  HangmanPlaySettingsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors. red,
        centerTitle: true,
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildOnlinePlayCard(),
                    const SizedBox(height: 10),
                    _buildLocalPlayCard(),
                    const SizedBox(height: 16),
                    _buildOfflinePlayCard(),
                    const SizedBox(height: 16),
                    _buildStartGameButton(context),
                  ],
                ),
              ),
            ),
          ),
          Obx(() => !controller.isLocalMultiplayerMode.value
            ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/hangmanAddWords'),
                child: Text("btn_send_words".tr,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ) : Container()
          ),
        ],
      ),
    );
  }

  Widget _buildOnlinePlayCard() {
    return Obx(() => CustomSwitchTile(
      title: 'online_with_friends'.tr,
      subtitle: 'this_generating_code'.tr,
      value: controller.isOnlineMode.value,
      onChanged: (value) {
        controller.toggleOnlineMode(value);
        controller.toggleLocalMultiplayerMode(false);
      },
      showAdditionalInfo: controller.isOnlineMode.value,
      additionalInfoTitle: 'share_hangman_play_code'.tr,
      additionalInfo: controller.gameCode.value,
      additionalActionIcon: Icons.copy,
      onAdditionalActionPressed: () {
        // Copy functionality
      },
    ));
  }


  Widget _buildLocalPlayCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => SwitchListTile(
              title: Text('play_offline_multiplayer'.tr,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Text('give_players_name'.tr),
              value: controller.isLocalMultiplayerMode.value,
              onChanged: (value) {
                controller.toggleLocalMultiplayerMode(value);
                controller.toggleOnlineMode(false);
              },
              activeColor: Colors.green,
              inactiveThumbColor: Colors.black,
            )),
            Obx(() {
              if (controller.isLocalMultiplayerMode.value) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    Text('add_player'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: playerNameController,
                            decoration: InputDecoration(
                              hintText: 'players_name_here'.tr,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                              Icons.add,
                              color: Colors.green,
                              size: 40
                          ),
                          onPressed: () {
                            controller.addLocalPlayer(playerNameController.text.trim());
                            playerNameController.clear();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.localPlayers.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text((index + 1).toString()),
                          ),
                          title: Text(controller.localPlayers[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => controller.removeLocalPlayer(index),
                          ),
                        );
                      },
                    )),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflinePlayCard() {
    return Card(
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
    );
  }

  Widget _buildStartGameButton(BuildContext context) {
    return Obx(() {
      if (controller.isOnlineMode.value ||
          controller.isLocalMultiplayerMode.value) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            onPressed: () => controller.startTeamPlayGame(context),
            child: Text('btn_start'.tr,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}