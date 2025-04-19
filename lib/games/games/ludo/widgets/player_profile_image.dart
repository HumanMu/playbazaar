import 'package:flutter/material.dart';
import '../helper/enums.dart';
import '../models/player_profile.dart';

class PlayerProfileWidget extends StatelessWidget {
  final PlayerProfile player;
  final bool isActive;
  final double size;

  const PlayerProfileWidget({
    super.key,
    required this.player,
    this.isActive = false,
    this.size = 80.0,
  });

  Color _getColorForToken(TokenType type) {
    switch (type) {
      case TokenType.red:
        return Colors.red;
      case TokenType.green:
        return Colors.green;
      case TokenType.blue:
        return Colors.blue;
      case TokenType.yellow:
        return Colors.amber;
    }
  }

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
              ? _getColorForToken(player.tokenType)
              : Colors.grey.shade300,
          width: isActive ? 3.0 : 1.0,
        ),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: _getColorForToken(player.tokenType).withValues(alpha: 0.5),
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
            child: CircleAvatar(
              radius: (size / 2) - 5,
              backgroundColor: _getColorForToken(player.tokenType).withValues(alpha: 0.2),
              backgroundImage: player.avatarUrl != null
                  ? AssetImage(player.avatarUrl!)
                  : AssetImage("assets/games/ludo/ludo_board.png"),
              child: player.avatarUrl == null
                  ? Icon(
                player.isRobot ? Icons.smart_toy : Icons.person,
                color: _getColorForToken(player.tokenType),
                size: size / 3,
              )
                  : null,
            ),
          ),

          // Robot indicator
          if (player.isRobot)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Icon(
                  Icons.smart_toy,
                  size: size / 5,
                  color: Colors.grey.shade700,
                ),
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
                player.name,
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