
import 'package:flutter/material.dart';

/*
class CustomTextInputs extends StatefulWidget {
  final String description;
  final String? value;
  final TextEditingController? textEditCon;
  final bool edit;

  const CustomTextInputs({Key? key,
    required this.description,
    required this.edit,
    this.value,
    this.textEditCon
  }) : super(key: key);

  @override
  State<CustomTextInputs> createState() => _CustomTextInputsState();
}
class _CustomTextInputsState extends State<CustomTextInputs> {

  @override
  Widget build(BuildContext context) {
    return _entryRow(widget.description, widget.value, widget.textEditCon, widget.edit);
  }

  Widget _entryRow(String description, String? value, TextEditingController? textEditCon, bool edit) {
    return widget.edit==false? Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.fromLTRB(30, 5, 30, 5),
      height: 30,
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
              child: Text(
                value != ""?value.toString() : '',
                style: const TextStyle(
                  color: Colors.white,
                ),
              )
          ),
        ],
      ),
    ) : Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.fromLTRB(30, 5, 30, 5),
        height: 30,
        child: TextFormField(
          initialValue: description.toString() ?? "",
          controller: textEditCon,
          style: const TextStyle(
            color: Colors.white,
          ),
        )
    );
  }
}*/

class CustomTextInputs extends StatelessWidget {
  final String? description;
  final String value;
  final TextEditingController? textEditCon;
  final bool edit;

  const CustomTextInputs({
    super.key,
    this.description,
    required this.value,
    required this.edit,
    this.textEditCon,
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
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                child: Text(
                  value.isNotEmpty? value : '',
                  style: const TextStyle(
                    color: Colors.white,
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
            style: const TextStyle(
              color: Colors.white,
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
        color: Colors.white,
      ),
    );
  }
}




