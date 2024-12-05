import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> acceptDialog(context, title, message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: Text(title)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: Text('btn_ok'.tr,
                style: TextStyle(fontSize: 25),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
          )),
        ],
      );
    },
  );
}