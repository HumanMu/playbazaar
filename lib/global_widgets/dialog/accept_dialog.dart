import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> acceptDialog(BuildContext context, String title, String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
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
              child: Text('btn_ok'.tr,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.green
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    },
  );
}
