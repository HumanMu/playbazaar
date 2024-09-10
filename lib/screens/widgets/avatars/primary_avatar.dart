import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../../../utils/custom_avatar.dart';


class PrimaryAvatarImage extends StatefulWidget {
  final bool editing;
  const PrimaryAvatarImage({super.key, required this.editing});

  @override
  State<PrimaryAvatarImage> createState ()=> _PrimaryAvatarState();
}

class _PrimaryAvatarState extends State<PrimaryAvatarImage> {

  Uint8List? avatarimage;
  void selectAvatarImage() async {
    Uint8List img = await selectAvatar(ImageSource.gallery);
    setState(() {
      avatarimage = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool editingState = widget.editing? true : false;

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
              avatarimage !=null ?
              CircleAvatar(
                radius: 45,
                backgroundImage: MemoryImage(avatarimage!),
              ) : const CircleAvatar(
                backgroundColor: Colors.deepOrangeAccent,
                radius: 45,
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/icons/afghanChatLogo.png'),
                  radius: 40.0,
                ),
              ),
              Positioned(
                bottom: -15,
                right: 50,
                child: IconButton(
                  onPressed: selectAvatarImage,
                  icon: const  Icon(
                    Icons.add_a_photo,
                    color: Colors.green,
                  ),
                ),
              ),
            ],

        ),
      ),
    );
  }
}

