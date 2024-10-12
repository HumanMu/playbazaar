
import 'package:flutter/material.dart';

Widget entryRow(String description, String value) {
  return Container(
    alignment: Alignment.centerRight,
    margin: const EdgeInsets.fromLTRB(30, 5, 30, 5),
    height: 30,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          child: Text(
            value.isNotEmpty? value : '',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
            width: 60,
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.white,
              ),
            )
        ),
      ],
    ),
  );
}