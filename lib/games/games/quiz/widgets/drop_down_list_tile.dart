import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DropDownListTile extends StatefulWidget {
  final List<String> quizLabels;
  final List<String> quizPaths;
  final ValueChanged<int?> onQuizSelected;

  const DropDownListTile({
    super.key,
    required this.quizLabels,
    required this.quizPaths,
    required this.onQuizSelected,
  });

  @override
  State<DropDownListTile> createState() => _DropDownListTileState();
}

class _DropDownListTileState extends State<DropDownListTile> {
  int? selectedQuizIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("change_path".tr, style: const TextStyle(fontSize: 16)),

        DropdownButton<int>(
          hint: Text('select'.tr),
          value: selectedQuizIndex,
          items: widget.quizLabels.asMap().entries.map((entry) {
            int index = entry.key;
            String label = entry.value;
            return DropdownMenuItem<int>(
              value: index,
              child: Text(label),
            );
          }).toList(),

          onChanged: (int? newIndex) {
            setState(() {
              selectedQuizIndex = newIndex;
              widget.onQuizSelected(newIndex); // Callback to handle selection
            });
          },
        ),
      ],
    );
  }
}
