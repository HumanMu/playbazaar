import 'package:flutter/material.dart';

class CustomListDialog extends StatelessWidget {
  final List<String> items;
  final String title;

  const CustomListDialog({
    super.key,
    required this.items,
    this.title = 'Select an Option'
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) => ListTile(
            title: Text(item),
            onTap: () => Navigator.of(context).pop(item),
          )).toList(),
        ),
      ),
    );
  }

  static Future<String?> show(BuildContext context, {
    required List<String> items,
    String title = 'Select an Option'
  }) async {
    return showDialog<String>(
      context: context,
      builder: (_) => CustomListDialog(
          items: items,
          title: title
      ),
    );
  }
}
