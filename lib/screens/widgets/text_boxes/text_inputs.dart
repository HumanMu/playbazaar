import 'package:flutter/material.dart';

class CustomTextInputs extends StatelessWidget {
  final String? description;
  final String value;
  final Color? color;

  const CustomTextInputs({
    super.key,
    this.description,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _entryRow(description, value);
  }

  Widget _entryRow(
      String? description, String value) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Row(
        children: [
          // Use Expanded to stretch the widget to fill available space
          SizedBox(
            width: 70,
            child: Text(
              description ?? "",
              style: TextStyle(
                color: color ?? Colors.black,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          // Also use Expanded for the value to take up the remaining space
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '',
              style: TextStyle(
                color: color ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

}



/// TextController
class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final int? maxLine;

  const CustomTextFormField({super.key, required this.controller, this.maxLine = 1, this.labelText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, // Use the controller here
      maxLines: maxLine,
      decoration: InputDecoration(
        labelText: labelText?? "",
      ),
      style: const TextStyle(
        color: Colors.black,
      ),
    );
  }
}




