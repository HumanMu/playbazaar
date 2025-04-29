import 'package:flutter/material.dart';
import '../helper/functions.dart';
import '../models/ludo_player.dart';

class PlayerProfileWidget extends StatelessWidget {
  final LudoPlayer player;
  final bool isActive;
  final double size;
  final bool showDice;

  const PlayerProfileWidget({
    super.key,
    required this.player,
    this.isActive = false,
    this.size = 70.0,
    this.showDice = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 1. Calculate the desired size (8% of screen width)
    final double calculatedSize = screenWidth * 0.08;

    // 2. Clamp the calculated size between the minimum (55.0) and maximum (70.0)
    final double profileDimension = calculatedSize.clamp(55.0, 70.0);

    return SizedBox(
      // Use the clamped 'profileDimension' for width calculation
      width: showDice ? profileDimension * 2.5 : profileDimension,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use SizedBox to constrain the Stack's dimensions
          SizedBox(
            width: profileDimension,
            height: profileDimension,
            child: Stack(
              children: [
                Container(
                  width: profileDimension,
                  height: profileDimension,
                  decoration: BoxDecoration(
                    // Using withOpacity for transparency adjustment
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
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  // Icon display logic kept as is
                  child: player.avatarImg == null
                      ? Center( // Added Center for the Icon specifically
                    child: Icon(
                      player.isRobot != null && player.isRobot! ? Icons.smart_toy : null,
                      color: LudoHelper.getTokenColor(player.tokenType),
                      // Make Icon size relative to the clamped profile dimension
                      size: profileDimension / 2,
                    ),
                  )
                      : null,
                ),


                // Name label - Kept original logic using the 'size' parameter from constructor
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      // Using withOpacity for transparency adjustment
                      color: Colors.black.withValues(alpha: 0.5),
                      // Using original 'size' parameter for radius
                      borderRadius: BorderRadius.circular(size / 4),
                    ),
                    child: Text(
                      player.name ?? "Guest",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        // Using original 'size' parameter for font size
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
          ),
          // Potential placeholder or widget for dice if showDice is true
          // Add your dice widget here if needed, adjusting layout as required
          if (showDice)
          // Example: Add space or dice widget here
            SizedBox(width: profileDimension * 1.5 /* Adjust as needed */),

        ],
      ),
    );
  }
}