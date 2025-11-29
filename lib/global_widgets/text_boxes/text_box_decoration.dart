
import 'package:flutter/material.dart';

InputDecoration decoration(String? hintText) {
  return InputDecoration(
    hintText: hintText!=""? hintText : "",
      enabledBorder: OutlineInputBorder(
        borderSide:
        const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(15),
      ),
      errorBorder: OutlineInputBorder(
          borderSide:
          const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
        borderSide:
        const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(15),
      )
  );
}
