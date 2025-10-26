import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

Future<void> leavingGroupDialog(
    final Function() onLeaveGroup, BuildContext context) async {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("leaving".tr),
        content: Text("leaving_group".tr),
        actions: [
          IconButton(
            onPressed: () {
              context.pop();
              //Navigator.pop(context);
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
