import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      title: Center(
        child: Text(title),
      ),
      content: Text(description),
      actions: [
        TextButton(
          onPressed: onNo,
          child: Text('no'.tr,
            style: TextStyle(
              color: Colors.red,
              fontSize: 20
            ),
          ),
        ),
        TextButton(
          onPressed: onYes,
          child: Text('yes'.tr,
            style: TextStyle(
              color: Colors.green,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}
