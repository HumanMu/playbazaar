import 'package:flutter/material.dart';
import 'package:get/get.dart';
class StringReturnDialog extends StatelessWidget {
  final String title;
  final String? description;
  final String hintText;
  final Color? btnApproveColor;

  const StringReturnDialog({
    required this.title,
    this.description,
    required this.hintText,
    this.btnApproveColor,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return AlertDialog(
      title: Center(
        child: Text(title,
          style: TextStyle(fontSize: 30),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description Text
          Text(
            description ?? "",
            style: TextStyle(fontSize: 13, color: Colors.black),
          ),
          SizedBox(height: description!=null? 10 : 0),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.black54,
                fontStyle: FontStyle.italic,
                fontSize: 12
              )
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text('btn_cancel'.tr),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(controller.text.isEmpty ? null : controller.text);
          },
          child: Text('btn_approve'.tr,
            style: TextStyle(
              color: btnApproveColor?? Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}

