import 'package:flutter/material.dart';

class YesNoDialog extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onYes;
  final VoidCallback onNo;

  const YesNoDialog({
    super.key,
    required this.title,
    required this.description,
    required this.onYes,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(
          onPressed: onNo,
          child: const Text('No'),
        ),
        TextButton(
          onPressed: onYes,
          child: const Text('Yes'),
        ),
      ],
    );
  }
}
