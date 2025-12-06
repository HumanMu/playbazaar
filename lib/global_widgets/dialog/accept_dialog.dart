import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AcceptDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onOk;

  const AcceptDialogWidget({
    super.key,
    required this.title,
    required this.message,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text(title)),
      content: SingleChildScrollView(
        child: Text(
          message,
          textDirection: Directionality.of(context),
          textAlign: TextAlign.start,
        ),
      ),
      actions: <Widget>[
        Center(
          child: TextButton(
            onPressed: onOk,
            child: Text(
              'btn_ok'.tr,
              style: TextStyle(fontSize: 25, color: Colors.green),
            ),
          ),
        ),
      ],
    );
  }
}