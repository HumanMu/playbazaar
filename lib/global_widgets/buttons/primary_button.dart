import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  final Color? backgroundColor;
  final Color? textColor;

  final double? textSize;
  final Size? minSize;
  final Size? maxSize;
  final double? borderRadius;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.textSize,
    this.minSize,
    this.maxSize,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.blue,
        minimumSize: minSize ?? const Size(double.infinity, 50),
        maximumSize: maxSize,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: textSize ?? 16,
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
}
