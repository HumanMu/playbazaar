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
        width: double.minPositive,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'waiting_room'.tr,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),

            // Game Code Section
            Container(
              padding: const EdgeInsets.all(8),
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

            // Players List - Modified for better visibility
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
                    return ListTile(
                      leading: CircleAvatar(
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
                          index==0? Text(" ${"host".tr}",
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          ) : Text(""),
                        ],
                      ),
                      trailing: Text(controller.participants[index].numberOfWin.toString())
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => controller.leaveOnlineCompetition(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text("btn_leave".tr,
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 5),  // Add spacing between buttons
                Expanded(  // Add Expanded to properly distribute space
                  child: Obx(() => controller.isHost.value
                    ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.participants.length >= 2
                          ? Colors.green
                          : Colors.grey,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: ()=> controller.participants.length >= 2
                          ? controller.startNextOnlineGame(context)
                          : null,
                      child: Text(controller.participants.length >= 2
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