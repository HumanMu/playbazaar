import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helper/enums.dart';
import '../models/ludo_player.dart';

class GameOverDialog extends StatelessWidget {
  final List<LudoPlayer> players;
  final bool isTeamPlay;
  final VoidCallback onWatchRemaining;
  final VoidCallback onLeave;

  const GameOverDialog({
    super.key,
    required this.players,
    required this.isTeamPlay,
    required this.onWatchRemaining,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    // Determine winner
    String winnerText = '';
    Color winnerColor = Colors.blue;

    if (isTeamPlay) {
      // Team play logic
      for (var teamId in {1, 2}) {
        bool teamWon = true;
        for (var player in players.where((p) => p.teamId == teamId)) {
          if (!player.hasFinished) {
            teamWon = false;
            break;
          }
        }

        if (teamWon) {
          // Determine team colors
          if (teamId == 1) {
            winnerText = 'red_yellow_winner'.tr;
            winnerColor = Colors.red;
          } else {
            winnerText = 'green_blue_winner'.tr;
            winnerColor = Colors.green;
          }
          break;
        }
      }
    } else {
      // Individual play logic
      for (var player in players) {
        if (player.hasFinished) {
          winnerText = '${"winner".tr}: ${player.name}';

          // Set color based on token type
          switch (player.tokenType) {
            case TokenType.red:
              winnerColor = Colors.red;
              break;
            case TokenType.green:
              winnerColor = Colors.green;
              break;
            case TokenType.yellow:
              winnerColor = Colors.amber;
              break;
            case TokenType.blue:
              winnerColor = Colors.blue;
              break;
          }
          break;
        }
      }
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: Get.width * 0.85,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Circular gradient background
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        winnerColor.withValues(alpha: 0.7),
                        winnerColor.withValues(alpha: 0.3),
                        winnerColor.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
                // Trophy icon
                Icon(
                  Icons.emoji_events_rounded,
                  size: 80,
                  color: winnerColor,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'game_over'.tr,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              winnerText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: winnerColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDialogButton(
                  'btn_watch_remaining'.tr,
                  Colors.green,
                  onWatchRemaining,
                ),
                _buildDialogButton(
                  'btn_leave'.tr,
                  Colors.red,
                  onLeave,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build consistent buttons
  Widget _buildDialogButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
