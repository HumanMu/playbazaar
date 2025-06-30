import 'package:flutter/material.dart';

class MessageTilePrivate extends StatelessWidget {
  final String message;
  final String sender;
  final bool sendByMe;

  const MessageTilePrivate({
    super.key,
    required this.message,
    required this.sender,
    required this.sendByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: sendByMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(25),
            topRight: const Radius.circular(25),
            bottomLeft: const Radius.circular(25),
            bottomRight: sendByMe ? const Radius.circular(25) : Radius.zero ,
          ),
          color: sendByMe ? Colors.red : Colors.green,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
