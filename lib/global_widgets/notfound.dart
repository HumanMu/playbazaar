import 'package:flutter/cupertino.dart';

notFound(message, guidanceText) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        Text(
          guidanceText,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
      ],
    ),
  );
}