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
      padding: const EdgeInsets.only(top: 5.0),
      child: Align(
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            left: sendByMe ? 30.0 : 8.0,
            right: sendByMe ? 8.0 : 30.0,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
          decoration: BoxDecoration(
            gradient: sendByMe
                ? LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : LinearGradient(
              colors: [Colors.white, Colors.grey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
              bottomLeft: sendByMe ? Radius.circular(30) : Radius.circular(5),
              bottomRight: sendByMe ? Radius.circular(5) : Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!sendByMe)
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage('URL_TO_USER_PROFILE_IMAGE'),
                    radius: 15,
                  ),
                ),
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sender,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: sendByMe ? Colors.white : Colors.blueGrey.shade800,
                      ),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 16,
                          color: sendByMe ? Colors.white : Colors.blueGrey.shade900,
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
