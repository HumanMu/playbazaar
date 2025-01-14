import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSwitchTextboxTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onSwitchChanged;
  final TextEditingController textController;
  final String? textFieldHeader;
  final String? textFieldHint;
  final Function(String) onItemAdd;
  final List<String> items;
  final Function(int)? onItemRemove;
  final bool showRemoveButton;

  const CustomSwitchTextboxTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onSwitchChanged,
    required this.textController,
    required this.onItemAdd,
    required this.items,
    this.textFieldHeader,
    this.textFieldHint,
    this.onItemRemove,
    this.showRemoveButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(

      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(subtitle),
              value: value,
              onChanged: onSwitchChanged,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.black,
            ),
            if (value) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                textFieldHeader ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: textFieldHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.green,
                      size: 40,
                    ),
                    onPressed: () {
                      final text = textController.text.trim();
                      if (text.isNotEmpty) {
                        onItemAdd(text);
                        textController.clear();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text((index + 1).toString()),
                    ),
                    title: Text(items[index]),
                    trailing: showRemoveButton && onItemRemove != null
                        ? IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => onItemRemove!(index),
                    )
                        : null,
                  );
                },
              )),
            ],
          ],
        ),
      ),
    );
  }
}