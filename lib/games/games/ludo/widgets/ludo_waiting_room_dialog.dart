import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/functions/string_cases.dart';
import 'package:playbazaar/games/games/ludo/controller/online_ludo_controller.dart';
import 'package:playbazaar/global_widgets/rarely_used/text_2_copy.dart';

class LudoWaitingRoomDialog extends StatelessWidget {
  //static const String dialogId = 'ludo_waiting_room';

  const LudoWaitingRoomDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final OnlineLudoController controller = Get.find<OnlineLudoController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'waiting_room'.tr,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Game Code Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text2Copy(
                inputText: controller.gameCode.value,
                textDescription: "game_code".tr,
              ),
            ),
            const SizedBox(height: 16),

            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 100,
                maxHeight: 400,
              ),
              child: Obx(() {
                return controller.players.isEmpty
                    ? Center(
                  child: Text(
                    'waiting_participants'.tr,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ) : ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.players.length,
                  itemBuilder: (context, index) {
                    final player = controller.players[index];
                    return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Stack(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.white54,
                                backgroundImage: player.avatarImg != null
                                    ? NetworkImage(player.avatarImg!)
                                    : null,
                                child: player.avatarImg == null || player.avatarImg == ""
                                    ? Text(player.name?[0].toUpperCase() ?? "x")
                                    : null,
                              ),
                              title: Row(
                                children: [
                                  Text(splitBySpace(player.name!)[0]),
                                  index == 0
                                      ? Text(
                                    " ${"host".tr}",
                                    style: TextStyle(fontSize: 10, color: Colors.red),
                                  )
                                      : Text(""),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  controller.players[index].playerId == controller.user!.uid && index!=0
                                      ? IconButton(
                                    onPressed: () => controller.removePlayer(controller.players[index].playerId!),
                                    icon: Icon(Icons.remove_circle_sharp, color: Colors.red, size: 20),
                                  ): Container(),
                                ],
                              ),
                            ),
                          ],
                        )
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => controller.closeWaitingRoom(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text("btn_leave".tr,
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: controller.isHost
                      ? Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.players.length >= 2 && controller.canStart.value
                          ? Colors.green
                          : Colors.grey,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: ()=> controller.players.length >= 2
                        ? controller.startNextGame()
                        : null,
                    child: Text(controller.players.length >= 2 && controller.canStart.value
                        ? 'btn_start'.tr
                        : 'waiting_participants'.tr,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ))
                      : Text('waiting_start'.tr,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
