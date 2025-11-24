import 'package:flutter/material.dart';

Widget circleAvatar (String text, {double radius = 25.0, Color bgColor = Colors.red} ) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.red,
    child: Text(
      text.substring(0, 1).toUpperCase(),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w300,
      ),
    ),
  );

}

