import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> leavingGroupDialog(
    final Function() onLeaveGroup) async {
  return showDialog(
    barrierDismissible: false,
    context: Get.context!,  // Use Get.context for accessing context
    builder: (context) {
      return AlertDialog(
        title: Text("leaving".tr),
        content: Text("leaving_group".tr),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.cancel_presentation, color: Colors.red),
          ),
          IconButton(
            onPressed: () async {
              await onLeaveGroup();
              Navigator.pop(context); // Close the dialog after the action
            },
            icon: const Icon(Icons.done_outline, color: Colors.green),
          ),
        ],
      );
    },
  );
}
