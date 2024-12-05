import 'package:flutter/material.dart';

import '../screens/widgets/avatars/primary_avatar.dart';
import '../screens/widgets/header.dart';


class HeaderStack extends StatelessWidget {
  const HeaderStack({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.5,
          child: ClipPath(
            clipper: Header(),
            child: Container(
              color: Colors.limeAccent,
              height: 205,
            ),
          ),
        ),
        ClipPath(
          clipper: Header(),
          child: Container(
            color: Colors.redAccent,
            height: 185,
            alignment: Alignment.centerLeft,
            child: const PrimaryAvatarImage(editing: false),
          ),
        ),
      ],
    );
  }
}
