import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: Text(
        message, 
        style: const TextStyle(
          color: Colors.white, 
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}
