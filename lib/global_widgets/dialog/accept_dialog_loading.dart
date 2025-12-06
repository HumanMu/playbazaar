import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AcceptDialogLoading extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onOk;
  final RxBool isLoading;

  const AcceptDialogLoading({
    super.key,
    required this.title,
    required this.message,
    required this.onOk,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text(title)),
      content: SingleChildScrollView(
        child: Obx(() => isLoading.value
            ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'processing'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        )
            : Text(
          message,
          textDirection: Directionality.of(context),
          textAlign: TextAlign.start,
        )),
      ),
      actions: <Widget>[
        Center(
          child: Obx(() => TextButton(
            onPressed: isLoading.value ? null : onOk,
            child: Text(
              'btn_ok'.tr,
              style: TextStyle(
                fontSize: 25,
                color: isLoading.value ? Colors.grey : Colors.green,
              ),
            ),
          )),
        ),
      ],
    );
  }
}