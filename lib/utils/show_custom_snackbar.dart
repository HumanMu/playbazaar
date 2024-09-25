import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackbar( String message, bool successful, {int? timing}) {
  Get.rawSnackbar(
    backgroundColor: successful
        ? Colors.green.withOpacity(0.7)
        :  Colors.redAccent.withOpacity(0.7),
    margin: const EdgeInsets.all(10),
    borderRadius: 10,
    borderWidth: 2,
    snackPosition: SnackPosition.TOP,
    duration: Duration(seconds: timing  ?? 3),
    // Custom layout
    snackStyle: SnackStyle.FLOATING, // Use GROUNDED for custom layout
    titleText: Text(
      "notification_title".tr,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 20,
      ),
    ),
    messageText: Text(
      message,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    ),
    //icon: Icon(Icons.warning, color: Colors.white),
  );
}
