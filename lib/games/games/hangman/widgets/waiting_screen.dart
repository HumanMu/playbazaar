import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:playbazaar/functions/string_cases.dart';
import '../controller/play_controller.dart';

class WaitingRoomDialog extends StatelessWidget {
  const WaitingRoomDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final PlayController controller = Get.find<PlayController>();

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${"game_code".tr}: ${controller.gameCode.value}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: controller.gameCode.value));
                      Get.snackbar(
                        'copy'.tr,
                        'copied_to_clipboard'.tr,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(milliseconds: 1500),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 100,
                maxHeight: 400,
              ),
              child: Obx(() {
                return controller.participants.isEmpty
                ? Center(
                  child: Text(
                    'waiting_for_players'.tr,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.participants.length,
                  itemBuilder: (context, index) {
                    final player = controller.participants[index];
                    return Obx(() => Container(
                      color: controller.winner.value != null
                          && controller.winner.value!.uid == controller.participants[index].uid
                          ?  Colors.green.shade300
                          : Colors.transparent,
                      child: Stack(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white54,
                              backgroundImage: player.image != null
                                  ? NetworkImage(player.image!)
                                  : null,
                              child: player.image == null
                                  ? Text(player.name[0].toUpperCase())
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Text(splitBySpace(player.name)[0]),
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
                                controller.participants[0].uid == controller.user!.uid && index!=0
                                  ? IconButton(
                                    onPressed: () => controller.leaveOnlineCompetition(controller.participants[index].uid),
                                    icon: Icon(Icons.remove_circle_sharp, color: Colors.red, size: 20),
                                  ): Container(),
                                  Text(controller.participants[index].numberOfWin.toString()),
                              ],
                            ),
                          ),
                          controller.winner.value != null &&
                              controller.winner.value!.uid == controller.participants[index].uid
                            ? Positioned(
                              top: 15, // Adjust this value to align the text properly
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Text("winner".tr,
                                  style: TextStyle(
                                      color: Colors.orangeAccent,
                                      fontSize: 25, fontWeight:
                                  FontWeight.bold
                                  ),
                                ),
                              ),
                            ) : Container()
                        ],
                      )
                    ));
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => controller.leaveOnlineCompetition(controller.user!.uid),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text("btn_leave".tr,
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Obx(() => controller.isHost.value
                    ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.participants.length >= 2 && controller.canStart.value
                          ? Colors.green
                          : Colors.grey,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: ()=> controller.participants.length >= 2
                          ? controller.startNextOnlineGame()
                          : null,
                      child: Text(controller.participants.length >= 2 && controller.canStart.value
                          ? 'btn_start'.tr
                          : 'waiting_participants'.tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                        : Text('waiting_start'.tr,
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
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
