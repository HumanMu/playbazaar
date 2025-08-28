import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../show_custom_snackbar.dart';

class Text2Copy extends StatelessWidget {
  const Text2Copy({
    super.key,
    required this.inputText,
    this.textDescription,
    this.inputTextStyle,
    this.copyIconColor,
    this.onCopyPressed,
    this.bgColor
  });

  final String inputText;
  final TextStyle? inputTextStyle;
  final Color? copyIconColor;
  final Color? bgColor;
  final VoidCallback? onCopyPressed;
  final String? textDescription;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: bgColor,
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            // Text description (if present) - no expansion needed
            if (textDescription != null && textDescription!.isNotEmpty)
              Text(
                "${"$textDescription"}:  ",
                style: inputTextStyle ?? const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

            // Expanded section for input text and icon button
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Flexible text that can wrap or truncate if needed
                  Flexible(
                    child: Text(
                      inputText,
                      style: inputTextStyle ?? const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.copy),
                      color: copyIconColor ?? Colors.black,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: inputText));
                        showCustomSnackbar("copied_to_clipboard".tr, true);
                      }
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
}