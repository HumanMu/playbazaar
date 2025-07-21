
// Call it only from a controller or services

import 'package:flutter/material.dart';

class DialogUtils {
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Optional: More flexible version with customizable actions
  static void showErrorDialogCustom({
    required BuildContext context,
    required String message,
    String title = 'Error',
    String buttonText = 'OK',
    VoidCallback? onPressed,
    bool popTwice = true,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onPressed ?? () {
              Navigator.of(context).pop(); // Close dialog
              if (popTwice) {
                Navigator.of(context).pop(); // Go back to previous screen
              }
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
