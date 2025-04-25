import 'package:flutter/material.dart';
import '../helper/functions.dart';
import '../models/ludo_player.dart';

class PlayerProfileWidget extends StatelessWidget {
  final LudoPlayer player;
  final bool isActive;
  final double size;

  const PlayerProfileWidget({
    super.key,
    required this.player,
    this.isActive = false,
    this.size = 60.0,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: isActive
              ? LudoHelper.getTokenColor(player.tokenType)
              : Colors.grey.shade300,
          width: isActive ? 3.0 : 1.0,
        ),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: LudoHelper.getTokenColor(player.tokenType).withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ]
            : null,
      ),
      child: Stack(
        children: [
          // Profile image
          Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: LudoHelper.getTokenColor(player.tokenType).withValues(alpha: 0.2),
                image: player.avatarImg != null
                    ? DecorationImage(
                  image: AssetImage(player.avatarImg!),
                  fit: BoxFit.cover,
                )
                    : DecorationImage(
                  image: AssetImage("assets/games/ludo/ludo_profile.jpg"),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: LudoHelper.getTokenColor(player.tokenType),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8), // Slight rounding (optional)
              ),
              child: player.avatarImg == null
                  ? Icon(
                player.isRobot != null ? null : Icons.smart_toy,
                color: LudoHelper.getTokenColor(player.tokenType),
                size: size / 2,
              )
                  : null,
            ),
          ),

          // Name label
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(size / 4),
              ),
              child: Text(
                player.name ?? "Guest",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size / 8,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}