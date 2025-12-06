import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateInfoDialog extends StatelessWidget {
  final String version;
  final VoidCallback onClose;

  const UpdateInfoDialog({
    super.key,
    required this.version,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.celebration, color: Colors.orange, size: 28),
          SizedBox(width: 12),
          Text('whats_new'.tr),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'version'.tr} $version',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'update_message_$version'.tr,
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: onClose,
          child: Text('got_it'.tr),
        ),
      ],
    );
  }
}