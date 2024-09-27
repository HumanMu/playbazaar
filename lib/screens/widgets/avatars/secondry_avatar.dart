import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

class SecondaryAvatar extends StatefulWidget {
  final String avatarImage;
  const SecondaryAvatar({super.key, required this.avatarImage});

  @override
  State<SecondaryAvatar> createState ()=> _SecondaryAvatarState();
}

class _SecondaryAvatarState extends State<SecondaryAvatar> {

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      startDelay: const Duration(milliseconds: 2000),
      glowColor: Colors.white,
      glowShape: BoxShape.circle,
      curve: Curves.fastOutSlowIn,
      child: Material(
        elevation: 6.0,
        shape: const CircleBorder(),
        child: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.redAccent,
              radius: 25,
              child: Text(widget.avatarImage.substring(0,1).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ), // Taking the first character of his/her first name and converting to uppercase
            ),
          ],
        ),
      ),
    );
  }

}