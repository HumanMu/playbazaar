
// call it only from widgets
import 'package:flutter/material.dart';

extension ShowErrorDialogExtensions on BuildContext {
  void showErrorDialog(String message) {
    showDialog(
      context: this,
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

  // More flexible version
  void showCustomErrorDialog({
    required String message,
    String title = 'Error',
    String buttonText = 'OK',
    VoidCallback? onPressed,
    bool popTwice = true,
  }) {
    showDialog(
      context: this,
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