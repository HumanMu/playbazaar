import 'package:flutter/material.dart';

class CustomTextInputs extends StatelessWidget {
  final String? description;
  final String value;
  final TextEditingController? textEditCon;
  final bool edit;
  final Color? color;

  const CustomTextInputs({
    super.key,
    this.description,
    required this.value,
    required this.edit,
    this.textEditCon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _entryRow(description, value, textEditCon, edit);
  }

  Widget _entryRow(
      String? description, String value, TextEditingController? textEditCon, bool edit) {
    return edit == false
        ? Container(
          alignment: Alignment.centerRight,
          margin: const EdgeInsets.fromLTRB(30, 5, 30, 5),
          height: 35,
          child: Row(
            children: [
              SizedBox(
                width: 65,
                child: Text(
                  description?? "",
                  style: TextStyle(
                    color: color ?? Colors.black,
                  ),
                ),
              ),
              SizedBox(
                child: Text(
                  value.isNotEmpty? value : '',
                  style: TextStyle(
                    color: color ?? Colors.black,
                  ),
                ),
              ),
            ],
          ),
        )
        : TextFormField(
            controller: textEditCon,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            style: TextStyle(
              color: color ?? Colors.black,
            ),
          );
  }
}



/// TextController
class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;

  const CustomTextFormField({super.key, required this.controller, this.labelText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, // Use the controller here
      decoration: InputDecoration(
        labelText: labelText?? "",
      ),
      style: const TextStyle(
        color: Colors.black,
      ),
    );
  }
}




