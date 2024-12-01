import 'package:flutter/material.dart';

class MessageTileGroup extends StatelessWidget {
  final String message;
  final String sender;
  final bool sendByMe;

  const MessageTileGroup({
    super.key,
    required this.message,
    required this.sender,
    required this.sendByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
            bottomLeft: const Radius.circular(10),
            bottomRight: sendByMe ? Radius.zero : const Radius.circular(10),
          ),
          color: sendByMe ? Colors.red : Colors.green,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                  color: Colors.white54
              ),
            ),
            const SizedBox(width: 5),
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}